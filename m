Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BAABCC4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 17:56:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 8D34F2082C
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 17:56:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="PTj4+TwS"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729136AbfDBR4G (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 13:56:06 -0400
Received: from aserp2120.oracle.com ([141.146.126.78]:40192 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726582AbfDBR4F (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2019 13:56:05 -0400
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32HNlNI150117;
        Tue, 2 Apr 2019 17:26:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : to : cc :
 references : from : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=QVq0Ky60rHlYtMGe76rm1r8JFi+4H3tt4YpJzOb0SrM=;
 b=PTj4+TwSQnNOe1WBCzU46UmuI7BDQ7LeoTXZB95qOnMwcEp3p5qEqm+Jo9BNn6u2OzgV
 YDVUvVuIiMcfjZDY5DXZITHCWw7wW0pikr0Z0vXKTOntHys9NcMv/pIek1ZeOFMVvQwv
 Q9LB3q2eO4t0eu6Wf481II5T/oIhRPXG428PClIfhGSZaWuvOpRo5/JAjCrWOV2HEcZU
 BFoFut43RXzPLdabJJa9CM39QZBH+zyBt3ezMUMEkFVA7p2KdBWrV6bSnp7uH7eHOiL/
 kZzCuRS/1wz+B05GOVp3Aakoz7TMOFOEf4atyo+0qRGYG1OmbXUa+H9vvlT6xrrN4fNt vQ== 
Received: from aserp3020.oracle.com (aserp3020.oracle.com [141.146.126.70])
        by aserp2120.oracle.com with ESMTP id 2rj0dnjc91-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 02 Apr 2019 17:26:22 +0000
Received: from pps.filterd (aserp3020.oracle.com [127.0.0.1])
        by aserp3020.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32HPLiP038637;
        Tue, 2 Apr 2019 17:26:22 GMT
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserp3020.oracle.com with ESMTP id 2rm9mhkaqt-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 02 Apr 2019 17:26:22 +0000
Received: from abhmp0010.oracle.com (abhmp0010.oracle.com [141.146.116.16])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x32HQL6S002183;
        Tue, 2 Apr 2019 17:26:21 GMT
Received: from bradley.us.oracle.com (/10.152.12.111)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 02 Apr 2019 10:26:20 -0700
Subject: Re: directory delegations
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     linux-nfs@vger.kernel.org
References: <2065755c-f888-9c62-f6e5-f143d42c51ee@oracle.com>
 <20190402161116.GA2828@fieldses.org>
From:   "Bradley C. Kuszmaul" <bradley.kuszmaul@oracle.com>
Message-ID: <2f1f6582-3672-1361-4392-80cb1e62e19c@oracle.com>
Date:   Tue, 2 Apr 2019 13:26:19 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190402161116.GA2828@fieldses.org>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=929
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904020115
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 lowpriorityscore=0
 mlxlogscore=974 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904020115
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

My simple model of metadata operations is to untar something like the 
linux sources.

Each file incurs a LOOKUP, CREATE, SETATTR, and WRITE, each of which is 
fairly high latency (even the WRITE ends up being done essentially 
synchronously because tar closes the file after its write(2) call.)

I guess directory delegations might save the cost of LOOKUP.

Is there any hope for getting write delegations?

What other steps might be possible?

-Bradley

On 4/2/19 12:11 PM, bfields@fieldses.org wrote:
> On Mon, Apr 01, 2019 at 12:21:49PM -0400, Bradley C. Kuszmaul wrote:
>> Hi, I'm the architect for Oracle's File Storage Service.   FSS is
>> basically a big scalable NFS server that runs in Oracle's cloud.
>>
>> Our metadata operations have higher latency than a vanilla NFS
>> server (e.g., a Linux NFS server serving a XFS stored on a block
>> device), and we suspect that directory delegations would make a big
>> performance improvement.
>>
>> I understand, however, that essentially no one implements directory
>> delegations.
>>
>> Can anyone fill me in on the current thinking of the future of
>> support for directory delegations in the Linux NFS client?
> Maybe somebody else will speak up, but I don't know of any effort to
> implement directory delegations.
>
> What metadata operations specifically are you worried about?  The
> directory delegations that are specified in RFC 5661 are read-only.
> Which might explain some of the lack of interest.
>
> But there may be other steps that we could take to improve matters.
>
> --b.
