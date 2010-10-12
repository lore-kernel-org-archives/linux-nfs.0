Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from exprod5og111.obsmtp.com ([64.18.0.22]:57061 "HELO
	exprod5og111.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751717Ab0JLSEg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 12 Oct 2010 14:04:36 -0400
Message-ID: <4CB4A332.8090803@panasas.com>
Date: Tue, 12 Oct 2010 14:04:34 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: Fred Isaman <iisaman@netapp.com>
CC: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/1] pnfs_submit: Restore forgetful mode io draining
References: <1286444145-12781-1-git-send-email-iisaman@netapp.com>
In-Reply-To: <1286444145-12781-1-git-send-email-iisaman@netapp.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2010-10-07 05:35, Fred Isaman wrote:
> Recent changes to the waitq code removed the wait for io to drain
> in the case of a "forgetful" return.  Restore the previous behavior.
> 
> Signed-off-by: Fred Isaman <iisaman@netapp.com>
> ---
>  fs/nfs/nfs4proc.c       |    6 +++++-
>  fs/nfs/pnfs.c           |    9 +++------
>  include/linux/nfs_xdr.h |    1 +
>  3 files changed, 9 insertions(+), 7 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index c854814..7727f592 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -5639,7 +5639,11 @@ nfs4_layoutreturn_prepare(struct rpc_task *task, void *calldata)
>  		rpc_sleep_on(&nfsi->lo_rpcwaitq, task, NULL);
>  		return;
>  	}
> -
> +	if (lrp->stateid) {
> +		/* Forget the layout, without sending the return */
> +		rpc_exit(task, 0);
> +		return;
> +	}
>  	if (nfs4_setup_sequence(server, NULL, &lrp->args.seq_args,
>  				&lrp->res.seq_res, 0, task))
>  		return;
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index f573219..eb4dfdf 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -612,7 +612,7 @@ pnfs_return_layout_barrier(struct nfs_inode *nfsi,
>  static int
>  return_layout(struct inode *ino, struct pnfs_layout_range *range,
>  	      enum pnfs_layoutreturn_type type, struct pnfs_layout_hdr *lo,
> -	      bool wait)
> +	      bool wait, const nfs4_stateid *stateid)
>  {
>  	struct nfs4_layoutreturn *lrp;
>  	struct nfs_server *server = NFS_SERVER(ino);
> @@ -633,6 +633,7 @@ return_layout(struct inode *ino, struct pnfs_layout_range *range,
>  	lrp->args.return_type = type;
>  	lrp->args.range = *range;
>  	lrp->args.inode = ino;
> +	lrp->stateid = stateid;
>  
>  	status = nfs4_proc_layoutreturn(lrp, wait);
>  out:
> @@ -688,11 +689,7 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
>  					__func__, status);
>  			}
>  		}
> -
> -		if (!stateid)
> -			status = return_layout(ino, &arg, type, lo, wait);
> -		else
> -			pnfs_layoutreturn_release(lo, &arg);
> +		status = return_layout(ino, &arg, type, lo, wait, stateid);
>  	}
>  out:
>  	dprintk("<-- %s status: %d\n", __func__, status);
> diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
> index c72de21..80e6a36 100644
> --- a/include/linux/nfs_xdr.h
> +++ b/include/linux/nfs_xdr.h
> @@ -277,6 +277,7 @@ struct nfs4_layoutreturn {
>  	struct nfs4_layoutreturn_args args;
>  	struct nfs4_layoutreturn_res res;
>  	struct rpc_cred *cred;
> +	const nfs4_stateid *stateid;
>  	int rpc_status;
>  };
>  

So after reverting this patch in post-submit there's no real reason
for passing the stateid to pnfs_return_layout, is it?
I'm planning to do the following in the pnfs branch (post revert of your patch):

git diff --stat -p -M
 fs/nfs/callback_proc.c |    5 ++---
 fs/nfs/inode.c         |    2 +-
 fs/nfs/nfs4state.c     |    2 +-
 fs/nfs/pnfs.c          |   11 +----------
 fs/nfs/pnfs.h          |    5 +----
 5 files changed, 6 insertions(+), 19 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 6b560ce..93a9b2e 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -234,8 +234,7 @@ static int pnfs_recall_layout(void *data)
 		if (pnfs_is_next_layout_stateid(NFS_I(inode)->layout,
 						rl.cbl_stateid))
 			status = pnfs_return_layout(inode, &rl.cbl_seg,
-						    &rl.cbl_stateid, RETURN_FILE,
-						    false);
+						    RETURN_FILE, false);
 		else
 			status = cpu_to_be32(NFS4ERR_DELAY);
 		if (status)
@@ -255,7 +254,7 @@ static int pnfs_recall_layout(void *data)
 	/* IMPROVEME: This loop is inefficient, running in O(|s_inodes|^2) */
 	while ((ino = nfs_layoutrecall_find_inode(clp, &rl)) != NULL) {
 		/* FIXME: need to check status on pnfs_return_layout */
-		pnfs_return_layout(ino, &rl.cbl_seg, NULL, RETURN_FILE, false);
+		pnfs_return_layout(ino, &rl.cbl_seg, RETURN_FILE, false);
 		iput(ino);
 	}
 
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 437d9a6..cbd5b3f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -1418,7 +1418,7 @@ static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr)
  */
 void nfs4_evict_inode(struct inode *inode)
 {
-	pnfs_return_layout(inode, NULL, NULL, RETURN_FILE, true);
+	pnfs_return_layout(inode, NULL, RETURN_FILE, true);
 	truncate_inode_pages(&inode->i_data, 0);
 	end_writeback(inode);
 	pnfs_destroy_layout(NFS_I(inode));
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 3168d77..8d32f2f 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -612,7 +612,7 @@ static void __nfs4_close(struct path *path, struct nfs4_state *state,
 				.length = NFS4_MAX_UINT64,
 			};
 
-			pnfs_return_layout(state->inode, &range, NULL,
+			pnfs_return_layout(state->inode, &range,
 					   RETURN_FILE, wait);
 		}
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f573219..74d8532 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -642,7 +642,6 @@ out:
 
 int
 _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
-		    const nfs4_stateid *stateid, /* optional */
 		    enum pnfs_layoutreturn_type type,
 		    bool wait)
 {
@@ -675,11 +674,6 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 		spin_unlock(&ino->i_lock);
 
 		if (layoutcommit_needed(nfsi)) {
-			if (stateid && !wait) { /* callback */
-				dprintk("%s: layoutcommit pending\n", __func__);
-				status = -EAGAIN;
-				goto out_put;
-			}
 			status = pnfs_layoutcommit_inode(ino, wait);
 			if (status) {
 				/* Return layout even if layoutcommit fails */
@@ -689,10 +683,7 @@ _pnfs_return_layout(struct inode *ino, struct pnfs_layout_range *range,
 			}
 		}
 
-		if (!stateid)
-			status = return_layout(ino, &arg, type, lo, wait);
-		else
-			pnfs_layoutreturn_release(lo, &arg);
+		status = return_layout(ino, &arg, type, lo, wait);
 	}
 out:
 	dprintk("<-- %s status: %d\n", __func__, status);
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 235709e..7ca22a0 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -184,7 +184,6 @@ pnfs_update_layout(struct inode *ino, struct nfs_open_context *ctx,
 		   enum pnfs_iomode access_type);
 bool pnfs_return_layout_barrier(struct nfs_inode *, struct pnfs_layout_range *);
 int _pnfs_return_layout(struct inode *, struct pnfs_layout_range *,
-			const nfs4_stateid *stateid, /* optional */
 			enum pnfs_layoutreturn_type, bool wait);
 void set_pnfs_layoutdriver(struct nfs_server *, u32 id);
 void unset_pnfs_layoutdriver(struct nfs_server *);
@@ -252,7 +251,6 @@ pnfs_layout_roc_iomode(struct nfs_inode *nfsi)
 
 static inline int pnfs_return_layout(struct inode *ino,
 				     struct pnfs_layout_range *range,
-				     const nfs4_stateid *stateid, /* optional */
 				     enum pnfs_layoutreturn_type type,
 				     bool wait)
 {
@@ -261,7 +259,7 @@ static inline int pnfs_return_layout(struct inode *ino,
 
 	if (pnfs_enabled_sb(nfss) &&
 	    (type != RETURN_FILE || has_layout(nfsi)))
-		return _pnfs_return_layout(ino, range, stateid, type, wait);
+		return _pnfs_return_layout(ino, range, type, wait);
 
 	return 0;
 }
@@ -350,7 +348,6 @@ pnfs_layout_roc_iomode(struct nfs_inode *nfsi)
 
 static inline int pnfs_return_layout(struct inode *ino,
 				     struct pnfs_layout_range *range,
-				     const nfs4_stateid *stateid, /* optional */
 				     enum pnfs_layoutreturn_type type,
 				     bool wait)
 {
