From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 02/47] sunrpc: add cl_private field to struct rpc_clnt
Date: Sat, 28 Mar 2009 22:26:44 +0300
Message-ID: <49CE79F4.1060106@panasas.com>
References: <49CC40E5.2080506@panasas.com>	 <1238122908-6967-1-git-send-email-bhalevy@panasas.com>	 <20090328000552.GJ18222@fieldses.org>	 <E166DD1F-96CC-4F61-B215-7CE5FCEF20C4@netapp.com>	 <49CDDDBB.9060706@panasas.com>	 <1238261035.6679.4.camel@heimdal.trondhjem.org>	 <49CE5E6D.7080806@panasas.com> <1238261753.6679.13.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:17411 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757844AbZC1T2U (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 15:28:20 -0400
In-Reply-To: <1238261753.6679.13.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mar. 28, 2009, 20:35 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> On Sat, 2009-03-28 at 20:29 +0300, Benny Halevy wrote:
>> On Mar. 28, 2009, 20:23 +0300, Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
>>> On Sat, 2009-03-28 at 11:20 +0300, Benny Halevy wrote:
>>>> On Mar. 28, 2009, 3:39 +0300, "Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:
>>>>> On Mar 27, 2009, at 8:06 PM, "J. Bruce Fields" <bfields@fieldses.org>  
>>>>> wrote:
>>>>>
>>>>>> On Fri, Mar 27, 2009 at 06:01:48AM +0300, Benny Halevy wrote:
>>>>>>> From: Andy Adamson <andros@netapp.com>
>>>>>>>
>>>>>>> Note: the NFSv4.1 client also uses (and declares) this pointer.
>>>>>> OK.  Ack from trond?
>>>>> First, someone would need to remind me why it is necessary, and add  
>>>>> that justification to the changelog.
>>>> First time this is used in this patchset is here:
>>>> [PATCH 35/47] nfsd: minorversion support for the back channel
>>>>
>>>> The client uses cl_private to determine the minorversion
>>>> (via a struct nfs_client *) to be set in the compound header,
>>>> and to know when to generate a SEQUENCE op.
>>>> Similarly, the server puts a struct nfs4_callback * in
>>>> there for callback compounds' CB_COMPOUND and CB_SEQUENCE.
>>> Why would the rpc_client need to know and track minor versions? That is
>>> an NFS protocol specific thing.
>> Agreed.  the rpc_client doesn't know anything about the minor version.
>> This is why we store it in a void *cl_private.
>>
>>> Besides, the caller should always know what minor version it is using.
>>> It shouldn't need a back-pointer in the rpc_client...
>>>
>> The back pointer is used in the xdr layer like this:
>>  	struct xdr_stream xdr;
>> +	struct nfs_client *clp =
>> +		(struct nfs_client *)req->rq_task->tk_client->cl_private;
>>  	struct compound_hdr hdr = {
>> -		.nops = 0,
>> +		.minorversion = clp->cl_minorversion,
>>  	};
> 
> Just put that information in the RPC arguments where it _BELONGS_.
> 

BTW, we are going back and forth on this...
cl_private was suggested on the review we did on November '08:
http://linux-nfs.org/pipermail/pnfs/2008-November/005435.html

Anyway, the following adds a *session to the nfs4_sequence_args
and res. It increases the memory footprint of all rpc args and res
but I agree it's cleaner.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
git diff --stat -p 2e00c20
 fs/nfs/client.c             |    1 -
 fs/nfs/nfs4proc.c           |    8 ++-
 fs/nfs/nfs4xdr.c            |  235 ++++++++++++++++---------------------------
 include/linux/nfs_xdr.h     |    7 ++
 include/linux/sunrpc/clnt.h |    1 -
 5 files changed, 99 insertions(+), 153 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 6e3ab63..bce02da 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -648,7 +648,6 @@ static int nfs_create_rpc_client(struct nfs_client *clp,
 	}
 
 	clp->cl_rpcclient = clnt;
-	clnt->cl_private = clp;
 	return 0;
 }
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5614cfa..e997882 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -514,11 +514,13 @@ static int nfs41_setup_sequence(struct nfs4_session *session,
 	spin_unlock(&tbl->slot_tbl_lock);
 
 	slot = tbl->slots + slotid;
+	args->sa_session = session;
 	args->sa_slotid = slotid;
 	args->sa_cache_this = cache_reply;
 
 	dprintk("<-- %s slotid=%d seqid=%d\n", __func__, slotid, slot->seq_nr);
 
+	res->sr_session = session;
 	res->sr_slotid = slotid;
 	res->sr_renewal_time = jiffies;
 	/*
@@ -4244,6 +4246,7 @@ static int nfs4_proc_exchange_id(struct nfs_client *clp, struct rpc_cred *cred)
 {
 	nfs4_verifier verifier;
 	struct nfs41_exchange_id_args args = {
+		.client = clp,
 		.flags = clp->cl_exchange_flags,
 	};
 	struct nfs41_exchange_id_res res = {
@@ -4659,10 +4662,13 @@ static int _nfs4_proc_create_session(struct nfs_client *clp)
 		.client = clp,
 		.cb_program = NFS4_CALLBACK,
 	};
-
+	struct nfs41_create_session_res res = {
+		.client = clp,
+	};
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_CREATE_SESSION],
 		.rpc_argp = &args,
+		.rpc_resp = &res,
 	};
 	int status;
 
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 342bb68..ae01d82 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1641,20 +1641,18 @@ static void encode_destroy_session(struct xdr_stream *xdr,
 #endif /* CONFIG_NFS_V4_1 */
 
 static void encode_sequence(struct xdr_stream *xdr,
-			    const struct nfs_client *clp,
 			    const struct nfs4_sequence_args *args,
 			    struct compound_hdr *hdr)
 {
 #if defined(CONFIG_NFS_V4_1)
-	struct nfs4_session *session;
+	struct nfs4_session *session = args->sa_session;
 	struct nfs4_slot_table *tp;
 	struct nfs4_slot *slot;
 	__be32 *p;
 
-	if (!clp->cl_minorversion)
+	if (!session)
 		return;
 
-	session = clp->cl_session;
 	tp = &session->fc_slot_table;
 
 	WARN_ON(args->sa_slotid == NFS4_MAX_SLOT_TABLE);
@@ -1690,21 +1688,28 @@ static void encode_sequence(struct xdr_stream *xdr,
  * END OF "GENERIC" ENCODE ROUTINES.
  */
 
+static u32 nfs4_xdr_minorversion(const struct nfs4_sequence_args *args)
+{
+#if defined(CONFIG_NFS_V4_1)
+	if (args->sa_session)
+		return args->sa_session->clp->cl_minorversion;
+#endif /* CONFIG_NFS_V4_1 */
+	return 0;
+}
+
 /*
  * Encode an ACCESS request
  */
 static int nfs4_xdr_enc_access(struct rpc_rqst *req, __be32 *p, const struct nfs4_accessargs *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_access(&xdr, args->access, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1718,15 +1723,13 @@ static int nfs4_xdr_enc_access(struct rpc_rqst *req, __be32 *p, const struct nfs
 static int nfs4_xdr_enc_lookup(struct rpc_rqst *req, __be32 *p, const struct nfs4_lookup_arg *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_lookup(&xdr, args->name, &hdr);
 	encode_getfh(&xdr, &hdr);
@@ -1741,15 +1744,13 @@ static int nfs4_xdr_enc_lookup(struct rpc_rqst *req, __be32 *p, const struct nfs
 static int nfs4_xdr_enc_lookup_root(struct rpc_rqst *req, __be32 *p, const struct nfs4_lookup_root_arg *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putrootfh(&xdr, &hdr);
 	encode_getfh(&xdr, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1763,15 +1764,13 @@ static int nfs4_xdr_enc_lookup_root(struct rpc_rqst *req, __be32 *p, const struc
 static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs_removeargs *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_remove(&xdr, &args->name, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1785,15 +1784,13 @@ static int nfs4_xdr_enc_remove(struct rpc_rqst *req, __be32 *p, const struct nfs
 static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs4_rename_arg *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->old_dir, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_putfh(&xdr, args->new_dir, &hdr);
@@ -1811,15 +1808,13 @@ static int nfs4_xdr_enc_rename(struct rpc_rqst *req, __be32 *p, const struct nfs
 static int nfs4_xdr_enc_link(struct rpc_rqst *req, __be32 *p, const struct nfs4_link_arg *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
@@ -1837,15 +1832,13 @@ static int nfs4_xdr_enc_link(struct rpc_rqst *req, __be32 *p, const struct nfs4_
 static int nfs4_xdr_enc_create(struct rpc_rqst *req, __be32 *p, const struct nfs4_create_arg *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_create(&xdr, args, &hdr);
@@ -1871,15 +1864,13 @@ static int nfs4_xdr_enc_symlink(struct rpc_rqst *req, __be32 *p, const struct nf
 static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p, const struct nfs4_getattr_arg *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
@@ -1892,15 +1883,13 @@ static int nfs4_xdr_enc_getattr(struct rpc_rqst *req, __be32 *p, const struct nf
 static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closeargs *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_close(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1914,15 +1903,13 @@ static int nfs4_xdr_enc_close(struct rpc_rqst *req, __be32 *p, struct nfs_closea
 static int nfs4_xdr_enc_open(struct rpc_rqst *req, __be32 *p, struct nfs_openargs *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_savefh(&xdr, &hdr);
 	encode_open(&xdr, args, &hdr);
@@ -1958,15 +1945,13 @@ static int nfs4_xdr_enc_open_confirm(struct rpc_rqst *req, __be32 *p, struct nfs
 static int nfs4_xdr_enc_open_noattr(struct rpc_rqst *req, __be32 *p, struct nfs_openargs *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_open(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -1980,15 +1965,13 @@ static int nfs4_xdr_enc_open_noattr(struct rpc_rqst *req, __be32 *p, struct nfs_
 static int nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req, __be32 *p, struct nfs_closeargs *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_open_downgrade(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -2002,15 +1985,13 @@ static int nfs4_xdr_enc_open_downgrade(struct rpc_rqst *req, __be32 *p, struct n
 static int nfs4_xdr_enc_lock(struct rpc_rqst *req, __be32 *p, struct nfs_lock_args *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_lock(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -2023,15 +2004,13 @@ static int nfs4_xdr_enc_lock(struct rpc_rqst *req, __be32 *p, struct nfs_lock_ar
 static int nfs4_xdr_enc_lockt(struct rpc_rqst *req, __be32 *p, struct nfs_lockt_args *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_lockt(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -2044,15 +2023,13 @@ static int nfs4_xdr_enc_lockt(struct rpc_rqst *req, __be32 *p, struct nfs_lockt_
 static int nfs4_xdr_enc_locku(struct rpc_rqst *req, __be32 *p, struct nfs_locku_args *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_locku(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -2065,15 +2042,13 @@ static int nfs4_xdr_enc_locku(struct rpc_rqst *req, __be32 *p, struct nfs_locku_
 static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct nfs4_readlink *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_readlink(&xdr, args, req, &hdr);
 
@@ -2089,15 +2064,13 @@ static int nfs4_xdr_enc_readlink(struct rpc_rqst *req, __be32 *p, const struct n
 static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nfs4_readdir_arg *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_readdir(&xdr, args, req, &hdr);
 
@@ -2116,15 +2089,13 @@ static int nfs4_xdr_enc_readdir(struct rpc_rqst *req, __be32 *p, const struct nf
 static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readargs *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_read(&xdr, args, &hdr);
 
@@ -2141,15 +2112,13 @@ static int nfs4_xdr_enc_read(struct rpc_rqst *req, __be32 *p, struct nfs_readarg
 static int nfs4_xdr_enc_setattr(struct rpc_rqst *req, __be32 *p, struct nfs_setattrargs *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_setattr(&xdr, args, args->server, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -2165,15 +2134,13 @@ nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
 		struct nfs_getaclargs *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getattr_two(&xdr, FATTR4_WORD0_ACL, 0, &hdr);
 
@@ -2189,15 +2156,13 @@ nfs4_xdr_enc_getacl(struct rpc_rqst *req, __be32 *p,
 static int nfs4_xdr_enc_write(struct rpc_rqst *req, __be32 *p, struct nfs_writeargs *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_write(&xdr, args, &hdr);
 	req->rq_snd_buf.flags |= XDRBUF_WRITE;
@@ -2212,15 +2177,13 @@ static int nfs4_xdr_enc_write(struct rpc_rqst *req, __be32 *p, struct nfs_writea
 static int nfs4_xdr_enc_commit(struct rpc_rqst *req, __be32 *p, struct nfs_writeargs *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_commit(&xdr, args, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -2234,15 +2197,13 @@ static int nfs4_xdr_enc_commit(struct rpc_rqst *req, __be32 *p, struct nfs_write
 static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs4_fsinfo_arg *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_fsinfo(&xdr, args->bitmask, &hdr);
 	encode_nops(&hdr);
@@ -2255,15 +2216,13 @@ static int nfs4_xdr_enc_fsinfo(struct rpc_rqst *req, __be32 *p, struct nfs4_fsin
 static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, __be32 *p, const struct nfs4_pathconf_arg *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getattr_one(&xdr, args->bitmask[0] & nfs4_pathconf_bitmap[0],
 			   &hdr);
@@ -2277,15 +2236,13 @@ static int nfs4_xdr_enc_pathconf(struct rpc_rqst *req, __be32 *p, const struct n
 static int nfs4_xdr_enc_statfs(struct rpc_rqst *req, __be32 *p, const struct nfs4_statfs_arg *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	encode_getattr_two(&xdr, args->bitmask[0] & nfs4_statfs_bitmap[0],
 			   args->bitmask[1] & nfs4_statfs_bitmap[1], &hdr);
@@ -2300,15 +2257,13 @@ static int nfs4_xdr_enc_server_caps(struct rpc_rqst *req, __be32 *p,
 				    struct nfs4_server_caps_arg *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fhandle, &hdr);
 	encode_getattr_one(&xdr, FATTR4_WORD0_SUPPORTED_ATTRS|
 			   FATTR4_WORD0_LINK_SUPPORT|
@@ -2378,15 +2333,13 @@ static int nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req, __be32 *p, str
 static int nfs4_xdr_enc_delegreturn(struct rpc_rqst *req, __be32 *p, const struct nfs4_delegreturnargs *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fhandle, &hdr);
 	encode_delegreturn(&xdr, args->stateid, &hdr);
 	encode_getfattr(&xdr, args->bitmask, &hdr);
@@ -2400,15 +2353,13 @@ static int nfs4_xdr_enc_delegreturn(struct rpc_rqst *req, __be32 *p, const struc
 static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs4_fs_locations_arg *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->dir_fh, &hdr);
 	encode_lookup(&xdr, args->name, &hdr);
 	encode_fs_locations(&xdr, args->bitmask, &hdr);
@@ -2424,13 +2375,11 @@ static int nfs4_xdr_enc_fs_locations(struct rpc_rqst *req, __be32 *p, struct nfs
  * EXCHANGE_ID request
  */
 static int nfs4_xdr_enc_exchange_id(struct rpc_rqst *req, uint32_t *p,
-				    void *args)
+				    struct nfs41_exchange_id_args *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = args->client->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -2447,10 +2396,8 @@ static int nfs4_xdr_enc_create_session(struct rpc_rqst *req, uint32_t *p,
 				       struct nfs41_create_session_args *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = args->client->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -2467,10 +2414,8 @@ static int nfs4_xdr_enc_destroy_session(struct rpc_rqst *req, uint32_t *p,
 					struct nfs4_session *session)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = session->clp->cl_minorversion,
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
@@ -2487,15 +2432,13 @@ static int nfs4_xdr_enc_sequence(struct rpc_rqst *req, uint32_t *p,
 				 struct nfs4_sequence_args *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(args),
 	};
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, args, &hdr);
+	encode_sequence(&xdr, args, &hdr);
 	encode_nops(&hdr);
 	return 0;
 }
@@ -2507,16 +2450,14 @@ static int nfs4_xdr_enc_get_lease_time(struct rpc_rqst *req, uint32_t *p,
 				       struct nfs4_get_lease_time_args *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->la_seq_args),
 	};
 	const u32 lease_bitmap[2] = { FATTR4_WORD0_LEASE_TIME, 0 };
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->la_seq_args, &hdr);
+	encode_sequence(&xdr, &args->la_seq_args, &hdr);
 	encode_putrootfh(&xdr, &hdr);
 	encode_fsinfo(&xdr, lease_bitmap, &hdr);
 	encode_nops(&hdr);
@@ -4198,13 +4139,13 @@ static int decode_exchange_id(struct xdr_stream *xdr,
 	return 0;
 }
 
-static int decode_create_session(struct xdr_stream *xdr, struct rpc_rqst *rqstp)
+static int decode_create_session(struct xdr_stream *xdr,
+				 struct nfs41_create_session_res *res)
 {
 	uint32_t *p;
 	int status;
 	u32 nr_attrs;
-	struct nfs_client *clp =
-		(struct nfs_client *)rqstp->rq_task->tk_client->cl_private;
+	struct nfs_client *clp = res->client;
 	struct nfs4_session *session = clp->cl_session;
 
 	status = decode_op_hdr(xdr, OP_CREATE_SESSION);
@@ -4266,16 +4207,13 @@ static int decode_sequence(struct xdr_stream *xdr,
 			   struct rpc_rqst *rqstp)
 {
 #if defined(CONFIG_NFS_V4_1)
-	struct nfs4_slot_table *tp;
 	struct nfs4_slot *slot;
-	struct nfs_client *clp =
-		(struct nfs_client *)rqstp->rq_task->tk_client->cl_private;
 	struct nfs4_sessionid id;
 	u32 dummy;
 	int status;
 	__be32 *p;
 
-	if (clp->cl_minorversion == 0)
+	if (!res->sr_session)
 		return 0;
 
 	status = decode_op_hdr(xdr, OP_SEQUENCE);
@@ -4288,11 +4226,10 @@ static int decode_sequence(struct xdr_stream *xdr,
 	 */
 	status = -ESERVERFAULT;
 
-	tp = &clp->cl_session->fc_slot_table;
-	slot = tp->slots + res->sr_slotid;
+	slot = &res->sr_session->fc_slot_table.slots[res->sr_slotid];
 	READ_BUF(NFS4_MAX_SESSIONID_LEN + 20);
 	COPYMEM(id.data, NFS4_MAX_SESSIONID_LEN);
-	if (memcmp(id.data, clp->cl_session->sess_id.data,
+	if (memcmp(id.data, res->sr_session->sess_id.data,
 		   NFS4_MAX_SESSIONID_LEN)) {
 		dprintk("%s Invalid session id\n", __func__);
 		goto out_err;
@@ -4601,16 +4538,14 @@ static int
 nfs4_xdr_enc_setacl(struct rpc_rqst *req, __be32 *p, struct nfs_setaclargs *args)
 {
 	struct xdr_stream xdr;
-	struct nfs_client *clp =
-		(struct nfs_client *)req->rq_task->tk_client->cl_private;
 	struct compound_hdr hdr = {
-		.minorversion = clp->cl_minorversion,
+		.minorversion = nfs4_xdr_minorversion(&args->seq_args),
 	};
 	int status;
 
 	xdr_init_encode(&xdr, &req->rq_snd_buf, p);
 	encode_compound_hdr(&xdr, req, &hdr);
-	encode_sequence(&xdr, clp, &args->seq_args, &hdr);
+	encode_sequence(&xdr, &args->seq_args, &hdr);
 	encode_putfh(&xdr, args->fh, &hdr);
 	status = encode_setacl(&xdr, args, &hdr);
 	encode_nops(&hdr);
@@ -5233,7 +5168,7 @@ static int nfs4_xdr_dec_exchange_id(struct rpc_rqst *rqstp, uint32_t *p,
  * a CREATE_SESSION request
  */
 static int nfs4_xdr_dec_create_session(struct rpc_rqst *rqstp, uint32_t *p,
-				       void *res)
+				       struct nfs41_create_session_res *res)
 {
 	struct xdr_stream xdr;
 	struct compound_hdr hdr;
@@ -5242,7 +5177,7 @@ static int nfs4_xdr_dec_create_session(struct rpc_rqst *rqstp, uint32_t *p,
 	xdr_init_decode(&xdr, &rqstp->rq_rcv_buf, p);
 	status = decode_compound_hdr(&xdr, &hdr);
 	if (!status)
-		status = decode_create_session(&xdr, rqstp);
+		status = decode_create_session(&xdr, res);
 	return status;
 }
 
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 517291e..4feacc6 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -130,11 +130,13 @@ struct nfs4_slot {
 };
 
 struct nfs4_sequence_args {
+	struct nfs4_session	*sa_session;
 	u8			sa_slotid;
 	u8			sa_cache_this;
 };
 
 struct nfs4_sequence_res {
+	struct nfs4_session	*sr_session;
 	u8			sr_slotid;	/* slot used to send request */
 	unsigned long		sr_renewal_time;
 	int			sr_status;	/* sequence operation status */
@@ -870,6 +872,7 @@ struct nfs_impl_id4 {
 
 #define NFS4_EXCHANGE_ID_LEN	(48)
 struct nfs41_exchange_id_args {
+	struct nfs_client		*client;
 	nfs4_verifier			*verifier;
 	unsigned int 			id_len;
 	char 				id[NFS4_EXCHANGE_ID_LEN];
@@ -902,6 +905,10 @@ struct nfs41_create_session_args {
 	struct nfs4_channel_attrs	fc_attrs;	/* Fore Channel */
 	struct nfs4_channel_attrs	bc_attrs;	/* Back Channel */
 };
+
+struct nfs41_create_session_res {
+	struct nfs_client	       *client;
+};
 #endif /* CONFIG_NFS_V4_1 */
 
 struct nfs_page;
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 8ca3fef..37881f1 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -53,7 +53,6 @@ struct rpc_clnt {
 	char			cl_pathname[30];/* Path in rpc_pipe_fs */
 	struct vfsmount *	cl_vfsmnt;
 	struct dentry *		cl_dentry;	/* inode */
-	void			*cl_private;	/* private data */
 	struct rpc_clnt *	cl_parent;	/* Points to parent of clones */
 	struct rpc_rtt		cl_rtt_default;
 	struct rpc_timeout	cl_timeout_default;



