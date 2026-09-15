Received: from mail-oi2-f13.google.com (mail-oi2-f13.google.com [74.125.231.205])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B90D33B95FA
	for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 12:22:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=74.125.231.205
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789474975; cv=none; b=FautgWfigsEPMtKUomyXsBqc2bWMWKboKkkpI+xH46/pP6Yk9OqyidoKZHMeTcLQm9C8Zc/fNoR4k/PtUb1Ytvi53AXbBAC2X4LMmbHI+HLTgYzk/T6libwDdN6v9lJ8yE4QTZrJ6f6lhqvq9S5LoUrmqA7Ht+F4++UVs5Lczi8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789474975; c=relaxed/simple;
	bh=sJcZKwks/D9sFCru/7r/xrExlAU1Qi9b+83ToKTrHXY=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=emNkOfrsdjsMIsQYajMr/zTHaOfDz8X6DL8AOvNv04bPKX+mSgbAoQAwvjc3iSmL2CGEn5YaGLRATxZCxPJNi/d0Keh3dvxo9pu3HgXGew7fCMUcS9czOa10t3ZbJTMOLrmx4ytKkKKT/WAIBouQ3aaRMiry/IHNBcFzQ6A+6eg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com; spf=pass smtp.mailfrom=hammerspace.com; dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b=UkcPkAa5; arc=none smtp.client-ip=74.125.231.205
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=hammerspace.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=hammerspace.com header.i=@hammerspace.com header.b="UkcPkAa5"
Received: by mail-oi2-f13.google.com with SMTP id 5614622812f47-4c2c08ff3f8so2051929b6e.1
        for <linux-nfs@vger.kernel.org>; Tue, 15 Sep 2026 05:22:53 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=hammerspace.com; s=google; t=1789474972; x=1790079772; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=UVLvekJrgF7oTGzHRPsrWUALy1FkjWASFHcdVeiIXmM=;
        b=UkcPkAa58PlX6bVXonm9ALUJz2eVS9XS+7/VtWFY/g2EcgLIKb+ImVyno0EgB5lMSS
         hH6rwt43sd6j8mS2I7FdzB4g74qUpOhisSva5nY0OWnqtkOFiVa86nNbIX/mKyQwQxjt
         AU8GA9/6jzQuBylez7POa2EgigMNYkLhsrDT89XaeWduVTW4Da1ajAynMTIUymR6CwPQ
         OtNzMKQJ5Vmgrc7CT1/rGby9/Hl1wZtd+o3T1pUNebd1mGXIRaX9TyIczclNmezmu3fI
         rLyXABTJA2MXyjv8zJl62Rm+4ApIr2VxBKIYQuu4HoJvxiFHPNYFZVHyxdT9LIri5Qn4
         NW6Q==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1789474972; x=1790079772;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=UVLvekJrgF7oTGzHRPsrWUALy1FkjWASFHcdVeiIXmM=;
        b=JjglAMWhrWFMO6Pud3iI28CNDC1+Ozi7EvhIBraGc8OfF89B33WS4nLcjk2La7+OrV
         8uqCvfX4k3X9qr1k6s7bH5M9Qw0og0wAcPbOsVguNID7tJCD9VA4+M/gb5vIISzmXEjF
         6LEiobfYUBnn2rH1OqWD0EjLE6s/vBI57AKaszsEjydS4dZ/LcdVMkVTXaXrwnSWR12d
         q1PJP4AzwNSEr7i9I0+VdrzBIMtLBSTdez5dQtBYuR24xnEiLENXYqa/qvdeVV9q116I
         xE8IszVl9epbiTOS6dUrTo+To/ZsHjro85T+jAGm5PaKYdYvPoUBbm5yhS7BGejxVkgV
         3+jA==
X-Gm-Message-State: AFuF++mDjkA3fUxt/DxDM6RngG8U5fsQEpzRaJq76mO3IVHzSanSWDnc
	n3DCbJB5cH76NCt11u36VZZlqTaz/3GVZ6q75I8IqFkJaBGbUW5c5jcXc9JGYIzDmzw=
X-Gm-Gg: AYBFou3I/ViN9HYFBjTf3Fv7fin+UG1cqRNCEyVY37IBshR1Gbo8vygXU4sTdpEJI0D
	BzXU00lOTSu/bOsfKl6a09PqPEv3W5TEzCPcEuN0pXRZ3l45zxdrUbjMlfuhTBhhnfDa9u+a/5j
	CLQw6jFMuPtjaGv1NfkQEb+SmCYKCvwNWujpO/wcG7euQF4tM3qHpjFbKDnF5anZ2X17vh5aloC
	4vkB5bjqu1lIjAdKItCCZqAZ/EBucS8HlZjfZhyDVhu68TmNMY6HUPWPnIBY0839avSMFz+HFKN
	ohf7SuR2x5xP6q39AnYQPlu3aGWYdG81zsfVv1jKotAu/bXwL9fFMHtQdYOr6L2iXGjavZ/Fd6T
	KceS+LO5T5O8hzPP10AtV9bNGcLSzHdFsqX8OmHkoPo4ZqS5guBM5lehK/z1YCbkwbLyX6rWCpY
	RLvbniUcGqncOn6IKr5C7J1RmVtuwPjAmGBEREFE5UMsvXcn/AXDUTgmGl9oHpB4vUUIdsgRotI
	dntHp9wlFe3L2vgXFznNnaLrThbFsBkwJE=
X-Received: by 2002:a05:6808:17a3:b0:4b9:a829:f017 with SMTP id 5614622812f47-4c7b5c8f7c2mr4714543b6e.35.1789474972351;
        Tue, 15 Sep 2026 05:22:52 -0700 (PDT)
Received: from bcodding.csb.hammerspace.com ([66.97.168.37])
        by smtp.gmail.com with ESMTPSA id 5614622812f47-4c32eb4274dsm13058260b6e.1.2026.09.15.05.22.51
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Tue, 15 Sep 2026 05:22:51 -0700 (PDT)
From: Benjamin Coddington <ben.coddington@hammerspace.com>
X-Google-Original-From: Benjamin Coddington <bcodding@hammerspace.com>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org,
	Jonathan Curley <jcurley@purestorage.com>,
	Mike Snitzer <snitzer@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Junrui Luo <moonafterrain@outlook.com>
Subject: [PATCH v4 18/24] NFSv4/pnfs: Recover revoked layouts on a deleted deviceID
Date: Tue, 15 Sep 2026 08:22:20 -0400
Message-ID: <56e0409ccfbbc061d6ab0726a1b19c7dc2f2e09c.1789474702.git.bcodding@hammerspace.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <cover.1789474702.git.bcodding@hammerspace.com>
References: <cover.1789474702.git.bcodding@hammerspace.com>
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
index b661f446ea49..e6a589913666 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -217,6 +217,7 @@ struct nfs_client *nfs4_alloc_client(const struct nfs_client_initdata *cl_init)
 	clp->cl_last_renewal = jiffies;
 	init_waitqueue_head(&clp->cl_lock_waitq);
 	INIT_LIST_HEAD(&clp->pending_cb_stateids);
+	INIT_LIST_HEAD(&clp->cl_deviceid_deletes);
 
 	if (cl_init->minorversion != 0)
 		__set_bit(NFS_CS_INFINITE_SLOTS, &clp->cl_flags);
@@ -286,6 +287,7 @@ static void nfs4_shutdown_client(struct nfs_client *clp)
 		nfs4_kill_renewd(clp);
 	clp->cl_mvops->shutdown_client(clp);
 	nfs4_destroy_callback(clp);
+	pnfs_deviceid_delete_queue_free(clp);
 	if (__test_and_clear_bit(NFS_CS_IDMAP, &clp->cl_res_state))
 		nfs_idmap_delete(clp);
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 04b1987115d5..02df5f4f5d84 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -10498,6 +10498,89 @@ static int nfs41_free_stateid(struct nfs_server *server,
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
index a5dec0473e22..1faf9dafd331 100644
--- a/fs/nfs/nfs4state.c
+++ b/fs/nfs/nfs4state.c
@@ -2669,6 +2669,9 @@ static void nfs4_state_manager(struct nfs_client *clp)
 				set_bit(NFS4CLNT_RUN_MANAGER, &clp->cl_state);
 			}
 			nfs4_layoutreturn_any_run(clp);
+			if (test_and_clear_bit(NFS4CLNT_DEVICEID_DELETE,
+					       &clp->cl_state))
+				nfs4_deviceid_delete_recover_run(clp);
 			clear_bit(NFS4CLNT_RECALL_RUNNING, &clp->cl_state);
 		}
 
diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5ddc57b7db57..ade314de1738 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -3101,6 +3101,68 @@ pnfs_layout_put_deviceid_refs(struct list_head *result)
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
index 8dd892d875e3..18ea4e8e0d85 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -400,6 +400,25 @@ int pnfs_layout_collect_deviceid_refs(struct nfs_client *clp,
 				const struct nfs4_deviceid *devid,
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

