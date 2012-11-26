Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35547 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754753Ab2KZOkE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Nov 2012 09:40:04 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 7/8] nfsd4: downgrade some fs/nfsd/nfs4state.c BUG's
Date: Mon, 26 Nov 2012 09:39:58 -0500
Message-Id: <1353940799-11763-8-git-send-email-bfields@redhat.com>
In-Reply-To: <1353940799-11763-1-git-send-email-bfields@redhat.com>
References: <1353940799-11763-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Linus has pointed out that indiscriminate use of BUG's can make it
harder to diagnose bugs because they can bring a machine down, often
before we manage to get any useful debugging information to the logs.
(Consider, for example, a BUG() that fires in a workqueue, or while
holding a spinlock).

Most of these BUG's won't do much more than kill an nfsd thread, but it
would still probably be safer to get out the warning without dying.

There's still more of this to do in nfsd/.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4state.c |   26 +++++++++++++++-----------
 1 file changed, 15 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e75872f..41d2aed 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -190,7 +190,7 @@ static struct list_head file_hashtbl[FILE_HASH_SIZE];
 
 static void __nfs4_file_get_access(struct nfs4_file *fp, int oflag)
 {
-	BUG_ON(!(fp->fi_fds[oflag] || fp->fi_fds[O_RDWR]));
+	WARN_ON_ONCE(!(fp->fi_fds[oflag] || fp->fi_fds[O_RDWR]));
 	atomic_inc(&fp->fi_access[oflag]);
 }
 
@@ -249,7 +249,7 @@ static inline int get_new_stid(struct nfs4_stid *stid)
 	 * preallocations that can exist at a time, but the state lock
 	 * prevents anyone from using ours before we get here:
 	 */
-	BUG_ON(error);
+	WARN_ON_ONCE(error);
 	/*
 	 * It shouldn't be a problem to reuse an opaque stateid value.
 	 * I don't think it is for 4.1.  But with 4.0 I worry that, for
@@ -494,7 +494,8 @@ static int nfs4_access_to_omode(u32 access)
 	case NFS4_SHARE_ACCESS_BOTH:
 		return O_RDWR;
 	}
-	BUG();
+	WARN_ON_ONCE(1);
+	return O_RDONLY;
 }
 
 /* release all access and file references for a given stateid */
@@ -1605,10 +1606,9 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	switch (exid->spa_how) {
 	case SP4_NONE:
 		break;
+	default:				/* checked by xdr code */
+		WARN_ON_ONCE(1);
 	case SP4_SSV:
-		return nfserr_serverfault;
-	default:
-		BUG();				/* checked by xdr code */
 	case SP4_MACH_CRED:
 		return nfserr_serverfault;	/* no excuse :-/ */
 	}
@@ -2912,7 +2912,7 @@ static void nfsd4_open_deleg_none_ext(struct nfsd4_open *open, int status)
 			open->op_why_no_deleg = WND4_CANCELLED;
 			break;
 		case NFS4_SHARE_WANT_NO_DELEG:
-			BUG();	/* not supposed to get here */
+			WARN_ON_ONCE(1);
 		}
 	}
 }
@@ -3466,7 +3466,11 @@ nfs4_preprocess_stateid_op(struct net *net, struct nfsd4_compound_state *cstate,
 			goto out;
 		if (filpp) {
 			*filpp = dp->dl_file->fi_deleg_file;
-			BUG_ON(!*filpp);
+			if (!*filpp) {
+				WARN_ON_ONCE(1);
+				status = nfserr_serverfault;
+				goto out;
+			}
 		}
 		break;
 	case NFS4_OPEN_STID:
@@ -3693,7 +3697,7 @@ static inline void nfs4_stateid_downgrade(struct nfs4_ol_stateid *stp, u32 to_ac
 	case NFS4_SHARE_ACCESS_BOTH:
 		break;
 	default:
-		BUG();
+		WARN_ON_ONCE(1);
 	}
 }
 
@@ -3882,7 +3886,7 @@ last_byte_offset(u64 start, u64 len)
 {
 	u64 end;
 
-	BUG_ON(!len);
+	WARN_ON_ONCE(!len);
 	end = start + len;
 	return end > start ? end - 1: NFS4_MAX_UINT64;
 }
@@ -4552,7 +4556,7 @@ nfs4_release_reclaim(struct nfsd_net *nn)
 			nfs4_remove_reclaim_record(crp, nn);
 		}
 	}
-	BUG_ON(nn->reclaim_str_hashtbl_size);
+	WARN_ON_ONCE(nn->reclaim_str_hashtbl_size);
 }
 
 /*
-- 
1.7.9.5

