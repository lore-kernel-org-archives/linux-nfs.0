Return-Path: <SRS0=VOvP=NG=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.3 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8175FC6786E
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 15:04:46 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 459FF2082B
	for <linux-nfs@archiver.kernel.org>; Fri, 26 Oct 2018 15:04:46 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="kn0NDEDc"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 459FF2082B
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726295AbeJZXmK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Oct 2018 19:42:10 -0400
Received: from aserp2120.oracle.com ([141.146.126.78]:57732 "EHLO
        aserp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726159AbeJZXmK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Oct 2018 19:42:10 -0400
Received: from pps.filterd (aserp2120.oracle.com [127.0.0.1])
        by aserp2120.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w9QEwYic147793;
        Fri, 26 Oct 2018 15:04:20 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=z+GaL3hXg527N04C8tT45jCCiCY7JsdvhCXtWfy0cak=;
 b=kn0NDEDcXsKmirRS6fxwXBVCn/i0eaBvZ7HYCUWJlgi4GPDlAxf+gKl3Jas5r/3O6B6o
 4b01poXwJlmBfMcH7hdDzYjgrAVptepqIpa+OfQWN25g+cSqh0Qllu1qoSABiX0ff95U
 TYiC1u/pZ2LhJPOuKl0kaMrcE6CFKl/zM/zQLY56xSlyusCoQfj9ro5H9U2zpuzSK+Jc
 3Nq2gEkcUaZDzIinTQAMppeRjBOV7QJQG+vvYr6U2f5f1OVGtkHB8xFg5A/LLXpmJxip
 o8lBbG7Y1V7vDOZfQVwvIAgwcxaoPQmIO9OGJSlA4/AlwpJ05mqnm2t8OfwVC/g6BDnN Sw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by aserp2120.oracle.com with ESMTP id 2n7vaqfry3-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 26 Oct 2018 15:04:20 +0000
Received: from userv0122.oracle.com (userv0122.oracle.com [156.151.31.75])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id w9QF4Js0001632
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 26 Oct 2018 15:04:19 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
        by userv0122.oracle.com (8.14.4/8.14.4) with ESMTP id w9QF4JPx021506;
        Fri, 26 Oct 2018 15:04:19 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 26 Oct 2018 08:04:18 -0700
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: copy offload support and absent file system
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <CAN-5tyEn+mM8ucuPXawN9L57XyGHUQHNL6Ddic5TFdXYTY2bSg@mail.gmail.com>
Date:   Fri, 26 Oct 2018 11:04:17 -0400
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: 7bit
Message-Id: <6CA0FBE4-6B7C-4D05-BE1E-AB3BEDD90171@oracle.com>
References: <CAN-5tyEn+mM8ucuPXawN9L57XyGHUQHNL6Ddic5TFdXYTY2bSg@mail.gmail.com>
To:     Olga Kornievskaia <aglo@umich.edu>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9057 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=999
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1807170000 definitions=main-1810260128
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Oct 26, 2018, at 8:54 AM, Olga Kornievskaia <aglo@umich.edu> wrote:
> 
> Hi Chuck,
> 
> In the context of doing a copy between different "types" of
> filesystems, it was pointed out to me that NFS has many types:
> nfs4_fs_type, nfs4_remote_fs_type, nfs4_remote_referral_fs_type,
> nfs4_referral_fs_type. So doing a simple check that fs type of "in"
> and "out" might not be sufficient. Do you see any issues allowing a
> copy offload between different types? Basically checking that "in" and
> "out" descriptions come from any of the these types?

I'm no expert... so what follows is an uninformed opinion.

All of these are NFSv4 file systems. But I don't think that's an
adequate check (it's necessary, but not sufficient).

The minor version of the mount point has to be 2 or higher, and
the client must confirm that the mounted server supports copy
offload (because all NFSv4.2 features are OPTIONAL).


--
Chuck Lever



