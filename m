Return-Path: <SRS0=5sV6=SF=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 90F5BC4360F
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 16:56:42 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 57263206DF
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Apr 2019 16:56:42 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="kkXRwlp3"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725959AbfDCQ4l (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 3 Apr 2019 12:56:41 -0400
Received: from userp2120.oracle.com ([156.151.31.85]:54782 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726099AbfDCQ4l (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Apr 2019 12:56:41 -0400
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33Gromo148865;
        Wed, 3 Apr 2019 16:56:33 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=vvkLKGpICLmHzthcobm4DCwVlCgFh/+luoeASLOLQs8=;
 b=kkXRwlp36tPgMCrZWDvFM+PZNd2y5vWzGxAAcoMkNMXTL8co3Krca+t/e4KlUXaa5p5b
 t/uSt3vpWgFX8ej05CQDz13QLCIjwGeGAh0G/vTFppgNdpQ/FEFIkbc0a53rZ1XHS5WT
 XJmlSN1UZjAHm0xnWQduc4nMmtOcsNuX+RvPuinPgs6L7D4tIzacAow+iVIXxfp9KRTU
 /gwWKmHbzFNVHl9gPRvMsPDzobKyvlJPN8wN8h60JIE2OQakWYArvWw00vALkQQsN7Qn
 n7lGjIRA7KC4wuDnGYV77t3g2PRvwShnUM7gGGb3w3xvVjqUircDVByFtLNTdhUlrkbn bA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
        by userp2120.oracle.com with ESMTP id 2rj13qa7cx-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 03 Apr 2019 16:56:32 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
        by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x33GuBI4176820;
        Wed, 3 Apr 2019 16:56:31 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userp3030.oracle.com with ESMTP id 2rm8f57bcy-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Wed, 03 Apr 2019 16:56:31 +0000
Received: from abhmp0003.oracle.com (abhmp0003.oracle.com [141.146.116.9])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x33GuPjr008000;
        Wed, 3 Apr 2019 16:56:29 GMT
Received: from bradley.us.oracle.com (/10.152.12.111)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Wed, 03 Apr 2019 09:56:25 -0700
Subject: Re: directory delegations
To:     "bfields@fieldses.org" <bfields@fieldses.org>,
        Trond Myklebust <trondmy@hammerspace.com>
Cc:     "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
References: <2065755c-f888-9c62-f6e5-f143d42c51ee@oracle.com>
 <20190402161116.GA2828@fieldses.org>
 <2f1f6582-3672-1361-4392-80cb1e62e19c@oracle.com>
 <20190402194148.GA5269@fieldses.org>
 <58230e155813e866cb057e6543ab7e61f51fedf6.camel@hammerspace.com>
 <20190403002822.GA7667@fieldses.org>
 <ec8d33473da41b3bde45f5ef1b4a02b98a535ac5.camel@hammerspace.com>
 <20190403020750.GA8272@fieldses.org>
From:   "Bradley C. Kuszmaul" <bradley.kuszmaul@oracle.com>
Message-ID: <c538dd35-fd1f-bab6-1cd3-6c9639462eab@oracle.com>
Date:   Wed, 3 Apr 2019 12:56:24 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190403020750.GA8272@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904030114
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9216 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1904030115
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

This proposal does look like it would be helpful.   How does this kind 
of proposal play out in terms of actually seeing the light of day in 
deployed systems?

-Bradley

On 4/2/19 10:07 PM, bfields@fieldses.org wrote:
> On Wed, Apr 03, 2019 at 02:02:54AM +0000, Trond Myklebust wrote:
>> The create itself needs to be sync, but the attribute delegations mean
>> that the client, not the server, is authoritative for the timestamps.
>> So the client now owns the atime and mtime, and just sets them as part
>> of the (asynchronous) delegreturn some time after you are done writing.
>>
>> Were you perhaps thinking about this earlier proposal?
>> https://urldefense.proofpoint.com/v2/url?u=https-3A__tools.ietf.org_html_draft-2Dmyklebust-2Dnfsv4-2Dunstable-2Dfile-2Dcreation-2D01&d=DwIBAg&c=RoP1YumCXCgaWHvlZYR8PZh8Bv7qIrMUB65eapI_JnE&r=YIKOmJLMLfe5wQR3VJI7jGjCnepZlMwumApzvaKItrY&m=qlAJ6dZPGjbcTzNIpkTyk-RTii6lWw1CLIjF6jp3P2Y&s=aTTFNJlRH-dXrQmE4cSYEUd8Kv3ij5cqTJtvgIixMa8&e=
> That's it, thanks!
>
> Bradley is concerned about performance of something like untar on a
> backend filesystem with particularly high-latency metadata operations,
> so something like your unstable file createion proposal (or actual write
> delegations) seems like it should help.
>
> --b.
