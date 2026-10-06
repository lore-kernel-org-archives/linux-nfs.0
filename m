Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1FC7B37269C;
	Tue,  6 Oct 2026 04:29:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791260984; cv=none; b=M2elHDVk3Mn7Q+fzL2aeHx0JXdnnUrX2gudm5HWgRxgPz4cvIsJAL8WPcng31/Gm4p6FgfXUN7bC0AqRDFMUSNOY9ycpVg/bW4PzyYTpk+8oLnNaKzFYMhSNduq20LTC5LecAFBup1/prmiotYqp5LW6pOb7ZZ+QYLOONPOozOM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791260984; c=relaxed/simple;
	bh=DHRpGIf/piIbW21nHa0ssqgVIvc8t/Dl3k5jjuCEwU0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=JtBwknzxLmkMXbDGL0wFvuKLYx7rn3taizAd25tzh0yjJ0VSpOAZk/tU9BrhCTtmHKXUM0C3KePBQCkAhZW/sLABlGQV+UP/Tp8NQghriAXMfJHhF+jw78bKACMWubROpnq81FfBqeoxQ5SAssQ54QldKAE1jpVTRSk2vKxBgvs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BE8Hg926; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BE8Hg926"
Received: by smtp.kernel.org (Postfix) with ESMTPS id 9B53CC4DDE4;
	Tue,  6 Oct 2026 04:29:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1791260983;
	bh=DHRpGIf/piIbW21nHa0ssqgVIvc8t/Dl3k5jjuCEwU0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To:From;
	b=BE8Hg926l1qnug8YOjtGMLXOmn6RqIaKkyXdr+L0f6OqaKfdTDQ5aCfAoAvXXVohG
	 4q4E6KevxTm3C18CUXyltJNGSipm+bQtUnGszIM2jfQJUdN33FIPSnf4cfYuwzUT06
	 mFmT/WnPDFFrWF2V5jd8aF8p/Xu1jKXzGbZp6DcTkV7Onl59+UKZa1xYclquSFVmkW
	 sGzBn3kerajclOCOm62pfQF7+TsA9xBVFdgEQjbI+2eir5W4MZZU5B4qtGw5UHM+To
	 K2NWBL6NhlFGTsM7I5kITiB7/ZpiUX5e3lUjZiOUNhaljLc/W5+Zo1d9EIq8Nfyp5x
	 DHvcTETEOSIqg==
Received: from aws-us-west-2-korg-lkml-1.web.codeaurora.org (localhost.localdomain [127.0.0.1])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8A19BCA5FF0;
	Tue,  6 Oct 2026 04:29:43 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Tue, 06 Oct 2026 13:29:46 +0900
Subject: [PATCH 4/6] nfsd: fail a LAYOUTGET in progress when the layout
 lease is broken
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261006-nfsd-layout-recall-v1-4-b59b31caf342@samsung.com>
References: <20261006-nfsd-layout-recall-v1-0-b59b31caf342@samsung.com>
In-Reply-To: <20261006-nfsd-layout-recall-v1-0-b59b31caf342@samsung.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, 
 Benjamin Coddington <bcodding@redhat.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1791260982; l=6838;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=7f9ITAOikWRbtOMoLGo7YDTKy1S9+l4nlC9NSOuBx84=;
 b=te15T75xTKa7A7hzUWM93hc0jzeDaNtTpQQLEBeTjYqtqgRf2SwgtKzfpZhFlvKVxck05yKaO
 fUeTJmqJMWkDsm0h/osve8A/7in4O20uCC4tDT4LJRkyVfi6LdiHXfO
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com

From: Daejun Park <daejun7.park@samsung.com>

A layout stateid takes its FL_LAYOUT lease when it is allocated, before
the first layout is added to it.  When the lease is broken in between,
nfsd4_recall_file_layout() finds no layouts and does nothing.  The
LAYOUTGET then hands out a layout that is not recalled: the lease is
already marked as breaking, so ->lm_break() is not called for it again.
The breaker waits until the client gives the layout up by itself or the
lease break time is over; with the SCSI layout the client is then
fenced although it was never sent a recall.  While the breaker waits,
kernel_setlease() fails for new layout stateids and the LAYOUTGETs of
other clients get NFS4ERR_DELAY.

Commit c5c707f96fc9 ("nfsd: implement pNFS layout recalls") marked such
a layout stateid as recalled, and since nothing kept the LAYOUTGET from
adding its layout afterwards, that layout was never recalled.  Commit
fb610c4dbc99 ("nfsd: fix race to check ls_layouts") therefore made the
recall skip a layout stateid without layouts, which left the case
above.

Let the lease break mark such a layout stateid as recalled again, and
make nfsd4_insert_layout() refuse to add layouts to a recalled layout
stateid, which is what was missing the first time.  The LAYOUTGET fails
with NFS4ERR_RECALLCONFLICT, the layout stateid is freed and the lease
goes away.  No callback is sent for it; the new
nfsd_layout_recall_empty tracepoint shows where fi_lo_recalls was
raised without one.  NFS4ERR_RECALLCONFLICT is what nfsd already answers
to a LAYOUTGET for a file with a recall in progress, also when the
recall went to another client (RFC 8881 section 15.1.14.3: "a
conflicting recall operation that is currently in progress for that
object").  The check in nfsd4_insert_layout() also covers a
layout stateid with layouts that is recalled between the checks in
nfsd4_layoutget() and nfsd4_insert_layout().

Only a lease break does this.  A LAYOUTGET that finds a layout stateid
without layouts of another client leaves it alone, as before.

The window is the time a LAYOUTGET needs from allocating the layout
stateid to inserting the layout.

Two clients writing to one file while the server writes 4 KiB to it
every 50 ms, for 30 seconds, block layout.  Without this patch one
write on the server took 9.7 seconds in one run and 13.9 seconds in
another, in both until the clients were done; in a third run it did not
happen.  With this patch the longest write on the server took 56 ms.

To see the new path at work, a delay of 100 ms was added to LAYOUTGET
between the two steps for one pair of runs.  Without the patch the
second write on the server took 30 seconds, the whole run.  With it the
longest write took 108 ms and nfsd_layout_recall_empty fired 16 times.
(With that delay every LAYOUTGET meets a write on the server, so the
clients got no layout in that run.  It shows the path and nothing else.)

Fixes: c5c707f96fc9 ("nfsd: implement pNFS layout recalls")

Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
 fs/nfsd/nfs4layouts.c | 49 +++++++++++++++++++++++++++++++++++++++++++------
 fs/nfsd/trace.h       |  1 +
 2 files changed, 44 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 3d288649c..66f79e4e4 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -337,14 +337,15 @@ nfsd4_preprocess_layout_stateid(struct svc_rqst *rqstp,
 }
 
 static void
-nfsd4_recall_file_layout(struct nfs4_layout_stateid *ls)
+nfsd4_recall_file_layout_locked(struct nfs4_layout_stateid *ls)
 {
-	spin_lock(&ls->ls_lock);
+	lockdep_assert_held(&ls->ls_lock);
+
 	if (ls->ls_recalled)
-		goto out_unlock;
+		return;
 
 	if (list_empty(&ls->ls_layouts))
-		goto out_unlock;
+		return;
 
 	ls->ls_recalled = true;
 	atomic_inc(&ls->ls_stid.sc_file->fi_lo_recalls);
@@ -354,7 +355,34 @@ nfsd4_recall_file_layout(struct nfs4_layout_stateid *ls)
 		refcount_inc(&ls->ls_stid.sc_count);
 		nfsd4_run_cb(&ls->ls_recall);
 	}
-out_unlock:
+}
+
+static void
+nfsd4_recall_file_layout(struct nfs4_layout_stateid *ls)
+{
+	spin_lock(&ls->ls_lock);
+	nfsd4_recall_file_layout_locked(ls);
+	spin_unlock(&ls->ls_lock);
+}
+
+/*
+ * A lease break also has to stop a LAYOUTGET that is in progress.  Its
+ * layout stateid has the lease and no layouts yet, so there is nothing to
+ * recall, and the breaker goes on once that layout stateid is gone.  Mark it
+ * as recalled without sending a callback: nfsd4_insert_layout() then fails
+ * the LAYOUTGET instead of handing out a layout after the break.
+ */
+static void
+nfsd4_break_file_layout(struct nfs4_layout_stateid *ls)
+{
+	spin_lock(&ls->ls_lock);
+	if (!ls->ls_recalled && list_empty(&ls->ls_layouts)) {
+		ls->ls_recalled = true;
+		atomic_inc(&ls->ls_stid.sc_file->fi_lo_recalls);
+		trace_nfsd_layout_recall_empty(&ls->ls_stid.sc_stateid);
+	} else {
+		nfsd4_recall_file_layout_locked(ls);
+	}
 	spin_unlock(&ls->ls_lock);
 }
 
@@ -433,6 +461,10 @@ nfsd4_insert_layout(struct nfsd4_layoutget *lgp, struct nfs4_layout_stateid *ls)
 	if (nfserr)
 		goto out;
 	spin_lock(&ls->ls_lock);
+	if (ls->ls_recalled) {
+		nfserr = nfserr_recallconflict;
+		goto out_unlock_ls;
+	}
 	list_for_each_entry(lp, &ls->ls_layouts, lo_perstate) {
 		if (layouts_try_merge(&lp->lo_seg, seg))
 			goto done;
@@ -451,6 +483,10 @@ nfsd4_insert_layout(struct nfsd4_layoutget *lgp, struct nfs4_layout_stateid *ls)
 	if (nfserr)
 		goto out;
 	spin_lock(&ls->ls_lock);
+	if (ls->ls_recalled) {
+		nfserr = nfserr_recallconflict;
+		goto out_unlock_ls;
+	}
 	list_for_each_entry(lp, &ls->ls_layouts, lo_perstate) {
 		if (layouts_try_merge(&lp->lo_seg, seg))
 			goto done;
@@ -461,6 +497,7 @@ nfsd4_insert_layout(struct nfsd4_layoutget *lgp, struct nfs4_layout_stateid *ls)
 	new = NULL;
 done:
 	nfs4_inc_and_copy_stateid(&lgp->lg_sid, &ls->ls_stid);
+out_unlock_ls:
 	spin_unlock(&ls->ls_lock);
 out:
 	spin_unlock(&fp->fi_lock);
@@ -794,7 +831,7 @@ nfsd4_layout_lm_break(struct file_lease *fl)
 	 * Enforce break lease timeout to prevent NFSD
 	 * thread from hanging in __break_lease.
 	 */
-	nfsd4_recall_file_layout(fl->c.flc_owner);
+	nfsd4_break_file_layout(fl->c.flc_owner);
 	return false;
 }
 
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index ad106d627..78f682bfd 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -679,6 +679,7 @@ DEFINE_STATEID_EVENT(layout_get_lookup_fail);
 DEFINE_STATEID_EVENT(layout_commit_lookup_fail);
 DEFINE_STATEID_EVENT(layout_return_lookup_fail);
 DEFINE_STATEID_EVENT(layout_recall);
+DEFINE_STATEID_EVENT(layout_recall_empty);
 DEFINE_STATEID_EVENT(layout_recall_done);
 DEFINE_STATEID_EVENT(layout_recall_fail);
 DEFINE_STATEID_EVENT(layout_recall_release);

-- 
2.43.0


