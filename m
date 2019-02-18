Return-Path: <SRS0=QdOa=QZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.2 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,
	SPF_PASS,UNPARSEABLE_RELAY autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 251B5C10F01
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 19:41:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id EBD662177E
	for <linux-nfs@archiver.kernel.org>; Mon, 18 Feb 2019 19:41:34 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=oracle.com header.i=@oracle.com header.b="fUcLxpQw"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725805AbfBRTle (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 18 Feb 2019 14:41:34 -0500
Received: from userp2120.oracle.com ([156.151.31.85]:44430 "EHLO
        userp2120.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725535AbfBRTld (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Feb 2019 14:41:33 -0500
Received: from pps.filterd (userp2120.oracle.com [127.0.0.1])
        by userp2120.oracle.com (8.16.0.27/8.16.0.27) with SMTP id x1IJclRK104759;
        Mon, 18 Feb 2019 19:41:31 GMT
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=oracle.com; h=content-type :
 mime-version : subject : from : in-reply-to : date : cc :
 content-transfer-encoding : message-id : references : to;
 s=corp-2018-07-02; bh=fs8KALZTYTgQcHLZoWnshX8BqSWVaX+GPIfDF9zpmE0=;
 b=fUcLxpQw1wl3tOwFbRm5dNR383eKRViAUPxkQ3kPOIHxy9fmj4/QaHfAzt2psDqqPUrB
 ALxYPZ4EYBeo/MFCROCEqXxIZdXwCTKEIZ2X12fbfQrkgJ0mK5ifiLSZ/iB44pMlrUgg
 N7a8e8TLdm6sHTYUhTxbXtdQc+Kt0c0StQKS7RGPKyq2APnLmIO2EuORhCxi/JV5P68Z
 NmXdW2PYw1BNbxUZhg1R/WUFCC+jLT+3d/ny4CufM5M5zNbcoqwR6WyTnuk/83niDpuQ
 kjFau3BfQag/JgJLsQb0XinUFdwEkyAZhwEcwO78URHe1LP4FhXv8yNgwgYkYW1kBJ0U SA== 
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
        by userp2120.oracle.com with ESMTP id 2qpb5r7ja6-1
        (version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 18 Feb 2019 19:41:31 +0000
Received: from userv0121.oracle.com (userv0121.oracle.com [156.151.31.72])
        by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id x1IJfPJa021770
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK);
        Mon, 18 Feb 2019 19:41:25 GMT
Received: from abhmp0014.oracle.com (abhmp0014.oracle.com [141.146.116.20])
        by userv0121.oracle.com (8.14.4/8.13.8) with ESMTP id x1IJfP9g016235;
        Mon, 18 Feb 2019 19:41:25 GMT
Received: from anon-dhcp-171.1015granger.net (/68.61.232.219)
        by default (Oracle Beehive Gateway v4.0)
        with ESMTP ; Mon, 18 Feb 2019 11:41:25 -0800
Content-Type: text/plain;
        charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 12.2 \(3445.102.3\))
Subject: Re: [PATCH RFC 4/4] NFSD: Prototype support for IMA on NFS (server)
From:   Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <20190218193218.GA5879@fieldses.org>
Date:   Mon, 18 Feb 2019 14:41:24 -0500
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        linux-integrity@vger.kernel.org
Content-Transfer-Encoding: 7bit
Message-Id: <A7D59BDC-08B3-4338-8E3B-6B41AC652968@oracle.com>
References: <20190214203336.6469.34750.stgit@manet.1015granger.net>
 <20190214204326.6469.25843.stgit@manet.1015granger.net>
 <20190218193218.GA5879@fieldses.org>
To:     Bruce Fields <bfields@fieldses.org>
X-Mailer: Apple Mail (2.3445.102.3)
X-Proofpoint-Virus-Version: vendor=nai engine=5900 definitions=9171 signatures=668683
X-Proofpoint-Spam-Details: rule=notspam policy=default score=0 priorityscore=1501 malwarescore=0
 suspectscore=0 phishscore=0 bulkscore=0 spamscore=0 clxscore=1011
 lowpriorityscore=0 mlxscore=0 impostorscore=0 mlxlogscore=999 adultscore=0
 classifier=spam adjust=0 reason=mlx scancount=1 engine=8.0.1-1810050000
 definitions=main-1902180146
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org



> On Feb 18, 2019, at 2:32 PM, bfields@fieldses.org wrote:
> 
> On Thu, Feb 14, 2019 at 03:43:26PM -0500, Chuck Lever wrote:
>> When NFSv4 Security Label support is enabled and kernel Integrity
>> and IMA support is enabled (via CONFIG), then build in code to
>> handle the "security.ima" xattr. The NFS server converts incoming
>> GETATTR and SETATTR calls to acesses and updates of the xattr.
>> 
>> The FATTR4 bit is made up; meaning we still have to go through a
>> standards process to allocate a bit that all NFS vendors agree on.
>> Thus there is no guarantee this prototype will interoperate with
>> others or with a future standards-based implementation.
> 
> Why the dependence on CONFIG_NFSD_V4_SECURITY_LABEL?

Hrm, well there is some mechanism on the client side that IMA
needs that is behind CONFIG_NFS_V4_SECURITY_LABEL. I guess I
didn't think about not doing the same thing on the server. It
may just be an artifact of an earlier version of this code.


> (Also, I wonder if we actually need CONFIG_NFSD_V4_SECURITY_LABEL or if
> we could just remove it, or replace it by CONFIG_SECURITY where
> necessary.)

On the server, there is already a (run-time) export option to
enable and disable security labels. Is there a reason a
distribution would want to disable client or server support
for security labels at build time?

--
Chuck Lever



