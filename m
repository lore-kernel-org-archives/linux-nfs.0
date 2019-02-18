Return-Path: <SRS0=QdOa=QZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 96664C4360F
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 18:23:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 69EB62146E
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 18:23:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="UoIBurwa"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2389892AbfBRSXe (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Feb 2019 13:23:34 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:52708 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1732719AbfBRSXd (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2019 13:23:33 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1IIJKSk048192;
        Mon, 18 Feb 2019 18:23:26 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=GpB5pmucKi3umRyKJXejlXF1NPujWeH9ZbuWAwvoiN4=;
 b=UoIBurwa0/sA9SPWypgK1LcAZXEblZUOc8lU+BusFwt6/EnzCm1eTsur5E1/bRumPd0g
 9TCqbOyjYeu3hdtpGB7rhi+eswJbc0GTrFC2cvsr0GMo3Xo1xPQspqSgnbNzz48p7U+G
 iXITga1/J0t9OOt2ZaQDwLB24GFEmjh0JG+M++uEZIV9hAlt7U/ZlC6ToJPra5psh+gT
 SJoPa85ZJMZNqHK9rzEqf7KsLEWt7oHqNFy7XXCg4AKmiOSBACqKpl/rZ7vcodtVeGO2
 SODYfiQSNHDtVH2KKDsj5/AXYNVmY5/CL/TwforXTp9d6lfxuyRScY38xVgsMlJDG0i3 NA== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by userp2120.oracle.com with ESMTP id 2qpb5r7bhn-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 18 Feb 2019 18:23:26 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1IINPqM003018
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 18 Feb 2019 18:23:25 GMT
Received: from abhmp0002.oracle.com (abhmp0002.oracle.com [141.146.116.8])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id x1IINOUY014267;
        Mon, 18 Feb 2019 18:23:25 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 18 Feb 2019 10:23:24 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH] nfs-utils: fix addrinfo usage with musl-1.1.21
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <530ec927-e9c6-490c-1382-8e5be1aea203@RedHat.com>
Date:   Mon, 18 Feb 2019 13:23:23 -0500
Cc:     Peter Wagner <tripolar@gmx.at>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <0B1E18B0-0034-4612-B63B-41155D2E0D64@oracle.com>
References: <20190217173901.33296254@onion.lan>
 <1081BBCD-8CA0-49CC-A02C-16F46FF613BF@oracle.com>
 <20190218001153.3d21b28c@onion.lan>
 <34D9E70A-7F29-4C6B-8A10-18F7A7EFFE2E@oracle.com>
 <137b8db8-a6d6-33a6-408b-73f8915eee08@RedHat.com>
 <EE3790BC-A5B4-4C34-9F21-7009579B3A25@oracle.com>
 <530ec927-e9c6-490c-1382-8e5be1aea203@RedHat.com>
To:     Steve Dickson <SteveD@RedHat.com>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9171 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=2 phishscore=0 bulkscore=0 spamscore=0 clxscore=1015
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=913 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902180135
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 18, 2019, at 12:59 PM, Steve Dickson <SteveD@RedHat.com> wrote:
> 
> 
> On 2/18/19 12:00 PM, Chuck Lever wrote:
>>> I also took a look at how freeaddrinfo(3) in glibc works:
>>> 
>>> void
>>> freeaddrinfo (struct addrinfo *ai)
>>> {
>>> struct addrinfo *p;
>>> 
>>> while (ai != NULL)
>>>   {
>>>     p = ai;
>>>     ai = ai->ai_next;
>>>     free (p->ai_canonname);
>>>     free (p);
>>>   }
>>> }
>>> It makes the assumption that ai_canonname is
>>> free-able memory....
>> Right, I seem to recall looking at this implementation when
>> I wrote the IPv6 support for nfs-utils. That seems sensible
>> to me.
>> 
>> However Peter's point is not all C libraries have to work
>> that way, and I can see that argument too.
> I agreed.... 
>> 
>> I have no objection to taking his fix as long as the hunk
>> in host_numeric_addrinfo() is dropped while we figure out
>> a more complete fix for that issue. 
> Taking it out I can see us getting flagged for possible memory leaking....

Exactly, with glibc C, that memory will leak if it's not freed
there.

We need a different solution here that works with all C libraries.
If Peter agrees, I'll volunteer to have a look at this.


> Taking a look to why those frees were add... see commit 94ce1eb9
> They should look very familiar to you ;-)  
> 
>> I would also like to
>> see his fix use a helper like nfs_freeaddrinfo(), but that
>> is only a suggestion.
> That is a good suggestion... It definitely cleans up the code.
> 
> steved. 
>> 
>> 

--
Chuck Lever



