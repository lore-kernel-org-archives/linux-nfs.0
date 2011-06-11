Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:62916 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751690Ab1FKVKm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 11 Jun 2011 17:10:42 -0400
Received: by iwn34 with SMTP id 34so2965328iwn.19
        for <linux-nfs@vger.kernel.org>; Sat, 11 Jun 2011 14:10:42 -0700 (PDT)
From: Benny Halevy <benny@tonian.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <benny@tonian.com>
Subject: [PATCH] NFSv4.1: deprecate headerpadsz in CREATE_SESSION
Date: Sat, 11 Jun 2011 17:08:39 -0400
Message-Id: <1307826519-2601-1-git-send-email-benny@tonian.com>
In-Reply-To: <1307753547.3421.6.camel@lade.trondhjem.org>
References: <1307753547.3421.6.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

We don't support header padding yet so better off ditching it

Reported-by: Sid Moore <learnmost@gmail.com>
Signed-off-by: Benny Halevy <benny@tonian.com>
---
 fs/nfs/nfs4proc.c       |    4 ----
 fs/nfs/nfs4xdr.c        |   10 ++++++----
 include/linux/nfs_xdr.h |    1 -
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index d2c4b59..3ca4497 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5098,7 +5098,6 @@ static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
 	if (mxresp_sz == 0)
 		mxresp_sz = NFS_MAX_FILE_IO_SIZE;
 	/* Fore channel attributes */
-	args->fc_attrs.headerpadsz = 0;
 	args->fc_attrs.max_rqst_sz = mxrqst_sz;
 	args->fc_attrs.max_resp_sz = mxresp_sz;
 	args->fc_attrs.max_ops = NFS4_MAX_OPS;
@@ -5111,7 +5110,6 @@ static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
 		args->fc_attrs.max_ops, args->fc_attrs.max_reqs);
 
 	/* Back channel attributes */
-	args->bc_attrs.headerpadsz = 0;
 	args->bc_attrs.max_rqst_sz = PAGE_SIZE;
 	args->bc_attrs.max_resp_sz = PAGE_SIZE;
 	args->bc_attrs.max_resp_sz_cached = 0;
@@ -5131,8 +5129,6 @@ static int nfs4_verify_fore_channel_attrs(struct nfs41_create_session_args *args
 	struct nfs4_channel_attrs *sent = &args->fc_attrs;
 	struct nfs4_channel_attrs *rcvd = &session->fc_attrs;
 
-	if (rcvd->headerpadsz > sent->headerpadsz)
-		return -EINVAL;
 	if (rcvd->max_resp_sz > sent->max_resp_sz)
 		return -EINVAL;
 	/*
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index d869a5e..c4b7d6c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1725,7 +1725,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(args->flags);			/*flags */
 
 	/* Fore Channel */
-	*p++ = cpu_to_be32(args->fc_attrs.headerpadsz);	/* header padding size */
+	*p++ = cpu_to_be32(0);				/* header padding size */
 	*p++ = cpu_to_be32(args->fc_attrs.max_rqst_sz);	/* max req size */
 	*p++ = cpu_to_be32(args->fc_attrs.max_resp_sz);	/* max resp size */
 	*p++ = cpu_to_be32(max_resp_sz_cached);		/* Max resp sz cached */
@@ -1734,7 +1734,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(0);				/* rdmachannel_attrs */
 
 	/* Back Channel */
-	*p++ = cpu_to_be32(args->fc_attrs.headerpadsz);	/* header padding size */
+	*p++ = cpu_to_be32(0);				/* header padding size */
 	*p++ = cpu_to_be32(args->bc_attrs.max_rqst_sz);	/* max req size */
 	*p++ = cpu_to_be32(args->bc_attrs.max_resp_sz);	/* max resp size */
 	*p++ = cpu_to_be32(args->bc_attrs.max_resp_sz_cached);	/* Max resp sz cached */
@@ -4997,12 +4997,14 @@ static int decode_chan_attrs(struct xdr_stream *xdr,
 			     struct nfs4_channel_attrs *attrs)
 {
 	__be32 *p;
-	u32 nr_attrs;
+	u32 nr_attrs, val;
 
 	p = xdr_inline_decode(xdr, 28);
 	if (unlikely(!p))
 		goto out_overflow;
-	attrs->headerpadsz = be32_to_cpup(p++);
+	val = be32_to_cpup(p++);	/* headerpadsz */
+	if (val)
+		return -EINVAL;		/* no support for header padding yet */
 	attrs->max_rqst_sz = be32_to_cpup(p++);
 	attrs->max_resp_sz = be32_to_cpup(p++);
 	attrs->max_resp_sz_cached = be32_to_cpup(p++);
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 5e8444a..00848d8 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -158,7 +158,6 @@ struct nfs_seqid;
 
 /* nfs41 sessions channel attributes */
 struct nfs4_channel_attrs {
-	u32			headerpadsz;
 	u32			max_rqst_sz;
 	u32			max_resp_sz;
 	u32			max_resp_sz_cached;
-- 
1.7.4.4

