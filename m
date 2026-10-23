Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792721423;
	b=miHvaqpqz6qifz7tpr2XL00lZk3toRdm0vR0xKnrinCz+utf3Rj+2Uciw7eHj/vLOdO8
	 e2dfwLHaLulq/jXd2PNN9wlo6y6+aJbV8me808DZOIV8vANg3v9aKomJ26tJhEJwJwODj
	 ji2wgVGUQjR1Asg5ikthHfpYO6j7ZbNFPUW6TQmew8fXqui70/ejkUQYBrzoI7K2EbKyQ
	 7HIl2Tqxon1gfpRQkwmuylST1K3kkBv6rsJc5pAF5BKWsZ/QNS7puELYVmEVeP8R0836p
	 uV7ffQskl4jm7gGTkFlCQB+XnwFtmO1RhVW/6lxdzFpGzyz4Vban87zv/hfLM5MkkpQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792721423;
	h=Received:DKIM-Signature:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Message-Id:References:In-Reply-To:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=Pwps7bMg45npWaSQsZjGkN3Qx0Hkho/rcLpuXEcHFgk=;
	b=sNvhzJbkpVXoBOOixd1lVMANl24cHKEM4qzfje3sgWtRvGt6CF0NAnGx8Y4Efw5/pXKk
	 1VCPguwKZuyy1pXT3yPtySVkqOL+S8jVM29pPFch3wydPAzI3nz34dM3/Y7pZgzWy2GbN
	 5DseEgH+21F5lnDwcQlwons5ehZp+88w3DDhAH02eXXhXJy14pvEN5Bp9Xo3SJVIMleqL
	 ke0N8UO0xUJvlCfX9FUqtJ+r74zJpvx3n27MNduNJay45RhDUU2e9CY1JTSXIgNTS0UE7
	 wg6xsloAKKPCbiW2479zIbv6LoyXcIu3S0ct4Dbd8E08yy2dwSqLwWM8wfCKbJnc4hg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="Ke/QWWo+";
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 07BEB606A319;
	Fri, 23 Oct 2026 02:10:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Ke/QWWo+
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1792721422;
	b=0JvuOXz+JNPdHvJaUzblfb8ukr4blMIam1Zly/IRaYimBDYKgqHtZfXFvzRAKy48u2w+
	 rgYXbkpw3GTOZDqje7CZWidWI+CGYyRQMqgO8/7a9XcBTD96Wkn79CAOfYZzOfUnaO+Pq
	 SRU7nnSWdTQo5tMUnSFzn7PtvVzGxdOOFxvGsmWP+NEpGAnmUloJ2aQuFVTYxDinYO+KJ
	 o0TmN72y4dewDV8hPeQZ+wUZSJlBWGMlqKb1rjxRzIvsGooo2b0IDjl1AF3+mLCYjcrpM
	 P9SkrgOSXmOOi2FG4YaPyg57wI4tD8UkNHbLef4om6+vo6t3V2quez1piCWtVh9pNgQ==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1792721422;
	h=DKIM-Signature:Received:From:Date:Subject:MIME-Version:Content-Type:
	 Message-Id:References:In-Reply-To:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=Pwps7bMg45npWaSQsZjGkN3Qx0Hkho/rcLpuXEcHFgk=;
	b=znPgesc4j28/1b/NfdmZ8L+ySg75wWALZK/nSbTiN1aEQmYwKXDx5cyiIL+LLlzR0UuT
	 JkoHriyQyDpePB6gA+Qn5YH7hMagBMUAItN6DjmHlresHoAFrvnVbvMq8xTB0ys1zndu8
	 L6Y97VZcwohXAJ2mLU41zqr9A+yWegRofYp4cbMMbUhHPiW2o2Q/dN8P7RmgpCtFIAzwO
	 gxBgnJJP6DwO8X1d6wqvjsSfdchOADx6k5RVZehVrYaPl3DpY935I3P/1Cy6zjelWGc6F
	 j1qus+jHRXg6fGnaTI+um8/iicTa7cDnF21K7/i2Q8IPbharPYRMNHhbH7VheGpXCZQ==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id D44131F031E3;
	Fri, 23 Oct 2026 02:10:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792721422;
	bh=Pwps7bMg45npWaSQsZjGkN3Qx0Hkho/rcLpuXEcHFgk=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To;
	b=Ke/QWWo+w7FWgdNjzWX8Iw8W8UC+6kzBrw2IRDkszAD9zVOuCm18VxiqWe7ohLJ+4
	 Mz1o1ugZQF+K/2zCYM7EjAqVvs33Iu/Usj3u88CZC8SPmPdw1eyaclu9eHI5NBwPE3
	 7Iw0nYF6ehwIphnRKKnt3TwyDeQCdAIcIaoJB9qzJAwRfYUuaIYCYyUbuN60fmEpTC
	 KnrkMcvgGxcRC6Sv33PV62SpY8D6/40huVSi8vyVmkGslqoa6ONDSSfrVbnXVaXUWF
	 adwD6GOHQf/C6cCKl8AdVLj9cDuCczhlDLc+b5agUzrhp1JV8W8b310dKW8GlfuFPU
	 Zmh/J86xcwqaQ==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id 5D35B4219E;
	Fri, 23 Oct 2026 02:10:21 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Fri, 23 Oct 2026 11:10:25 +0900
Subject: [PATCH v2 4/4] nfsd: do not fail a LAYOUTGET on a lease break by
 the same client
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Message-Id: <20261023-nfsd-layout-refcall-v2-4-2160bddced0c@samsung.com>
References: <20261023-nfsd-layout-refcall-v2-0-2160bddced0c@samsung.com>
In-Reply-To: <20261023-nfsd-layout-refcall-v2-0-2160bddced0c@samsung.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, 
 Benjamin Coddington <ben.coddington@hammerspace.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1792721421; l=13186;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=KnGMB0uW//H10UcDvkCS6Dac/ufCUyYjUaxjBYG9z24=;
 b=pWzAds3HSNTZ2WaEF7+ROG0f0iL7A9t+d3zZDZPPEpHYfvfeAZDM0nOc8bfXqx0XML7VVQ7rp
 OkCa60zUa2GD0rXsHGoBn6Nhp0iwQiOkGb77BypWj5TfrgqjOyCCole
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com
Content-Transfer-Encoding: 7bit

From: Daejun Park <daejun7.park@samsung.com>

"nfsd: fail a LAYOUTGET in progress when the layout lease is broken"
fails a LAYOUTGET whose layout stateid has no layouts yet when the lease
is broken, so that no layout is handed out after the break without a
recall. Since "nfsd: answer NFS4ERR_DELAY instead of waiting for a
layout recall", a WRITE through the metadata server that meets a layout
of its own client gets NFS4ERR_DELAY, and the Linux client resends it
every 0.1 seconds; a resend breaks the lease of any LAYOUTGET that the
same client has in progress. A client that writes through the metadata
server while it does I/O through a layout of the same file, as the Linux
client does for O_DIRECT writes that are not aligned to a page, then
gets NFS4ERR_RECALLCONFLICT for LAYOUTGET after LAYOUTGET, and waits up
to 15 seconds between them.

When the break comes from a request of the client that holds the layout
stateid, nfsd4_break_file_layout() notes that the break met a LAYOUTGET
in progress and when the break times out (fl_break_time), and
nfsd4_insert_layout() recalls the layout as soon as it adds it. The
LAYOUTGET succeeds and the client is asked for the layout back at once.
nfsd4_layout_breaker_is_holder() finds the client of the breaker as
nfsd_breaker_owns_lease() does for delegations. The layout is still
recalled: a write through the metadata server can change the block
mapping that the layout describes. A break by another client or by a
local process fails the LAYOUTGET as before, and the conflicting
operation goes ahead without waiting for a recall, unless a break by the
holder came first. The new case is traced as nfsd_layout_break_pending.

A LAYOUTGET that would add its layout after the break has timed out
fails as before, whether or not the timeout has been noticed yet:
time_out_leases() notices it only when another lease operation on the
file comes, and a layout added in between would be recalled when it is
already due and have its client fenced if that operation comes before
the layout is back. When the timeout is noticed first,
nfsd4_layout_lm_breaker_timedout() marks the layout stateid recalled, so
that the LAYOUTGET fails. A layout added shortly before the break times
out is recalled with what is left of fs.lease-break-time, and its client
is fenced if it does not return the layout by then, where the LAYOUTGET
failed before this patch. With the default of 45 seconds that takes a
LAYOUTGET that has been in progress for most of that time.

The recall is queued before the LAYOUTGET reply is sent and can reach
the client first; a client that answers NFS4ERR_NOMATCHING_LAYOUT then
would have its layout thrown away while it uses it. The resent recall of
"nfsd: resend a layout recall once before trusting NOMATCHING_LAYOUT"
and the referring call that CB_LAYOUTRECALL carries since "nfsd: send a
referring call with CB_LAYOUTRECALL" cover that, for a client that takes
the reply in within about three seconds or holds the recall back, which
is why this comes after them. A recall that cannot be sent because the
backchannel is down ends at once and drops the layouts, as any layout
recall does today; with this patch that can take the layout that the
LAYOUTGET is handing out.

One client writing 1 MiB blocks with O_DIRECT through its block layout
and 512 bytes at the middle of a page through the metadata server to the
same file, for 30 seconds: before this patch 51, 54 and 12 of the 1 MiB
writes were done in three runs, as the LAYOUTGETs failed and the client
backed off; with it 240, 249 and 244, with no 1 MiB block lost. The 512
byte writes went from 5172, 5137 and 7589 to 1473, 1214 and 1397: the
client now holds a layout most of the time, and such a WRITE meets it
and gets NFS4ERR_DELAY. The same change without the two patches above
lost 75 of 600, 79 of 589 and 87 of 600 blocks.

With fs.lease-break-time at one second and a test-only delay before
nfsd4_insert_layout(), a 512 byte write through the metadata server 0.3
seconds into the LAYOUTGET broke the lease and was resent every 0.1
seconds; the first resend after the break timed out came 37 to 44 ms
after it. A layout added 25 to 29 ms before the break timed out was
recalled at once and returned in each of five runs, without fencing.
LAYOUTGETs that would add their layout about 17 or 30 ms after the break
had timed out, before that resend, failed with NFS4ERR_RECALLCONFLICT in
each of five runs at each offset. With the test of the deadline taken
out, they handed the layout out. At 17 ms the client returned it before
the resend in each of five runs, and nothing was fenced; at 30 ms the
resend timed the break out while the client still held the layout, and
had it fenced, in four of five, and came first in the fifth.

With a test-only delay of three seconds and a local write on the server
that breaks the lease during that delay and goes ahead one second later,
the LAYOUTGET fails with NFS4ERR_RECALLCONFLICT with this patch in each
of three runs: a local process is not the holder, so this patch leaves
that case alone. With another client breaking the lease, as in the test
of "nfsd: resend a layout recall once before trusting NOMATCHING_LAYOUT"
without the delay, the 1 MiB writes went on with the whole series as
without it, 600 blocks in each of three runs of 30 seconds, and no
recall overtook a reply; without the series, one did in one of three
runs, and that block read back as zeroes.

No Fixes: tag, as "nfsd: fail a LAYOUTGET in progress when the layout
lease is broken" is not upstream yet. Where that patch is backported,
this one is needed too, but only together with the two patches before
it, so only where "NFSD: Send referring calls with CB_RECALL" and its
series are, and not before v7.1.

Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
 fs/nfsd/nfs4layouts.c | 81 ++++++++++++++++++++++++++++++++++++++++++++-------
 fs/nfsd/state.h       | 11 +++++++
 fs/nfsd/trace.h       |  1 +
 3 files changed, 82 insertions(+), 11 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 7a0353149e..c797bc7d93 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -336,6 +336,8 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
 	}
 
 	ls->ls_recall_start = 0;
+	ls->ls_break_pending = false;
+	ls->ls_break_time = 0;
 	ls->ls_fenced = false;
 	ls->ls_fence_inflight = false;
 	ls->ls_fence_stopped = false;
@@ -459,16 +461,42 @@ nfsd4_recall_file_layout(struct nfs4_layout_stateid *ls)
 	spin_unlock(&ls->ls_lock);
 }
 
+/* Whether the lease break comes from a request of the client of @ls */
+static bool
+nfsd4_layout_breaker_is_holder(const struct nfs4_layout_stateid *ls)
+{
+	struct svc_rqst *rqstp = nfsd_current_rqst();
+	struct nfsd_thread_local_info *ntli;
+
+	if (!nfsd_v4client(rqstp))
+		return false;
+	ntli = rqstp->rq_private;
+	return *ntli->ntli_lease_breaker == ls->ls_stid.sc_client;
+}
+
 /*
- * A layout stateid with no layouts belongs to a LAYOUTGET in progress
- * and already holds the lease. Mark the stateid recalled so that
- * nfsd4_insert_layout() fails the LAYOUTGET and the lease is released.
+ * A lease break also has to reach a LAYOUTGET in progress, whose layout
+ * stateid holds the lease but has no layouts yet. Mark the stateid
+ * recalled so that nfsd4_insert_layout() fails the LAYOUTGET and the
+ * lease is released. When the break comes from a request of the same
+ * client, as a WRITE through the metadata server that the Linux client
+ * sends next to its I/O through the layout, failing its LAYOUTGET would
+ * have it back off and fail again: note the break and its deadline
+ * instead, and let nfsd4_insert_layout() recall the layout as soon as it
+ * adds it, unless the break is past its deadline by then.
+ * ->lm_break() is not called again for a lease that is already breaking.
  */
 static void
-nfsd4_break_file_layout(struct nfs4_layout_stateid *ls)
+nfsd4_break_file_layout(struct nfs4_layout_stateid *ls,
+			unsigned long break_time)
 {
 	spin_lock(&ls->ls_lock);
-	if (!ls->ls_recalled && list_empty(&ls->ls_layouts)) {
+	if (!ls->ls_recalled && list_empty(&ls->ls_layouts) &&
+	    nfsd4_layout_breaker_is_holder(ls)) {
+		ls->ls_break_pending = true;
+		ls->ls_break_time = break_time;
+		trace_nfsd_layout_break_pending(&ls->ls_stid.sc_stateid);
+	} else if (!ls->ls_recalled && list_empty(&ls->ls_layouts)) {
 		ls->ls_recalled = true;
 		atomic_inc(&ls->ls_stid.sc_file->fi_lo_recalls);
 		trace_nfsd_layout_recall_empty(&ls->ls_stid.sc_stateid);
@@ -478,6 +506,18 @@ nfsd4_break_file_layout(struct nfs4_layout_stateid *ls)
 	spin_unlock(&ls->ls_lock);
 }
 
+/*
+ * Whether the lease break noted by nfsd4_break_file_layout() is past its
+ * deadline. A layout added now would be recalled too late, whether or
+ * not time_out_leases() has noticed the timeout yet.
+ */
+static bool
+nfsd4_layout_break_expired(const struct nfs4_layout_stateid *ls)
+{
+	return ls->ls_break_pending && ls->ls_break_time &&
+	       time_after(jiffies, ls->ls_break_time);
+}
+
 static inline u64
 layout_end(struct nfsd4_layout_seg *seg)
 {
@@ -553,7 +593,7 @@ nfsd4_insert_layout(struct nfsd4_layoutget *lgp, struct nfs4_layout_stateid *ls)
 	if (nfserr)
 		goto out;
 	spin_lock(&ls->ls_lock);
-	if (ls->ls_recalled) {
+	if (ls->ls_recalled || nfsd4_layout_break_expired(ls)) {
 		nfserr = nfserr_recallconflict;
 		goto out_unlock_ls;
 	}
@@ -575,7 +615,7 @@ nfsd4_insert_layout(struct nfsd4_layoutget *lgp, struct nfs4_layout_stateid *ls)
 	if (nfserr)
 		goto out;
 	spin_lock(&ls->ls_lock);
-	if (ls->ls_recalled) {
+	if (ls->ls_recalled || nfsd4_layout_break_expired(ls)) {
 		nfserr = nfserr_recallconflict;
 		goto out_unlock_ls;
 	}
@@ -589,6 +629,10 @@ nfsd4_insert_layout(struct nfsd4_layoutget *lgp, struct nfs4_layout_stateid *ls)
 	new = NULL;
 done:
 	nfs4_inc_and_copy_stateid(&lgp->lg_sid, &ls->ls_stid);
+	if (ls->ls_break_pending) {
+		ls->ls_break_pending = false;
+		nfsd4_recall_file_layout_locked(ls);
+	}
 out_unlock_ls:
 	spin_unlock(&ls->ls_lock);
 out:
@@ -1182,7 +1226,7 @@ nfsd4_layout_lm_break(struct file_lease *fl)
 	 * Enforce break lease timeout to prevent NFSD
 	 * thread from hanging in __break_lease.
 	 */
-	nfsd4_break_file_layout(fl->c.flc_owner);
+	nfsd4_break_file_layout(fl->c.flc_owner, fl->fl_break_time);
 	return false;
 }
 
@@ -1373,7 +1417,9 @@ static void nfsd4_layout_fence_worker(struct work_struct *work)
  *
  * Schedule a worker to fence the client from accessing the block device.
  * If the layout type has no fence operation, the worker runs the fence
- * script instead.
+ * script instead. If a lease break of its own client met the LAYOUTGET
+ * of a layout stateid that has no layouts yet, mark it recalled instead,
+ * so that the LAYOUTGET fails.
  *
  * This function runs under the protection of the spin_lock flc_lock.
  * At this time, the file_lease associated with the layout stateid is
@@ -1413,8 +1459,21 @@ nfsd4_layout_lm_breaker_timedout(struct file_lease *fl)
 		spin_unlock(&ls->ls_lock);
 		return false;
 	}
-	if (list_empty(&ls->ls_layouts) ||
-			!refcount_inc_not_zero(&ls->ls_stid.sc_count)) {
+	if (list_empty(&ls->ls_layouts)) {
+		/*
+		 * The lease goes away and the conflicting operation goes
+		 * ahead, so a LAYOUTGET that the break met must not add a
+		 * layout any more: fail it as nfsd4_insert_layout() fails one
+		 * on a recalled layout stateid.
+		 */
+		if (ls->ls_break_pending && !ls->ls_recalled) {
+			ls->ls_recalled = true;
+			atomic_inc(&ls->ls_stid.sc_file->fi_lo_recalls);
+		}
+		spin_unlock(&ls->ls_lock);
+		return true;
+	}
+	if (!refcount_inc_not_zero(&ls->ls_stid.sc_count)) {
 		spin_unlock(&ls->ls_lock);
 		return true;
 	}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 5cf3a5ac46..ec325825d7 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -876,6 +876,17 @@ struct nfs4_layout_stateid {
 	/* The client has answered NFS4_OK to the recall */
 	bool				ls_recall_accepted;
 	bool				ls_recalled;
+	/*
+	 * A lease break of this client met a LAYOUTGET in progress: recall
+	 * the layout it adds, or fail it once the break is past its time.
+	 * Under ls_lock.
+	 */
+	bool				ls_break_pending;
+	/*
+	 * fl_break_time of that break: 0 if it does not time out.
+	 * Under ls_lock.
+	 */
+	unsigned long			ls_break_time;
 	struct mutex			ls_mutex;
 	/*
 	 * The latest NFSD4_LAYOUT_MAX_GRANTS LAYOUTGETs that added a
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index a2c21d491a..2110e95ee1 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -829,6 +829,7 @@ DEFINE_STATEID_EVENT(layout_commit_lookup_fail);
 DEFINE_STATEID_EVENT(layout_return_lookup_fail);
 DEFINE_STATEID_EVENT(layout_recall);
 DEFINE_STATEID_EVENT(layout_recall_empty);
+DEFINE_STATEID_EVENT(layout_break_pending);
 DEFINE_STATEID_EVENT(layout_recall_done);
 DEFINE_STATEID_EVENT(layout_recall_resend);
 DEFINE_STATEID_EVENT(layout_recall_new_seqid);

-- 
2.43.0


