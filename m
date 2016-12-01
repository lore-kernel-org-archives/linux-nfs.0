Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f194.google.com ([209.85.223.194]:35099 "EHLO
        mail-io0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759814AbcLAWTj (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Dec 2016 17:19:39 -0500
Received: by mail-io0-f194.google.com with SMTP id h133so4681125ioe.2
        for <linux-nfs@vger.kernel.org>; Thu, 01 Dec 2016 14:19:39 -0800 (PST)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 15/26] NFSv4: Fix missing operation accounting in NFS4_dec_delegreturn_sz
Date: Thu,  1 Dec 2016 17:19:11 -0500
Message-Id: <20161201221922.15657-16-trond.myklebust@primarydata.com>
In-Reply-To: <20161201221922.15657-15-trond.myklebust@primarydata.com>
References: <20161201221922.15657-1-trond.myklebust@primarydata.com>
 <20161201221922.15657-2-trond.myklebust@primarydata.com>
 <20161201221922.15657-3-trond.myklebust@primarydata.com>
 <20161201221922.15657-4-trond.myklebust@primarydata.com>
 <20161201221922.15657-5-trond.myklebust@primarydata.com>
 <20161201221922.15657-6-trond.myklebust@primarydata.com>
 <20161201221922.15657-7-trond.myklebust@primarydata.com>
 <20161201221922.15657-8-trond.myklebust@primarydata.com>
 <20161201221922.15657-9-trond.myklebust@primarydata.com>
 <20161201221922.15657-10-trond.myklebust@primarydata.com>
 <20161201221922.15657-11-trond.myklebust@primarydata.com>
 <20161201221922.15657-12-trond.myklebust@primarydata.com>
 <20161201221922.15657-13-trond.myklebust@primarydata.com>
 <20161201221922.15657-14-trond.myklebust@primarydata.com>
 <20161201221922.15657-15-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We need to account for the reply to the PUTFH operation in the
DELEGRETURN compound.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/nfs4xdr.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 86f72ae605c8..0a82b3fb2d27 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -710,6 +710,7 @@ static int nfs4_stat_to_errno(int);
 				encode_getattr_maxsz)
 #define NFS4_dec_delegreturn_sz (compound_decode_hdr_maxsz + \
 				decode_sequence_maxsz + \
+				decode_putfh_maxsz + \
 				decode_delegreturn_maxsz + \
 				decode_getattr_maxsz)
 #define NFS4_enc_getacl_sz	(compound_encode_hdr_maxsz + \
-- 
2.9.3

