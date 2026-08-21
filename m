Received: from mail-oi1-f178.google.com (mail-oi1-f178.google.com [209.85.167.178])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 41E81493632
	for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 16:29:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.167.178
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787329794; cv=none; b=suCgi2oJVIs/J4mgfU35pXA1pNkzvqPsBKM4ciZ2WUv07Cm7Cl3tnHSe1t6eqQYVGjI9+3U2lCLqvseLS4NX0adX9MyGRsnQVBVovL3i0us5NWvVjknSMQU9iBmb0ZtmsnDc2wdg21iquwINQ3Hibh6RaxrwuOOhqFK/BvVHIqA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787329794; c=relaxed/simple;
	bh=el+gIecwugLSH/rA+4yuVlNKm2Jg1Sj9B0AmyKoC+2M=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=i7SwPWdD65wvNfpCu/FliQWHDiBlW3wziNW7/TuduJ1JOPXd7UH0gVa3yT9AF1UgxVDI+IZOpcWo/24AE2TUKsS8DlhIPgM8Bl7hCJ3d39VvLbWK+35Y9MVVayFUqYPl5wlAZhVgfxdVJWmu9ps+AoGw7IV3aMtV2atWPMFfeWU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=dCmNdRBg; arc=none smtp.client-ip=209.85.167.178
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="dCmNdRBg"
Received: by mail-oi1-f178.google.com with SMTP id 5614622812f47-4a45b3f0becso1130685b6e.1
        for <linux-nfs@vger.kernel.org>; Fri, 21 Aug 2026 09:29:52 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1787329791; x=1787934591; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=psqB40gE6v7YL8cOMT8qsGatL24F4MBPtdr0KcGJ3ZM=;
        b=dCmNdRBgeLZl9mwr9GHXvfRRo34tOmPS8HXXVnn8xT0h2zrdgI669k16zfTs1nYga4
         RgryDHfbJdKqJL6lXxdW6zObuJWCP1LNiu3Ff7F/01EJuGPLAohI/rWkBFgd18WpEPJY
         0KMd3A46b5o1jdkGQ1OuYexlqPNW8fgz1Lr8jakxGDJMZiUSQ+iYEqjGzLFGsgZBijDU
         WB/0JXu5H8UJfNaF54TLA4nqk9CgMLuV0phj06lE3TjQxNV8zwvHs+qXXbTzYsuPrS6n
         JIgwNqnCuZmRQaqtj9YoVx8pdAGyr4CcIspjdf+um/lqjxr/t3sXi1iyuBgU64EzfiXA
         pKoQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1787329791; x=1787934591;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=psqB40gE6v7YL8cOMT8qsGatL24F4MBPtdr0KcGJ3ZM=;
        b=gz8Q4KMFMMYLEQ1AIHdoqjRaS7DRM0875J8dZuCHPZBkXwK3R+dZExBES3/OG9KLQo
         BEWWNSFKH68SX173I//M8TnECCfeDe5alguqebaJP8GuL5vUNq1OoaDIjxAOWHc/EPIy
         KpadubH0r0S8ROijdHy1qsranD8VD4DO/pZ+RypoPS2U3DD5g8XHORb80P+TYQThGd1c
         mnW8RB+Hu1RgJ8iGHVKf2EU0WOtBSrSFzme6TyF2Rxao2pOFLC9VA193bhbB/GrkPIbj
         CuOtRfr+xjvZU3KUsTHqlQVE/FNkYocLKgASHz5cux8ou8jqDuiqZ3MTipF61sT3EQPD
         dK7w==
X-Gm-Message-State: AOJu0YxkR5e2hAYfS7Vc2gq2/gU8AA+756wcQXgq5Ia0oiEm6sjZRQdd
	fpwZER0aaD8443PoX66j1L5lat8ZgSoDYOe+v7qe/Guyb79eA94J7ptuC915Qs+hK98=
X-Gm-Gg: AR+sD11DJoG3U+Bj0+ZVmI68u63zCOi8/Yks/6eN11EoFEKWP4t18L/7gHQ+BfAFFR3
	Cyt+cFNEv50RZBLHBQUxgNgn/L7CptpwfiZgPng2eLGqqH070kFh8hHhiuj70R/rAIVObcRBX/y
	hTorSQqmkp2yEsMiKhm1uPiMyriZ4N9LVGQGcvsrHLtIUwE4j6GIdwi11zquS+9eofQxC0LBCwj
	TItcknfnTSWqt8qpM3Zs8hde53ekMSECJeJBP9InDkTxUkHpxQLzs5amZ5ww0dk7U1Mj3UoqZsN
	fwHVormNZzqYdgLQcAC7ZQYfL3EvSF4cGrCJ5PMsmSN8PjZubw9LHj5o8t+Avci0SERzm5NyZnf
	sfPMZC9qYiHWlBuJKpG4MCmfRUxSZgSOKoYmbAWgabWBs6Au8O/O3AoDzv/+/azM4YicWXeYHJp
	as6yFxkxZlLqPUvtMQn49bTggJWlLBcrwo1ytgqu1pvo2pkCqfa6Irh4JnPUBARw+FGkOf/EmRJ
	lK6G5QkWOAQzbvgqJxOBMSjxPoQztNGPds=
X-Received: by 2002:a05:6808:3a10:b0:497:da7f:179a with SMTP id 5614622812f47-4b2ef4f2804mr8736886b6e.21.1787329790857;
        Fri, 21 Aug 2026 09:29:50 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4b2d6d74145sm5002916b6e.15.2026.08.21.09.29.49
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Fri, 21 Aug 2026 09:29:50 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Subject: [PATCH v2 17/23] NFSv4/pnfs: Recover revoked layouts on a deleted deviceID
Date: Fri, 21 Aug 2026 12:29:21 -0400
Message-ID: <1d38246cd2b9eb02e7ce23c19a325e6a26d11faf.1787327939.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1787327939.git.bcodding@hammerspace.com>
References: <cover.1787327939.git.bcodding@hammerspace.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

RFC 8881 Section 20.12 lets a server send CB_NOTIFY_DEVICEID DELETE for
a deviceID once it has revoked every layout referring to it.  Revocation
is not announced, so the client can still be holding what it believes
are live layouts on that deviceID.  Section 18.40.4 resolves that:
TEST_STATEID each referring layout and recover the ones that come back
revoked -- mark the layout stateid invalid, free the lsegs, FREE_STATEID
to acknowledge.

The callback thread cannot issue fore-channel RPCs, so suspects are
queued on the nfs_client (dedup'd, holding a layoutdriver reference) and
resolved by a new state-manager step keyed on NFS4CLNT_DEVICEID_DELETE.
The worker re-collects the referring layouts, so layouts returned or
recalled in the meantime are skipped.

Drop the cached device once the collected layouts account for the
delete: every one of them was revoked here.  Section 18.48.3 defines
TEST_STATEID's answers, and NFS4ERR_OLD_STATEID says the layout exists
and was not revoked -- only that it moved on after this stateid was
snapshotted -- so it counts against the delete as NFS4_OK does.  Any
other answer leaves the revocation unresolved and keeps the device
cached, as does a layout the server still considers valid (verifying
that one with GETDEVICEINFO comes next).

A layout counts as revoked only if it was invalidated here; a stateid
that no longer matches its layout is a stale snapshot.  Invalidating one
is paired with nfs_commit_inode(), since pnfs_clear_lseg_state() drops
only the VALID and LAYOUTCOMMIT references, and an lseg still held by a
commit bucket would keep the layout -- and the device nodes this
recovery is trying to release -- alive.

If the walk collects no referring layouts, the device is unreferenced
and the delete is carried out directly.  If the collection could not be
completed, recovery leaves the device cached for the next notification.

Nothing enqueues suspects yet, so no behavior change.

Assisted-by: Claude:claude-fable-5
Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
---
 fs/nfs/nfs4_fs.h          |  2 +
 fs/nfs/nfs4client.c       |  2 +
 fs/nfs/nfs4proc.c         | 83 +++++++++++++++++++++++++++++++++++++++
 fs/nfs/nfs4state.c        |  3 ++
 fs/nfs/pnfs.c             | 62 +++++++++++++++++++++++++++++
 fs/nfs/pnfs.h             | 19 +++++++++
 include/linux/nfs_fs_sb.h |  2 +
 7 files changed, 173 insertions(+)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index b48e5b87cb2a..d642aca0adc3 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -52,6 +52,7 @@ enum nfs4_client_state {
 	NFS4CLNT_RECALL_ANY_LAYOUT_READ,
 	NFS4CLNT_RECALL_ANY_LAYOUT_RW,
 	NFS4CLNT_DELEGRETURN_DELAYED,
+	NFS4CLNT_DEVICEID_DELETE,
 };
 
 #define NFS4_RENEW_TIMEOUT		0x01
@@ -493,6 +494,7 @@ int nfs41_discover_server_trunking(struct nfs_client *clp,
 			struct nfs_client **, const struct cred *);
 extern void nfs4_schedule_session_recovery(struct nfs4_session *, int);
 extern void nfs41_notify_server(struct nfs_client *);
+extern void nfs4_deviceid_delete_recover_run(struct nfs_client *clp);
 bool nfs4_check_serverowner_major_id(struct nfs41_server_owner *o1,
 			struct nfs41_server_owner *o2);
 
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 71c271a1700a..6a2f7522179c 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -217,6 +217,7 @@ struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
 	clp->cl_last_renewal = jiffies;
 	init_waitqueue_head(&clp->cl_lock_waitq);
 	INIT_LIST_HEAD(&clp->pending_cb_stateids);
+	INIT_LIST_HEAD(&clp->cl_deviceid_deletes);
 
 	if (cl_init->minorversion != 0)
 		__set_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags);
@@ -285,6 +286,7 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
 		nfs4_kill_renewd(clp);
 	clp->cl_mvops->shutdown_client(clp);
 	nfs4_destroy_callback(clp);
+	pnfs_deviceid_delete_queue_free(clp);
 	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
 		nfs_idmap_delete(clp);
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 5709c6fea85b..d115ee1dd185 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -10441,6 +10441,89 @@ static int nfs41_free_stateid(struct nfs_server *server,
 	return ret;
 }
 
+/*
+ * A DELETE for a deviceID we still hold layouts on implies the server
+ * revoked them: run the RFC 8881 Section 18.40.4 recovery.
+ */
+static void nfs4_deviceid_delete_recover(struct nfs_client *clp,
+		const struct pnfs_layoutdriver_type *ld,
+		const struct nfs4_deviceid *id)
+{
+	LIST_HEAD(layouts);
+	struct nfs4_deviceid_ref *ref;
+	bool revoked = false;
+	bool referenced = false;
+	bool inconclusive = false;
+
+	if (pnfs_layout_collect_deviceid_refs(clp, ld, id, &layouts)) {
+		/* Only a partial list -- an allocation failed, or an inode is
+		 * being evicted.  Leave the device cached and recover on a
+		 * later notification.
+		 */
+		pnfs_layout_put_deviceid_refs(&layouts);
+		return;
+	}
+
+	if (list_empty(&layouts)) {
+		nfs4_delete_deviceid(ld, clp, id);
+		return;
+	}
+
+	list_for_each_entry(ref, &layouts, node) {
+		struct pnfs_layout_hdr *lo = ref->lo;
+		struct inode *inode = ref->inode;
+		bool invalidated = false;
+		LIST_HEAD(head);
+		int status;
+
+		status = nfs41_test_stateid(NFS_SERVER(inode), &ref->stateid,
+					    ref->cred);
+		switch (status) {
+		case NFS_OK:
+		case -NFS4ERR_OLD_STATEID:
+			referenced = true;
+			break;
+		case -NFS4ERR_ADMIN_REVOKED:
+		case -NFS4ERR_DELEG_REVOKED:
+		case -NFS4ERR_EXPIRED:
+		case -NFS4ERR_BAD_STATEID:
+			spin_lock(&inode->i_lock);
+			if (pnfs_layout_is_valid(lo) &&
+			    nfs4_stateid_match_other(&ref->stateid,
+						     &lo->plh_stateid)) {
+				pnfs_mark_layout_stateid_invalid(lo, &head);
+				revoked = true;
+				invalidated = true;
+			}
+			spin_unlock(&inode->i_lock);
+			pnfs_free_lseg_list(&head);
+			if (invalidated)
+				nfs_commit_inode(inode, 0);
+			nfs41_free_stateid(NFS_SERVER(inode), &ref->stateid,
+					   ref->cred, true);
+			break;
+		default:
+			inconclusive = true;
+			break;
+		}
+	}
+	pnfs_layout_put_deviceid_refs(&layouts);
+
+	if (revoked && !referenced && !inconclusive)
+		nfs4_delete_deviceid(ld, clp, id);
+}
+
+void nfs4_deviceid_delete_recover_run(struct nfs_client *clp)
+{
+	struct nfs4_deviceid_delete *dd;
+
+	while ((dd = pnfs_deviceid_delete_dequeue(clp)) != NULL) {
+		nfs4_deviceid_delete_recover(clp, dd->ld, &dd->id);
+		pnfs_put_layoutdriver(dd->ld);
+		kfree(dd);
+	}
+}
+
 static void
 nfs41_free_lock_state(struct nfs_server *server, struct nfs4_lock_state *lsp)
 {
diff --git a/fs/nfs/nfs4state.c b/fs/nfs/nfs4state.c
index 305a772e5497..fcdb4b55c98a 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2643,6 +2643,9 @@ static void nfs4_state_manager(struct nfs_client *clp)
 				set_bit(NFS4CLNT_RUN_MANAGER, &clp->cl_state);
 			}
 			nfs4_layoutreturn_any_run(clp);
+			if (test_and_clear_bit(NFS4CLNT_DEVICEID_DELETE,
+					       &clp->cl_state))
+				nfs4_deviceid_delete_recover_run(clp);
 			clear_bit(NFS4CLNT_RECALL_RUNNING, &clp->cl_state);
 		}
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c44f5a109021..aa5dda3743f9 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -3103,6 +3103,68 @@ pnfs_layout_put_deviceid_refs(struct list_head *result)
 	}
 }
 
+/*
+ * Queue @id for the state manager's Section 18.40.4 recovery,
+ * dropping duplicates of an already-queued suspect.
+ */
+void pnfs_deviceid_delete_mark(struct nfs_client *clp,
+			       const struct pnfs_layoutdriver_type *ld,
+			       const struct nfs4_deviceid *id)
+{
+	struct nfs4_deviceid_delete *dd, *new;
+
+	new = kzalloc_obj(*new, GFP_KERNEL);
+	if (!new)
+		return;	/* lost notification; recovery waits for the next */
+	new->ld = pnfs_find_layoutdriver(ld->id);
+	if (!new->ld) {
+		kfree(new);
+		return;
+	}
+	memcpy(&new->id, id, sizeof(new->id));
+
+	spin_lock(&clp->cl_lock);
+	list_for_each_entry(dd, &clp->cl_deviceid_deletes, list) {
+		if (dd->ld == new->ld &&
+		    !memcmp(&dd->id, &new->id, sizeof(dd->id))) {
+			spin_unlock(&clp->cl_lock);
+			pnfs_put_layoutdriver(new->ld);
+			kfree(new);
+			return;
+		}
+	}
+	list_add_tail(&new->list, &clp->cl_deviceid_deletes);
+	spin_unlock(&clp->cl_lock);
+
+	set_bit(NFS4CLNT_DEVICEID_DELETE, &clp->cl_state);
+	nfs4_schedule_state_manager(clp);
+}
+
+struct nfs4_deviceid_delete *pnfs_deviceid_delete_dequeue(
+			       struct nfs_client *clp)
+{
+	struct nfs4_deviceid_delete *dd = NULL;
+
+	spin_lock(&clp->cl_lock);
+	if (!list_empty(&clp->cl_deviceid_deletes)) {
+		dd = list_first_entry(&clp->cl_deviceid_deletes,
+				      struct nfs4_deviceid_delete, list);
+		list_del(&dd->list);
+	}
+	spin_unlock(&clp->cl_lock);
+	return dd;
+}
+
+void pnfs_deviceid_delete_queue_free(struct nfs_client *clp)
+{
+	struct nfs4_deviceid_delete *dd;
+
+	while ((dd = pnfs_deviceid_delete_dequeue(clp)) != NULL) {
+		pnfs_put_layoutdriver(dd->ld);
+		kfree(dd);
+	}
+}
+
 /* Check if we have we have a valid layout but if there isn't an intersection
  * between the request and the pgio->pg_lseg, put this pgio->pg_lseg away.
  */
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 5a8c1ffee784..3149a487afb8 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -399,6 +399,25 @@ int pnfs_layout_collect_deviceid_refs(struct nfs_client *clp,
 				const struct nfs4_deviceid *id,
 				struct list_head *result);
 void pnfs_layout_put_deviceid_refs(struct list_head *result);
+
+/*
+ * A CB_NOTIFY_DEVICEID DELETE naming a deviceID that live layouts
+ * still reference (RFC 8881 Section 18.40.4).  Queued on
+ * nfs_client.cl_deviceid_deletes under cl_lock for the state manager
+ * to resolve; holds a layoutdriver reference.
+ */
+struct nfs4_deviceid_delete {
+	struct list_head list;
+	const struct pnfs_layoutdriver_type *ld;
+	struct nfs4_deviceid id;
+};
+
+void pnfs_deviceid_delete_mark(struct nfs_client *clp,
+			       const struct pnfs_layoutdriver_type *ld,
+			       const struct nfs4_deviceid *id);
+struct nfs4_deviceid_delete *pnfs_deviceid_delete_dequeue(
+			       struct nfs_client *clp);
+void pnfs_deviceid_delete_queue_free(struct nfs_client *clp);
 int pnfs_layout_handle_reboot(struct nfs_client *clp);
 
 /* nfs4_deviceid_flags */
diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
index cd3ebca61dd1..11b4a3f10c60 100644
--- a/include/linux/nfs_fs_sb.h
+++ b/include/linux/nfs_fs_sb.h
@@ -103,6 +103,8 @@ struct nfs_client {
 	/* The flags used for obtaining the clientid during EXCHANGE_ID */
 	u32			cl_exchange_flags;
 	struct nfs4_session	*cl_session;	/* shared session */
+	/* CB_NOTIFY_DEVICEID DELETE suspects, protected by cl_lock */
+	struct list_head	cl_deviceid_deletes;
 	bool			cl_preserve_clid;
 	struct nfs41_server_owner *cl_serverowner;
 	struct nfs41_server_scope *cl_serverscope;
-- 
2.53.0

