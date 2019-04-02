Return-Path: <SRS0=y3t/=SE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B0596C4360F
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 17:33:17 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 848242075E
	for <linux-nfs@archiver.kernel.org>; Tue,  2 Apr 2019 17:33:17 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="DcVroEIF"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729434AbfDBRdQ (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 2 Apr 2019 13:33:16 -0400
Received: from aserp2120.oracle.com ([141.146.126.78]:47792 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725959AbfDBRdQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 Apr 2019 13:33:16 -0400
X-Greylist: delayed 411 seconds by postgrey-1.27 at vger.kernel.org; Tue, 02 Apr 2019 13:33:15 EDT
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32HTL9C156078;
        Tue, 2 Apr 2019 17:33:13 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=subject : from : to :
 cc : references : message-id : date : mime-version : in-reply-to :
 content-type : content-transfer-encoding; s=corp-2018-07-02;
 bh=CXo+ZYkGDFwFJks0m9aXHdoqpdaCva9kPwV0Xm1bUsg=;
 b=DcVroEIFKlQamRziXxrCIaMnKCC+aYExGOHm2JI7jWetQ2erbU4PW0o5GjbO5m0Mt+aK
 hAu4ihuGCILSP40q0PjhtWTj6NLJLxxiygY0wdteBpkB9FSlTqq+/p05J8USn6/Rt4md
 mGTYA8W/CJ4Y5R66nhKO6u0ac2DWUw+nHd/hQGQ+60QrDaLTyrA2vKFn7Lpfyf0PsRch
 OPOwcYXCR1ROhFShNC+a3BH8AyYaSjzi3L0X1ApYHAd5Lzvcuq/crX180RYrCsFXonYa
 /EAeqTWwn3PbFBb32NsrPRyK7CmAnP7YPLy9Q1yJWjCWikbzJETBW0QUf5c5p+9Nbext JA== 
Received: from userp3030.oracle.com (userp3030.oracle.com [156.151.31.80])
        by aserp2120.oracle.com with ESMTP id 2rj0dnje9p-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 02 Apr 2019 17:33:13 +0000
Received: from pps.filterd (userp3030.oracle.com [127.0.0.1])
        by userp3030.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x32HRhUc135829;
        Tue, 2 Apr 2019 17:29:12 GMT
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by userp3030.oracle.com with ESMTP id 2rm8f4muyv-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 02 Apr 2019 17:29:12 +0000
Received: from abhmp0001.oracle.com (abhmp0001.oracle.com [141.146.116.7])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x32HTB4m002534;
        Tue, 2 Apr 2019 17:29:11 GMT
Received: from bradley.us.oracle.com (/10.152.12.111)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 02 Apr 2019 10:29:11 -0700
Subject: Re: directory delegations
From:   "Bradley C. Kuszmaul" <bradley.kuszmaul@oracle.com>
To:     "J. Bruce Fields" <bfields@fieldses.org>
Cc:     linux-nfs@vger.kernel.org
References: <2065755c-f888-9c62-f6e5-f143d42c51ee@oracle.com>
 <20190402161116.GA2828@fieldses.org>
 <2f1f6582-3672-1361-4392-80cb1e62e19c@oracle.com>
Message-ID: <03576c76-abca-9e3c-bf58-5a2a22e8f999@oracle.com>
Date:   Tue, 2 Apr 2019 13:29:10 -0400
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <2f1f6582-3672-1361-4392-80cb1e62e19c@oracle.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Content-Language: en-US
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1904020116
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9215 signatures=668685
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 lowpriorityscore=0
 mlxlogscore=999 adultscore=0 classifier=spam adjust=0 reason=mlx
 scancount=1 engine=8.0.1-1810050000 definitions=main-1904020116
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I stand corrected.  Apparently there is no LOOKUP, so maybe read-only 
directory delegations don't help at all with untar.

-Bradley

On 4/2/19 1:26 PM, Bradley C. Kuszmaul wrote:
> My simple model of metadata operations is to untar something like the 
> linux sources.
>
> Each file incurs a LOOKUP, CREATE, SETATTR, and WRITE, each of which 
> is fairly high latency (even the WRITE ends up being done essentially 
> synchronously because tar closes the file after its write(2) call.)
>
> I guess directory delegations might save the cost of LOOKUP.
>
> Is there any hope for getting write delegations?
>
> What other steps might be possible?
>
> -Bradley
>
> On 4/2/19 12:11 PM, bfields@fieldses.org wrote:
>> On Mon, Apr 01, 2019 at 12:21:49PM -0400, Bradley C. Kuszmaul wrote:
>>> Hi, I'm the architect for Oracle's File Storage Service.   FSS is
>>> basically a big scalable NFS server that runs in Oracle's cloud.
>>>
>>> Our metadata operations have higher latency than a vanilla NFS
>>> server (e.g., a Linux NFS server serving a XFS stored on a block
>>> device), and we suspect that directory delegations would make a big
>>> performance improvement.
>>>
>>> I understand, however, that essentially no one implements directory
>>> delegations.
>>>
>>> Can anyone fill me in on the current thinking of the future of
>>> support for directory delegations in the Linux NFS client?
>> Maybe somebody else will speak up, but I don't know of any effort to
>> implement directory delegations.
>>
>> What metadata operations specifically are you worried about? The
>> directory delegations that are specified in RFC 5661 are read-only.
>> Which might explain some of the lack of interest.
>>
>> But there may be other steps that we could take to improve matters.
>>
>> --b.
