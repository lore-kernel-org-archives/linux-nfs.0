Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f170.google.com ([209.85.223.170]:37564 "EHLO
	mail-ie0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757907Ab3BFXa0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Feb 2013 18:30:26 -0500
Received: by mail-ie0-f170.google.com with SMTP id c11so2733453ieb.15
        for <linux-nfs@vger.kernel.org>; Wed, 06 Feb 2013 15:30:25 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v1 3/4] NFS: Avoid PUTROOTFH when managing leases
To: linux-nfs@vger.kernel.org
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Bryan Schumaker <bjschuma@netapp.com>
Date: Wed, 06 Feb 2013 18:30:24 -0500
Message-ID: <20130206233024.1535.72583.stgit@seurat.1015granger.net>
In-Reply-To: <20130206230045.1535.48770.stgit@seurat.1015granger.net>
References: <20130206230045.1535.48770.stgit@seurat.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, the compound operation the Linux NFS client sends to the
server to confirm a client ID looks like this:

	{ SETCLIENTID_CONFIRM; PUTROOTFH; GETATTR(lease_time) }

Performing these operations together saves a round trip.

Unfortunately, this arrangement assumes that the security flavor
used for establishing a client ID can also be used to access the
server's pseudo-fs.

If the server requires a different security flavor to access its
pseudo-fs than it allowed for the client's SETCLIENTID operation,
the PUTROOTFH in this compound fails with NFS4ERR_WRONGSEC.  Even
though the SETCLIENTID_CONFIRM succeeded, our client's trunking
detection logic interprets the failure of the compound as a failure
by the server to confirm the client ID.

As part of server trunking detection, the client thus begins another
SETCLIENTID pass with the same nfs4_client_id.  This fails with
NFS4ERR_CLID_INUSE because the first SETCLIENTID/SETCLIENTID_CONFIRM
already succeeded in confirming that client ID -- it was the
PUTROOTFH operation that caused the SETCLIENTID_CONFIRM compound to
fail.

This commit separates the "establish client ID" step from the
"accessing the server's pseudo-fs root" step.  The first access of
the server's pseudo-fs may require retrying the PUTROOTFH operation
with different security flavors.

That leaves the matter of how to retrieve the server's lease time.
Do this in nfs4_proc_get_rootfh() after we are certain that the
rpc_clnt's security flavor is correct for accessing the root FH.

Note that NFSv4.1 state recovery invokes nfs4_proc_get_lease_time()
using the lease management security flavor.  This may cause some
heartburn if that security flavor isn't the same as the security
flavor the server requires for accessing the pseudo-fs.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Bryan Schumaker <bjschuma@netapp.com>
---

 fs/nfs/nfs4proc.c |   68 +++++++++++++++++++++++++++++++++++++++++++++--------
 fs/nfs/nfs4xdr.c  |   18 ++------------
 2 files changed, 61 insertions(+), 25 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ad86cfa..6f1055b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2449,6 +2449,62 @@ static int nfs4_find_root_sec(struct nfs_server *server, struct nfs_fh *fhandle,
 	return status;
 }
 
+static int _nfs4_get_lease_time(struct nfs_server *server,
+		struct nfs_fh *fhandle)
+{
+	const u32 lease_bitmap[3] = { FATTR4_WORD0_LEASE_TIME };
+	struct nfs_fsinfo info;
+	struct nfs4_fsinfo_arg args = {
+		.fh = fhandle,
+		.bitmask = lease_bitmap,
+	};
+	struct nfs4_fsinfo_res res = {
+		.fsinfo = &info,
+	};
+	struct rpc_message msg = {
+		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_FSINFO],
+		.rpc_argp = &args,
+		.rpc_resp = &res,
+	};
+	unsigned long now;
+	int status;
+
+	dprintk("NFS call  get_lease_time\n");
+
+	now = jiffies;
+	status = nfs4_call_sync(server->client, server, &msg,
+					&args.seq_args, &res.seq_res, 0);
+	if (status == 0) {
+		struct nfs_client *clp = server->nfs_client;
+
+		spin_lock(&clp->cl_lock);
+		clp->cl_lease_time = info.lease_time * HZ;
+		clp->cl_last_renewal = now;
+		spin_unlock(&clp->cl_lock);
+	}
+	dprintk("NFS reply get_lease_time: %d\n", status);
+	return status;
+}
+
+static int nfs4_get_lease_time(struct nfs_server *server,
+		struct nfs_fh *fhandle)
+{
+	struct nfs4_exception exception = { };
+	int err;
+	do {
+		err = _nfs4_get_lease_time(server, fhandle);
+		switch (err) {
+		case 0:
+		case -NFS4ERR_WRONGSEC:
+			goto out;
+		default:
+			err = nfs4_handle_exception(server, err, &exception);
+		}
+	} while (exception.retry);
+out:
+	return err;
+}
+
 static int nfs4_do_find_root_sec(struct nfs_server *server,
 		struct nfs_fh *fhandle, struct nfs_fsinfo *info)
 {
@@ -2475,6 +2531,8 @@ int nfs4_proc_get_rootfh(struct nfs_server *server, struct nfs_fh *fhandle,
 		status = nfs4_do_find_root_sec(server, fhandle, info);
 
 	if (status == 0)
+		status = nfs4_get_lease_time(server, fhandle);
+	if (status == 0)
 		status = nfs4_server_capabilities(server, fhandle);
 	if (status == 0)
 		status = nfs4_do_fsinfo(server, fhandle, info);
@@ -4120,27 +4178,17 @@ int nfs4_proc_setclientid_confirm(struct nfs_client *clp,
 		struct nfs4_setclientid_res *arg,
 		struct rpc_cred *cred)
 {
-	struct nfs_fsinfo fsinfo;
 	struct rpc_message msg = {
 		.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_SETCLIENTID_CONFIRM],
 		.rpc_argp = arg,
-		.rpc_resp = &fsinfo,
 		.rpc_cred = cred,
 	};
-	unsigned long now;
 	int status;
 
 	dprintk("NFS call  setclientid_confirm auth=%s, (client ID %llx)\n",
 		clp->cl_rpcclient->cl_auth->au_ops->au_name,
 		clp->cl_clientid);
-	now = jiffies;
 	status = rpc_call_sync(clp->cl_rpcclient, &msg, RPC_TASK_TIMEOUT);
-	if (status == 0) {
-		spin_lock(&clp->cl_lock);
-		clp->cl_lease_time = fsinfo.lease_time * HZ;
-		clp->cl_last_renewal = now;
-		spin_unlock(&clp->cl_lock);
-	}
 	dprintk("NFS reply setclientid_confirm: %d\n", status);
 	return status;
 }
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index c445b8c..66eafa5 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -530,14 +530,10 @@ static int nfs4_stat_to_errno(int);
 				decode_setclientid_maxsz)
 #define NFS4_enc_setclientid_confirm_sz \
 				(compound_encode_hdr_maxsz + \
-				encode_setclientid_confirm_maxsz + \
-				encode_putrootfh_maxsz + \
-				encode_fsinfo_maxsz)
+				encode_setclientid_confirm_maxsz)
 #define NFS4_dec_setclientid_confirm_sz \
 				(compound_decode_hdr_maxsz + \
-				decode_setclientid_confirm_maxsz + \
-				decode_putrootfh_maxsz + \
-				decode_fsinfo_maxsz)
+				decode_setclientid_confirm_maxsz)
 #define NFS4_enc_lock_sz        (compound_encode_hdr_maxsz + \
 				encode_sequence_maxsz + \
 				encode_putfh_maxsz + \
@@ -2609,12 +2605,9 @@ static void nfs4_xdr_enc_setclientid_confirm(struct rpc_rqst *req,
 	struct compound_hdr hdr = {
 		.nops	= 0,
 	};
-	const u32 lease_bitmap[3] = { FATTR4_WORD0_LEASE_TIME };
 
 	encode_compound_hdr(xdr, req, &hdr);
 	encode_setclientid_confirm(xdr, arg, &hdr);
-	encode_putrootfh(xdr, &hdr);
-	encode_fsinfo(xdr, lease_bitmap, &hdr);
 	encode_nops(&hdr);
 }
 
@@ -6650,8 +6643,7 @@ static int nfs4_xdr_dec_setclientid(struct rpc_rqst *req,
  * Decode SETCLIENTID_CONFIRM response
  */
 static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req,
-					    struct xdr_stream *xdr,
-					    struct nfs_fsinfo *fsinfo)
+					    struct xdr_stream *xdr)
 {
 	struct compound_hdr hdr;
 	int status;
@@ -6659,10 +6651,6 @@ static int nfs4_xdr_dec_setclientid_confirm(struct rpc_rqst *req,
 	status = decode_compound_hdr(xdr, &hdr);
 	if (!status)
 		status = decode_setclientid_confirm(xdr);
-	if (!status)
-		status = decode_putrootfh(xdr);
-	if (!status)
-		status = decode_fsinfo(xdr, fsinfo);
 	return status;
 }
 

