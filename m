Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4F638481AB0;
	Wed, 12 Aug 2026 18:08:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786558106; cv=none; b=OztlQK+TSacjHCYErBYszPPJxZdBogNnRVWdfrPaPmkzybSMbH9YeY0IS9/yGtHozagDgkxV0rDutKRJPTHUmSXQiOidea2nPS6KhdAZDtFNRqgQm0KTKH4bZCmNOg9b8vbwqT+hz7pbWGqea50/B80MAtwTDWgMGKeWq7n4dog=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786558106; c=relaxed/simple;
	bh=UdBXUWJ3qFYYvJ4Rc2yTan11nOfSrINI/dKKW84HkzU=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=tJl1BCWV1O9Y3Y4U2gp4FlODRaYHrRuYFsDyoLgNfkJE9URDRh3YtC4POyrheEu/iNtuykG9CEwfsSEZ+Wm+YGpSqmnhF5QhTxuM3ohyf1ljYIeNOYLc5mIcDoALozVuX5+7o0k2Fbt/lhNvTyhK+bDsorhQtfi9CbhiHTpROQc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DDvR0LMl; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DDvR0LMl"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 681D71F00A3E;
	Wed, 12 Aug 2026 18:08:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786558105;
	bh=g9Ieuc7g3+3SRGhj2KYEpURRJen+bO2L/kcR4adJznM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=DDvR0LMliOByzowuIuf2EBm9HHn/tuAK5o57F1IFRX1j00lCiK6Ze/Oxbyi+AGxVR
	 o6rD1rjqBj+Aun3GhgnxEnnCogrgi/b1HF09j3bHGxPTYU3A6fh7VmS1fVWzNvogor
	 Dee7ZTYvXuJGwVNVPUUZ+/MjcFacE/ciBoUvYceU2+ktDVtJ1+2xoQ2te2cPLLM8Ci
	 OnOMvzaPLJZ07m16SZ3+1WZ6dYeHuDBUAgZIQAqiwjS6YPRiMdFBaPW1vsq+mCT8pQ
	 dF6VUYvc7sc6gTb2KdSqn3c747bkgF9pYzev8xaOxgYej+KyCMGh+CMJee0ryXjFsu
	 ipYovgTrc0wkQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 12 Aug 2026 14:08:15 -0400
Subject: [PATCH 2/2] nfsd: back CB_NOTIFY notify_mask words with
 per-delegation storage
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260812-dir-deleg-v1-2-411faa713068@kernel.org>
References: <20260812-dir-deleg-v1-0-411faa713068@kernel.org>
In-Reply-To: <20260812-dir-deleg-v1-0-411faa713068@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3627; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=UdBXUWJ3qFYYvJ4Rc2yTan11nOfSrINI/dKKW84HkzU=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqfLaWLVWKUYA4oKbtpMImENatU4bDBM31D4DLv
 aYk5L7PVg2JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCany2lgAKCRAADmhBGVaC
 FW0FEADVqxJeUrfxw07wK36sspoiFGWeUeVpMGaDD87Xc6xncIIWFF8cnPZJF33a32eb+U5v+n/
 Tx0TuPzgM2QJmTrtHR5/QVnhhGqH+hUmlV9aGw4vKgpaieDCdTlK6aLQx2I0f4glnSI9Lmim1H3
 a/uKLqxdQQ9vwSpB42CZwmLmqlJ+qhx6nHWsYS/D5bcDdmucRXZAjOEAU1zTbKKwLz8ddvpfdA/
 lfeA8cE5Ug+vTpaz8ijb1ikH0q/bv+KkWZswMZEgu9s3O/TgGNOaxPpv2/uIOBSqc/wD7zuNsTh
 7vdlnWRyk4iD5S7ICyB/mKXv9ySQKLMFSUpkv/GEuQRLBv50L2tFMLdGgK6jASf5siSuhdJR3bq
 1q9IfB97lcH+MY3szSt4Yx3Lj9jHVQPqHA/jpGQ3VOxIgVkl3Wl4Qo8muuvkAXPX8iUXSsolaJf
 CR7hh4G4ANysI7aIt6UiMKCbK7CR11c+62DYtdfmAPpO0lFzO0up1LjIYma9ybfmUtC3n1G1wan
 asg5dgAuJRWSdwLKXFNYpVk/oyvxRlDAVDGgn7RvC9IUTlY4ZT/9U1IV5w1BAw4KC3yrJb+efdS
 9M/G8J7K2eC5JP8AJsLlOgZzzXgX5y0ytEPIDOkJ5kQ+thXvBW7BpByIBesKqBhwiohi+T2Hn3z
 VcDZFBuaIrRL78Q==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd4_cb_notify_prepare() reserved a word from the encoding xdr stream
for each notify4's host-order notify_mask, storing the pointer in
ncn_nf[].notify_mask.element. That element must survive until the RPC
encode re-reads ncn_nf, so the host-endian word lived inside the XDR
staging buffer for the whole callback lifetime - the same fragile
pattern as the attrmask, and one that keeps host-order bytes in a
buffer meant to hold big-endian XDR.

ncn_nf is a bounded per-delegation array reused across every CB_NOTIFY,
so give it a parallel ncn_masks array with the same lifetime:

- allocate/free ncn_masks alongside ncn_nf in alloc_init_dir_deleg() /
  nfs4_free_dir_deleg()
- point notify_mask.element at &ncn_masks[i] (events) and
  &ncn_masks[count] (dir attr change)

The mask backing is now pre-allocated, so the per-word NULL checks in
prepare go away. The staging stream holds only encoded XDR.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 20 +++++++++-----------
 fs/nfsd/state.h     |  1 +
 2 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 510380b6aa7a..1ba97e3f65eb 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1323,6 +1323,7 @@ static void nfs4_free_dir_deleg(struct nfs4_stid *stid)
 	for (i = 0; i < ncn->ncn_evt_cnt; ++i)
 		nfsd_notify_event_put(ncn->ncn_evt[i]);
 	kfree(ncn->ncn_nf);
+	kfree(ncn->ncn_masks);
 	for (i = 0; i < NOTIFY4_PAGE_ARRAY_SIZE; i++) {
 		if (!ncn->ncn_pages[i])
 			break;
@@ -1355,6 +1356,11 @@ alloc_init_dir_deleg(struct nfs4_client *clp, struct nfs4_file *fp)
 		nfs4_put_stid(&dp->dl_stid);
 		return NULL;
 	}
+	ncn->ncn_masks = kcalloc(NOTIFY4_EVENT_QUEUE_SIZE, sizeof(*ncn->ncn_masks), GFP_KERNEL);
+	if (!ncn->ncn_masks) {
+		nfs4_put_stid(&dp->dl_stid);
+		return NULL;
+	}
 	spin_lock_init(&ncn->ncn_lock);
 	nfsd4_init_cb(&ncn->ncn_cb, dp->dl_stid.sc_client,
 			&nfsd4_cb_notify_ops, NFSPROC4_CLNT_CB_NOTIFY);
@@ -3767,14 +3773,9 @@ nfsd4_cb_notify_prepare(struct nfsd4_callback *cb)
 		struct nfsd_notify_event *nne = events[i];
 
 		if (!error) {
-			u32 *maskp = (u32 *)xdr_reserve_space(&stream, sizeof(*maskp));
+			u32 *maskp = &ncn->ncn_masks[i];
 			u8 *p;
 
-			if (!maskp) {
-				error = true;
-				goto put_event;
-			}
-
 			p = nfsd4_encode_notify_event(&stream, nne, dp, nf, maskp);
 			if (!p) {
 				pr_notice("Could not generate CB_NOTIFY from fsnotify mask 0x%x\n",
@@ -3792,13 +3793,10 @@ nfsd4_cb_notify_prepare(struct nfsd4_callback *cb)
 		nfsd_notify_event_put(nne);
 	}
 	if (!error && (dp->dl_notify_mask & BIT(NOTIFY4_CHANGE_DIR_ATTRS))) {
-		u32 *maskp = (u32 *)xdr_reserve_space(&stream, sizeof(*maskp));
+		u32 *maskp = &ncn->ncn_masks[count];
 		u8 *p;
 
-		if (maskp)
-			p = nfsd4_encode_dir_attr_change(&stream, dp, nf);
-		else
-			p = ERR_PTR(-ENOBUFS);
+		p = nfsd4_encode_dir_attr_change(&stream, dp, nf);
 
 		if (IS_ERR(p)) {
 			/*
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index ff1c9fa731aa..c65b604e29f1 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -271,6 +271,7 @@ struct nfsd4_cb_notify {
 	struct nfsd_notify_event	*ncn_evt[NOTIFY4_EVENT_QUEUE_SIZE]; // list of events
 	struct page			*ncn_pages[NOTIFY4_PAGE_ARRAY_SIZE]; // for encoding
 	struct notify4			*ncn_nf;	// array of notify4's to be sent
+	u32				*ncn_masks;	// host-order notify_mask backing for ncn_nf[]
 	bool				ncn_encode_err;	// did encoding fail?
 	struct nfsd4_callback		ncn_cb;		// notify4 callback
 };

-- 
2.55.0

