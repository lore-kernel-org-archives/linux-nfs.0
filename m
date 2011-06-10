Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60026 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756617Ab1FJTzR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jun 2011 15:55:17 -0400
Received: by iwn34 with SMTP id 34so2430663iwn.19
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jun 2011 12:55:16 -0700 (PDT)
Message-ID: <4DF276A0.6080504@tonian.com>
Date: Fri, 10 Jun 2011 15:55:12 -0400
From: Benny Halevy <benny@tonian.com>
To: Sid Moore <learnmost@gmail.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [patch 1/1]: fix bug in CREATE_SESSION encoding
References: <BANLkTikv_vi7eR8Xu-_K5F5D5Smrj=goog@mail.gmail.com>
In-Reply-To: <BANLkTikv_vi7eR8Xu-_K5F5D5Smrj=goog@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-06-10 02:32, Sid Moore wrote:
> Hi
> 
> I think it might be an error when typing. see the patch below.
> 
> 
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -1772,7 +1772,7 @@ static void encode_create_session(struct xdr_stream *xdr,
>         *p++ = cpu_to_be32(0);                          /* rdmachannel_attrs */
> 
>         /* Back Channel */
> -       *p++ = cpu_to_be32(args->fc_attrs.headerpadsz); /* header
> padding size */
> +       *p++ = cpu_to_be32(args->bc_attrs.headerpadsz); /* header
> padding size */
>         *p++ = cpu_to_be32(args->bc_attrs.max_rqst_sz); /* max req size */
>         *p++ = cpu_to_be32(args->bc_attrs.max_resp_sz); /* max resp size */
>         *p++ = cpu_to_be32(args->bc_attrs.max_resp_sz_cached);  /* Max
> resp sz cached */
> 
> --
> Sid
> --

Thanks for spotting this!
Since we don't support header padding yet the following patch
might be more appropriate.
Trond, what do you think?

Benny

git diff --stat -p -M
 fs/nfs/nfs4proc.c       |    4 ----
 fs/nfs/nfs4xdr.c        |   10 ++++++----
 include/linux/nfs_xdr.h |    1 -
 3 files changed, 6 insertions(+), 9 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 987260c..e7ef0b1 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -5099,7 +5099,6 @@ static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
 	if (mxresp_sz == 0)
 		mxresp_sz = NFS_MAX_FILE_IO_SIZE;
 	/* Fore channel attributes */
-	args->fc_attrs.headerpadsz = 0;
 	args->fc_attrs.max_rqst_sz = mxrqst_sz;
 	args->fc_attrs.max_resp_sz = mxresp_sz;
 	args->fc_attrs.max_ops = NFS4_MAX_OPS;
@@ -5112,7 +5111,6 @@ static void nfs4_init_channel_attrs(struct nfs41_create_session_args *args)
 		args->fc_attrs.max_ops, args->fc_attrs.max_reqs);

 	/* Back channel attributes */
-	args->bc_attrs.headerpadsz = 0;
 	args->bc_attrs.max_rqst_sz = PAGE_SIZE;
 	args->bc_attrs.max_resp_sz = PAGE_SIZE;
 	args->bc_attrs.max_resp_sz_cached = 0;
@@ -5132,8 +5130,6 @@ static int nfs4_verify_fore_channel_attrs(struct nfs41_create_session_args *args
 	struct nfs4_channel_attrs *sent = &args->fc_attrs;
 	struct nfs4_channel_attrs *rcvd = &session->fc_attrs;

-	if (rcvd->headerpadsz > sent->headerpadsz)
-		return -EINVAL;
 	if (rcvd->max_resp_sz > sent->max_resp_sz)
 		return -EINVAL;
 	/*
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 73f18f4..7afc8df 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1780,7 +1780,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(args->flags);			/*flags */

 	/* Fore Channel */
-	*p++ = cpu_to_be32(args->fc_attrs.headerpadsz);	/* header padding size */
+	*p++ = cpu_to_be32(0);				/* header padding size */
 	*p++ = cpu_to_be32(args->fc_attrs.max_rqst_sz);	/* max req size */
 	*p++ = cpu_to_be32(args->fc_attrs.max_resp_sz);	/* max resp size */
 	*p++ = cpu_to_be32(max_resp_sz_cached);		/* Max resp sz cached */
@@ -1789,7 +1789,7 @@ static void encode_create_session(struct xdr_stream *xdr,
 	*p++ = cpu_to_be32(0);				/* rdmachannel_attrs */

 	/* Back Channel */
-	*p++ = cpu_to_be32(args->fc_attrs.headerpadsz);	/* header padding size */
+	*p++ = cpu_to_be32(0);				/* header padding size */
 	*p++ = cpu_to_be32(args->bc_attrs.max_rqst_sz);	/* max req size */
 	*p++ = cpu_to_be32(args->bc_attrs.max_resp_sz);	/* max resp size */
 	*p++ = cpu_to_be32(args->bc_attrs.max_resp_sz_cached);	/* Max resp sz cached */
@@ -5119,12 +5119,14 @@ static int decode_chan_attrs(struct xdr_stream *xdr,
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
index d1f9c27..0a21844 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -161,7 +161,6 @@ struct nfs_seqid;

 /* nfs41 sessions channel attributes */
 struct nfs4_channel_attrs {
-	u32			headerpadsz;
 	u32			max_rqst_sz;
 	u32			max_resp_sz;
 	u32			max_resp_sz_cached;
