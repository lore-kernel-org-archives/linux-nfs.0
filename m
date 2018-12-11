Return-Path: <SRS0=OjhL=OU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-7.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0696CC67839
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 19:12:32 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C3A4F20880
	for <linux-nfs@archiver.kernel.org>; Tue, 11 Dec 2018 19:12:31 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="rW4RspHo"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C3A4F20880
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726434AbeLKTMa (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 11 Dec 2018 14:12:30 -0500
Received: from aserp2130.oracle.com ([141.146.126.79]:57054 "EHLO
        aserp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727054AbeLKTM0 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 11 Dec 2018 14:12:26 -0500
Received: from pps.filterd (aserp2130.oracle.com [127.0.0.1])
        by aserp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wBBJ9MJY054723;
        Tue, 11 Dec 2018 19:12:23 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=DdA+5d3X+bXm2ciincug7PtSv7xvqNp9VhxMR2VL9nY=;
 b=rW4RspHoWUYyfpFDHjMZNnYSilMULEjUhO8M7VDtOUh9ZUzXQIOxvc+f0hbXbngDlHZL
 lNTcmrU1qVty1Z7sMfC7+NVkbORT7zY9hQlphDo4wKcPlnhQbvoAmgmrI53wNiMobK+k
 OoV9vYxrlhbFJwmHQM94rlVadIpdN7VXz8ysnHhYcvAHusGHXut/JWj3QC/gdr6//fKs
 +mKiX2Vzm/1Vud4FimGBghyDtVxZfShtqkg6bEmPUfRNP1ZoHwp3gWmWnm5bH/UAw09d
 FIsnu7Kjxe8Nd+kJmSJhPAcGhjahy240AjEn6GaeK+2qaQZy9shknl6kh8j0sInOnZhI qg== 
Received: from aserv0021.oracle.com (aserv0021.oracle.com [141.146.126.233])
        by aserp2130.oracle.com with ESMTP id 2p83fe5yqu-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 11 Dec 2018 19:12:23 +0000
Received: from aserv0122.oracle.com (aserv0122.oracle.com [141.146.126.236])
        by aserv0021.oracle.com (8.14.4/8.14.4) with ESMTP id wBBJCHCG004633
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Tue, 11 Dec 2018 19:12:17 GMT
Received: from abhmp0008.oracle.com (abhmp0008.oracle.com [141.146.116.14])
        by aserv0122.oracle.com (8.14.4/8.14.4) with ESMTP id wBBJCHlm025894;
        Tue, 11 Dec 2018 19:12:17 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Tue, 11 Dec 2018 11:12:17 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH] nfsref: switch the way libraries are linked.
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20181211190944.71940-1-steved@redhat.com>
Date:   Tue, 11 Dec 2018 14:12:16 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <0F088877-F56A-47FF-BBF3-95A8293BF912@oracle.com>
References: <20181211190944.71940-1-steved@redhat.com>
To:     Steve Dickson <steved@redhat.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9103 signatures=668679
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=794
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1812110170
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org


> On Dec 11, 2018, at 2:09 PM, Steve Dickson <steved@redhat.com> wrote:
> 
> Link the static libs before the dynamic libs allowing
> the routines in the static libs to be defined
> by the dynamic libs

Hi Steve, Why is this change necessary? Is there a bug report?


> Signed-off-by: Steve Dickson <steved@redhat.com>
> ---
> utils/nfsref/Makefile.am | 6 +++---
> 1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/utils/nfsref/Makefile.am b/utils/nfsref/Makefile.am
> index 44edc83..2409dd0 100644
> --- a/utils/nfsref/Makefile.am
> +++ b/utils/nfsref/Makefile.am
> @@ -27,9 +27,9 @@ noinst_HEADERS		= nfsref.h
> 
> sbin_PROGRAMS		= nfsref
> nfsref_SOURCES		= add.c lookup.c nfsref.c remove.c
> -LDADD			= $(LIBXML2) $(LIBCAP) \
> -			  ../../support/nfs/libnfs.la \
> -			  ../../support/junction/libjunction.la
> +LDADD			= ../../support/nfs/libnfs.la \
> +			  ../../support/junction/libjunction.la \
> +			  $(LIBXML2) $(LIBCAP)
> 
> man8_MANS		= nfsref.man
> 
> -- 
> 2.19.2
> 

--
Chuck Lever



