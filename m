Return-Path: <SRS0=T1LL=OJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-2.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY,URIBL_BLOCKED autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3D9FFC04EB8
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:39:01 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id F2848206B7
	for <linux-nfs@archiver.kernel.org>; Fri, 30 Nov 2018 21:39:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="VEQWSwAm"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2848206B7
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=oracle.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726512AbeLAItj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sat, 1 Dec 2018 03:49:39 -0500
Received: from userp2130.oracle.com ([156.151.31.86]:55764 "EHLO
        userp2130.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725941AbeLAItj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 1 Dec 2018 03:49:39 -0500
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
        by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id wAULXtPY162474;
        Fri, 30 Nov 2018 21:38:57 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=yCbuYREvZTrIrB45cgPvEzfe/fcv9/wLAdY4DdO519A=;
 b=VEQWSwAmWtk5yknYdSkLyK8MvAmDt9RqiFXySiRqNbXlwNOZI9xKEvqsGn09VHIww5M9
 ASv8ictWD+6p05N0Pcr/lqjCBY/QoE91QGBh2HXYuGkfP2pBdePB0M/aE7mWK/6jXtge
 7mcAtlW+r6lgtIPg+/jaFU1JLMKpS4act/ok2of1aX+8HtQ7cyqOxK302LRZV3FHyNh7
 rn4PtIg2sZznzYPBSngQDJvk2nuLyR+9KGhEEcyRYAWdGJb56cjnONY0PTkyInNjWm1w
 jbZ4Y1lbuvx3ejooOpIPQQfFbDBoas92+WmbmvgKD/y5VNZqn4C+j7yiHEWHYJG9PWcI tw== 
Received: from aserv0022.oracle.com (aserv0022.oracle.com [141.146.126.234])
        by userp2130.oracle.com with ESMTP id 2p2jf0qt13-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 30 Nov 2018 21:38:57 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by aserv0022.oracle.com (8.14.4/8.14.4) with ESMTP id wAULcoR7021420
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Fri, 30 Nov 2018 21:38:51 GMT
Received: from abhmp0007.oracle.com (abhmp0007.oracle.com [141.146.116.13])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id wAULcogK004876;
        Fri, 30 Nov 2018 21:38:50 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Fri, 30 Nov 2018 13:38:50 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 11.5 \(3445.9.1\))
Subject: Re: [PATCH v2 3/3] SUNRPC: Ensure we refresh the bvec after
 RPCSEC_GSS encoding
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <14e5c2ae4982304c17df6903e9829289d0f44c93.camel@hammerspace.com>
Date:   Fri, 30 Nov 2018 16:38:49 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Transfer-Encoding: quoted-printable
Message-Id: <81D0C171-A020-4135-9633-BBB8E8DC33BB@oracle.com>
References: <20181130211846.89000-1-trond.myklebust@hammerspace.com>
 <20181130211846.89000-2-trond.myklebust@hammerspace.com>
 <20181130211846.89000-3-trond.myklebust@hammerspace.com>
 <9D04832A-FC88-409C-8742-CBF742B6CB4A@oracle.com>
 <eaa3259a1aa12e29b8bd824f7cd417d6346239f9.camel@gmail.com>
 <93C4273C-DBBD-4B75-9F1F-EB103F2F430A@oracle.com>
 <14e5c2ae4982304c17df6903e9829289d0f44c93.camel@hammerspace.com>
To:     Trond Myklebust <trondmy@hammerspace.com>
X-Mailer: Apple Mail (2.3445.9.1)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9093 signatures=668686
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 suspectscore=0 malwarescore=0
 phishscore=0 bulkscore=0 spamscore=0 mlxscore=0 mlxlogscore=563
 adultscore=0 classifier=spam adjust=0 reason=mlx scancount=1
 engine=8.0.1-1810050000 definitions=main-1811300183
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Nov 30, 2018, at 4:37 PM, Trond Myklebust <trondmy@hammerspace.com> =
wrote:
>=20
> On Fri, 2018-11-30 at 16:32 -0500, Chuck Lever wrote:
>>>=20
>> I actually had a patch that looked exactly like yours (except for the
>> description text). It didn't seem to do anything. So there may be an
>> issue here, but I don't believe I'm seeing it with my reproducer.
>>=20
>=20
> Argh... Yes, I was too quick off the trigger. The call to
> xdr_buf_init() in rpc_xdr_encode() will actually clobber the ->bvec
> array...

Duh. That sounds very plausible!


--
Chuck Lever



