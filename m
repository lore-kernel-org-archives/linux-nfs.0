Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from gateway36.websitewelcome.com ([50.116.126.2]:23674 "EHLO
        gateway36.websitewelcome.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1725857AbeHAE05 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Aug 2018 00:26:57 -0400
Received: from cm16.websitewelcome.com (cm16.websitewelcome.com [100.42.49.19])
        by gateway36.websitewelcome.com (Postfix) with ESMTP id 31B74400C5679
        for <linux-nfs@vger.kernel.org>; Tue, 31 Jul 2018 20:21:12 -0500 (CDT)
Date: Tue, 31 Jul 2018 21:18:44 -0500
From: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
To: Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Subject: [PATCH] NFS: Mark expected switch fall-throughs
Message-ID: <20180801021844.GA17795@embeddedor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In preparation to enabling -Wimplicit-fallthrough, mark switch cases
where we are expecting to fall through.

Warning level 2 was used: -Wimplicit-fallthrough=2

Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>
---
 fs/nfs/blocklayout/blocklayout.c | 1 +
 fs/nfs/nfs3acl.c                 | 2 ++
 fs/nfs/nfs4file.c                | 1 +
 fs/nfs/nfs4idmap.c               | 2 ++
 fs/nfs/nfs4proc.c                | 8 ++++++++
 fs/nfs/nfs4state.c               | 6 ++++++
 fs/nfs/pagelist.c                | 1 +
 7 files changed, 21 insertions(+)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 9619016..a981733 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -753,6 +753,7 @@ bl_alloc_lseg(struct pnfs_layout_hdr *lo, struct nfs4_layoutget_res *lgr,
 	case -ENODEV:
 		/* Our extent block devices are unavailable */
 		set_bit(NFS_LSEG_UNAVAILABLE, &lseg->pls_flags);
+		/* Fall through */
 	case 0:
 		return lseg;
 	default:
diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
index 7173a4e..9fce185 100644
--- a/fs/nfs/nfs3acl.c
+++ b/fs/nfs/nfs3acl.c
@@ -108,6 +108,7 @@ struct posix_acl *nfs3_get_acl(struct inode *inode, int type)
 		case -EPROTONOSUPPORT:
 			dprintk("NFS_V3_ACL extension not supported; disabling\n");
 			server->caps &= ~NFS_CAP_ACLS;
+			/* fall through */
 		case -ENOTSUPP:
 			status = -EOPNOTSUPP;
 		default:
@@ -229,6 +230,7 @@ static int __nfs3_proc_setacls(struct inode *inode, struct posix_acl *acl,
 			dprintk("NFS_V3_ACL SETACL RPC not supported"
 					"(will not retry)\n");
 			server->caps &= ~NFS_CAP_ACLS;
+			/* fall through */
 		case -ENOTSUPP:
 			status = -EOPNOTSUPP;
 	}
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 6b3b372..6c03d6b 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -149,6 +149,7 @@ static loff_t nfs4_file_llseek(struct file *filep, loff_t offset, int whence)
 		ret = nfs42_proc_llseek(filep, offset, whence);
 		if (ret != -ENOTSUPP)
 			return ret;
+		/* Fall through */
 	default:
 		return nfs_file_llseek(filep, offset, whence);
 	}
diff --git a/fs/nfs/nfs4idmap.c b/fs/nfs/nfs4idmap.c
index cf72169..3f23b68 100644
--- a/fs/nfs/nfs4idmap.c
+++ b/fs/nfs/nfs4idmap.c
@@ -506,6 +506,7 @@ static int nfs_idmap_prepare_message(char *desc, struct idmap *idmap,
 	switch (token) {
 	case Opt_find_uid:
 		im->im_type = IDMAP_TYPE_USER;
+		/* Fall through */
 	case Opt_find_gid:
 		im->im_conv = IDMAP_CONV_NAMETOID;
 		ret = match_strlcpy(im->im_name, &substr, IDMAP_NAMESZ);
@@ -513,6 +514,7 @@ static int nfs_idmap_prepare_message(char *desc, struct idmap *idmap,
 
 	case Opt_find_user:
 		im->im_type = IDMAP_TYPE_USER;
+		/* Fall through */
 	case Opt_find_group:
 		im->im_conv = IDMAP_CONV_IDTONAME;
 		ret = match_int(&substr, &im->im_id);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 981c1cb..bed38b9 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -449,6 +449,7 @@ static int nfs4_do_handle_exception(struct nfs_server *server,
 						stateid);
 				goto wait_on_recovery;
 			}
+			/* Fall through */
 		case -NFS4ERR_OPENMODE:
 			if (inode) {
 				int err;
@@ -501,8 +502,10 @@ static int nfs4_do_handle_exception(struct nfs_server *server,
 				ret = -EBUSY;
 				break;
 			}
+			/* Fall through */
 		case -NFS4ERR_DELAY:
 			nfs_inc_server_stats(server, NFSIOS_DELAY);
+			/* Fall through */
 		case -NFS4ERR_GRACE:
 		case -NFS4ERR_LAYOUTTRYLATER:
 		case -NFS4ERR_RECALLCONFLICT:
@@ -1361,6 +1364,7 @@ static int can_open_delegated(struct nfs_delegation *delegation, fmode_t fmode,
 	case NFS4_OPEN_CLAIM_PREVIOUS:
 		if (!test_bit(NFS_DELEGATION_NEED_RECLAIM, &delegation->flags))
 			break;
+		/* Fall through */
 	default:
 		return 0;
 	}
@@ -2130,6 +2134,7 @@ int nfs4_open_delegation_recall(struct nfs_open_context *ctx,
 		err = nfs4_open_recover_helper(opendata, FMODE_WRITE);
 		if (err)
 			break;
+		/* Fall through */
 	case FMODE_READ:
 		err = nfs4_open_recover_helper(opendata, FMODE_READ);
 	}
@@ -2259,6 +2264,7 @@ static void nfs4_open_prepare(struct rpc_task *task, void *calldata)
 	case NFS4_OPEN_CLAIM_DELEG_CUR_FH:
 	case NFS4_OPEN_CLAIM_DELEG_PREV_FH:
 		data->o_arg.open_bitmap = &nfs4_open_noattr_bitmap[0];
+		/* Fall through */
 	case NFS4_OPEN_CLAIM_FH:
 		task->tk_msg.rpc_proc = &nfs4_procedures[NFSPROC4_CLNT_OPEN_NOATTR];
 	}
@@ -6221,11 +6227,13 @@ static void nfs4_locku_done(struct rpc_task *task, void *data)
 			if (nfs4_update_lock_stateid(calldata->lsp,
 					&calldata->res.stateid))
 				break;
+			/* Fall through */
 		case -NFS4ERR_ADMIN_REVOKED:
 		case -NFS4ERR_EXPIRED:
 			nfs4_free_revoked_stateid(calldata->server,
 					&calldata->arg.stateid,
 					task->tk_msg.rpc_cred);
+			/* Fall through */
 		case -NFS4ERR_BAD_STATEID:
 		case -NFS4ERR_OLD_STATEID:
 		case -NFS4ERR_STALE_STATEID:
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 2bf2eaa..f1b27e8 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -1525,6 +1525,7 @@ static int nfs4_reclaim_locks(struct nfs4_state *state, const struct nfs4_state_
 		default:
 			pr_err("NFS: %s: unhandled error %d\n",
 					__func__, status);
+			/* Fall through */
 		case -ENOMEM:
 		case -NFS4ERR_DENIED:
 		case -NFS4ERR_RECLAIM_BAD:
@@ -1597,6 +1598,7 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 			default:
 				printk(KERN_ERR "NFS: %s: unhandled error %d\n",
 					__func__, status);
+				/* Fall through */
 			case -ENOENT:
 			case -ENOMEM:
 			case -EACCES:
@@ -1608,6 +1610,7 @@ static int nfs4_reclaim_open_state(struct nfs4_state_owner *sp, const struct nfs
 				break;
 			case -EAGAIN:
 				ssleep(1);
+				/* Fall through */
 			case -NFS4ERR_ADMIN_REVOKED:
 			case -NFS4ERR_STALE_STATEID:
 			case -NFS4ERR_OLD_STATEID:
@@ -2190,9 +2193,11 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
 	case -ETIMEDOUT:
 		if (clnt->cl_softrtry)
 			break;
+		/* Fall through */
 	case -NFS4ERR_DELAY:
 	case -EAGAIN:
 		ssleep(1);
+		/* Fall through */
 	case -NFS4ERR_STALE_CLIENTID:
 		dprintk("NFS: %s after status %d, retrying\n",
 			__func__, status);
@@ -2204,6 +2209,7 @@ int nfs4_discover_server_trunking(struct nfs_client *clp,
 		}
 		if (clnt->cl_auth->au_flavor == RPC_AUTH_UNIX)
 			break;
+		/* Fall through */
 	case -NFS4ERR_CLID_INUSE:
 	case -NFS4ERR_WRONGSEC:
 		/* No point in retrying if we already used RPC_AUTH_UNIX */
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 67d19cd..bb5476a 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -561,6 +561,7 @@ static void nfs_pgio_rpcsetup(struct nfs_pgio_header *hdr,
 	case FLUSH_COND_STABLE:
 		if (nfs_reqs_to_commit(cinfo))
 			break;
+		/* fall through */
 	default:
 		hdr->args.stable = NFS_FILE_SYNC;
 	}
-- 
2.7.4

