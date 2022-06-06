retry() {  # command, times, wait, expected_output (overwrite status to 0 if it is the same)
    retry_times=0
    retry=$2
    command=$1

    ok_result=$4

    echo "Trying: $command"
    result=$(eval $command)
    status=$?
    echo "$result"
    until (exit $status) || [ $retry_times -eq $retry ]; do
        if [ ! -z "$ok_result" ] && [[ $result =~ $ok_result ]]; then
            echo "Althought the status code is not 0, the output is the expected, so retuning a success."
            status=0
            break
        fi
        echo "Retrying: $command"
        result=$(eval $command)
        status=$?
        echo "$result"
        sleep $3
        echo $(( retry_times++ ))
    done
    (exit $status)
}
rm aws.yaml || true
rm aws-cidrs.json || true
# downloading AWS CIDRs blocks
    retry "curl --max-time 10 -o aws-cidrs.json https://ip-ranges.amazonaws.com/ip-ranges.json" 10 10

    blocks=$(jq --arg rg us-west-2 '.prefixes[] | select(.region==$rg and .service=="AMAZON") | .ip_prefix' < aws-cidrs.json)
    global_blocks=$(jq --arg rg GLOBAL '.prefixes[] | select(.region==$rg and .service=="AMAZON") | .ip_prefix' < aws-cidrs.json)
    east_blocks=$(jq --arg rg us-east-1 '.prefixes[] | select(.region==$rg and .service=="AMAZON") | .ip_prefix' < aws-cidrs.json)
    s3_blocks=$(jq --arg rg us-west-2 '.prefixes[] | select(.region==$rg and .service=="S3") | .ip_prefix' < aws-cidrs.json)

    # render cidrs for amazon (all cidrs for the region) (aws.amazon keys)
    cp ./aws.amazon.template.yaml ./amazon.yaml

    arr=$(echo $blocks | tr " " "\n")
    for x in $arr
    do
        echo "    - value: $x" >> ./amazon.yaml
    done
    cat ./amazon.yaml >> ./aws.yaml
    rm ./amazon.yaml

    # render cidrs for AMAZON on GLOBAL region (aws.global keys)
    cp ./aws.amazon.template.yaml ./amazon.yaml
    sed -i -e "s/amazon/global/" ./amazon.yaml

    arr=$(echo $global_blocks | tr " " "\n")
    for x in $arr
    do
        echo "    - value: $x" >> ./amazon.yaml
    done
    cat ./amazon.yaml >> ./aws.yaml
    rm ./amazon.yaml

    #render cidrs for AMAZON service on us-east-1 region (aws.useast1 keys)
    cp ./aws.amazon.template.yaml ./amazon.yaml
    sed -i -e "s/amazon/useast1/" ./amazon.yaml

    arr=$(echo $east_blocks | tr " " "\n")
    for x in $arr
    do
        echo "    - value: $x" >> ./amazon.yaml
    done
    cat ./amazon.yaml >> ./aws.yaml
    rm ./amazon.yaml

    # render cidrs for s3
    cp ./aws.s3.template.yaml ./s3.yaml
    arr=$(echo $s3_blocks | tr " " "\n")
    for x in $arr
    do
        echo "    - value: $x" >> ./s3.yaml
    done
    cat ./s3.yaml >> ./aws.yaml
    rm ./s3.yaml

