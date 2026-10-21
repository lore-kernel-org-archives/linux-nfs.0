Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792544586;
	b=jPJ4JdbCslsQAE0pO50rX8B7HA88PjC2HsYzZ/9obbWabdmr+RTufkt4sEf3Kh6/Siou
	 ZFC3pn9RgkA12iM+aK7k+DDxXeyTi9fAzH0o1ogegnuvY0WUrteAnbszIGa5EboLtWvIv
	 LbalvrBqdGpOjbnrLD2GDjM3vyZ8LWq0ncbRyyqVK4yfSBMW4Ivg/4SHb/FeM/bNK2vk0
	 WBSbb/gToUV0+Bcf6t6bSBD1ZAkrxU93iRwjHhZtWeLOCfYxEJMHy1/w/zzuiTGduInXZ
	 6GOtanHj9Z1TRHrdUM5Uacu6cu2zmnqn5Vf5tvMWhjmSvFnU4ixYECf5cVdkWFSKnRA==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792544586;
	h=Received:DKIM-Signature:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Message-Id:References:In-Reply-To:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=k2tfDj7xvyxwHEgPGacPd+ZElw5+Yt3doiWL7ua3O9s=;
	b=h3tjmXZhvujmIONCasMKR0k3utXAwf0znR5Qm8A+arOSoVNAsoUhjMEsdRDws91YKfxW
	 PjEk+czR3SmfH7SHMggntl4Rrbs1oJUaqVRQKrEPD49Sw9BM6HwSy3M6ssVHeZFMU4s+q
	 +vF23z3XKmqmkLBKaLcVYCtfDoutRo+s/hfVH22ACo1oIVumfN5ZyfJV5sWdUUdkj2Pl4
	 EbTuXxiQhtkXBvho41bmNWNahjsfPrPZdVL+N4BB/Naap14ad7SYhe60whemsbEnMCXj8
	 61RxHYxXRlsyiutzvQkSMSU5oCw10fo+NuoIFg3M9bifMXycomjpuo9FsEdP4wbhfmg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fy6s6MTH;
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4246D606A325;
	Wed, 21 Oct 2026 01:03:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=fy6s6MTH
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1792544586;
	b=zcNyaeRxZ2X0SBbuur6DtuxzhCuNpjHVDJZTtGWjhFzXOYIIv79XiCl/4pXFXhQrvpJA
	 a/6xPpW/W8XKvAejZKj4yBhfYe41CyAiAJWz1ld0G34pW7eh3PjT7XJdZ0uqNUW9O68Kv
	 /KQyPVgAiH+I0/Xm9U3YYSH8VPGWeGKDoS9z6uBEqnukaMgBYs11i2B6tUrb5S7c7Xmeg
	 xHEQP0BJy3YRRYNY/eFO+Q1/f2a4umKX7vOHhy8DWuBRpQ/M1p3GqdDc8UP+7OVLJuU2w
	 FTbh+JdVeLanJp2R6U+WMpB8yKrh5htgXieUlLhLrc4hVtJ5D0ls/s5I4fTfY6zkrcw==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1792544586;
	h=DKIM-Signature:Received:From:Date:Subject:MIME-Version:Content-Type:
	 Message-Id:References:In-Reply-To:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=k2tfDj7xvyxwHEgPGacPd+ZElw5+Yt3doiWL7ua3O9s=;
	b=XUAGdbp+YeIA8oR2V/nyajD+YeyYvgV9iD8msfThCDJXrS81k/OsI97P2HDNnUA+eTMF
	 h1lxY68DiryzlMehnDXmW/peFyxNoWEznubNnWi+MewOpikA4ecATNEEO+a8QYcqNiCCX
	 fJzZMM4kZJPYf++VmHYftH7IPVERJwgwskf6yvTFKmS4Q1InQWfqABRh5pEvn2bYuMdeB
	 pkUTI+P17d2DkKnbyHZTrfkk4IM6B44D8Rwh34a+0BZ73bV0HYNAO+eGIDsAQUrhmaRRM
	 lwS8THepVoBVbPOeJmvzPps9lP1P5QuI+3wRCHgqWu8vUNPmztthU2RlYBj1s8KtTsA==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id 0A06D1F000CB;
	Wed, 21 Oct 2026 01:03:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792544585;
	bh=k2tfDj7xvyxwHEgPGacPd+ZElw5+Yt3doiWL7ua3O9s=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To;
	b=fy6s6MTHpJC7DjFOii1LnpZuyB1a0IHGhbEamAVN8zw6ARKB6VdFwJXMDAPS2l51q
	 mEH74BE1+xN3vgeLNUK0nXRe8PkJ5WTpHKjx57XFJuGpxUvU5wKUNjv7Kme7bCNe8v
	 WnGjWYuhCsBOUJdNHZ7fhsNFkFQUnCriqMvYfRrwJbp2lY1t686MUMH1WM9pBTGaS5
	 40kN2/ymKO3kzHECSo3p5Av0GbNv4H/jHHNRpjzxs1WURgVrGHROsoWxFKaKkoC7fl
	 EL+FrZjq6k06fXWO+FCJV5NSbL2mUmCMeBcetCOZ9Tw8CWAOF8aJTFaop2t5kugPD1
	 KxcxHkkJPHGBQ==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id 6DE6E43287;
	Wed, 21 Oct 2026 01:03:03 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Wed, 21 Oct 2026 10:03:04 +0900
Subject: [PATCH 2/4] nfsd: resend a layout recall once before trusting
 NOMATCHING_LAYOUT
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
Message-Id: <20261021-nfsd-layout-refcall-v1-2-797096b92377@samsung.com>
References: <20261021-nfsd-layout-refcall-v1-0-797096b92377@samsung.com>
In-Reply-To: <20261021-nfsd-layout-refcall-v1-0-797096b92377@samsung.com>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, 
 Benjamin Coddington <ben.coddington@hammerspace.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Daejun Park <daejun7.park@samsung.com>
X-Mailer: b4 0.13.0
X-Developer-Signature: v=1; a=ed25519-sha256; t=1792544582; l=11784;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=1awGlEX3eaa62kNCVXfBAkAaQI+ZyZMa5d0+Jm6EidI=;
 b=ed8Co4rP8FG0WBEIYDC7ASPctXJGM3QIHi9LrxmoKOcA/WQmuORjxCtY+JPabjuyeFyB/qhVd
 w6gz2hm8NrpAW5wVWfTfQvpLA5I+J8s5QHJQsRjGZlmfEQDqgCMRv4o
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com
Content-Transfer-Encoding: 7bit

From: Daejun Park <daejun7.park@samsung.com>

When the lease of a layout is broken right after nfsd has handed the
layout out, the CB_LAYOUTRECALL can reach the client before the reply to
the LAYOUTGET. A client that does not know the layout stateid yet
answers NFS4ERR_NOMATCHING_LAYOUT, nfsd4_cb_layout_done() takes that as
the end of the recall and drops the layouts, and the client then gets
the reply and writes through a layout that the server no longer has.

The Linux client loses those writes. Its next LAYOUTGET with that layout
stateid gets NFS4ERR_BAD_STATEID, and it calls
pnfs_mark_layout_stateid_invalid(), which clears NFS_INO_LAYOUTCOMMIT
and the layout segments; the block layout driver drops the extents it
has written through the layout with the layout header. No LAYOUTCOMMIT
is sent for them, they stay unwritten extents on the server, they read
back as zeroes, and fsync() on the client succeeds.

Since "nfsd: fail a LAYOUTGET in progress when the layout lease is
broken", a lease break that meets the LAYOUTGET before it has added its
layout fails it, so the recall can only overtake the reply to a
LAYOUTGET that has added its layout. In eight traced runs of the test
below without a delay on the client, no recall overtook a reply; with a
test-only delay of one second the client lost every block whose reply
the recall overtook.

The delegation code has the same problem with NFS4ERR_BAD_STATEID [1].
It trusts the answer if the slot that carried the grant had retired when
the recall was sent, and otherwise sends the recall once more after two
seconds. Do the same for layouts. nfsd4_layoutget() records the slot of
the request in the layout stateid once the layout has been added, while
it still holds ls_mutex, which nfsd4_cb_layout_prepare() takes as well.
->prepare notes whether that slot had retired, and when the client
answers NFS4ERR_NOMATCHING_LAYOUT while layouts are left, the slot had
not retired and the client has not answered NFS4_OK to this recall,
->done sends the recall once more after two seconds. The Linux client
frees the slot of a LAYOUTGET only after pnfs_layout_process() has taken
the layout in.

The resend repeats the request with its seqid, as the polls do, although
RFC 8881 section 12.5.3 has a new seqid for each request: a client that
did not take the request in expects that seqid next, whether or not it
has processed the LAYOUTGET reply since, and the Linux client answers a
seqid that skips one with NFS4ERR_DELAY unless the recall names
referring calls that are complete, which this patch does not send.

A client that took the request in answers the resend with
NFS4ERR_OLD_STATEID: when the Linux client has the layout stateid but no
layout segment that the recall matches, initiate_file_draining() takes
in the seqid of the recall before it answers NFS4ERR_NOMATCHING_LAYOUT.
"nfsd: keep polling a layout recall answered with NFS4ERR_OLD_STATEID"
has the polls carry a new seqid then, which the client answers afresh. A
LAYOUTRETURN during the delay that returns the last layout does not stop
the resend, but the answer to it then ends the recall without fencing
the client, as "nfsd: do not fence a client for a layout recall with no
layouts left" has it. The resend is traced as nfsd_layout_recall_resend.

The answer to the resend is trusted, where the delegation code trusts it
only if the slot has retired by then and otherwise leaves the delegation
to the laundromat, which revokes it. The counterpart for a layout is to
poll until the slot retires and fence the client after two lease
periods, and a client that is idle leaves its slot unretired also when
it really has no layout.

The resend covers a client that takes the reply in within the two
seconds before it; a client that takes longer still loses the data. The
next patch lets a client that honors referring calls hold the recall
back instead.

The resend costs the writer that broke the lease. A pNFS block layout
client writes 1 MiB blocks with O_DIRECT to a new file for 60 seconds
while an NFSv4.0 client writes to another range of it, so that the
writes of the NFSv4.0 client keep breaking the layout lease. With a
test-only delay of one second in the pNFS client before
pnfs_layout_process(), 14 of 58 and 14 of 57 blocks written through a
layout read back as zeroes in two runs, each one a block whose LAYOUTGET
reply the recall overtook. With this patch none did (27 and 26 blocks),
although the recall overtook the reply 11 and 18 times. The NFSv4.0
client wrote all its 600 blocks in 15.0 and 15.3 seconds without this
patch and in 37.8 and 51.9 seconds with it: each recall that overtook a
reply lasted two seconds longer, and the WRITEs of the NFSv4.0 client
got NFS4ERR_DELAY meanwhile. With fs.lease-break-time at two seconds or
less, a resent recall can outlast the lease break and have the client
fenced, also one that really has no layout, where the recall used to end
at its first answer. Without the delay, both clients wrote all their 600
blocks in each of three traced runs of 30 seconds with this patch, and
no recall overtook a reply.

The writer pays also when the client that holds the layout is idle: in a
test where a client read a file, kept it open and did no further I/O
while another client wrote to it, the write ended 12.1 seconds after the
first read with this patch and 8.8 seconds after it without; the writer
starts 8 seconds after the reader starts. The idle client answered
NFS4ERR_NOMATCHING_LAYOUT to the recall and to the resend.

This needs the previous patch, and with it [1], and from "nfsd: layout
recall and lease break fixes" [2] the patches named above: without
"nfsd: keep polling a layout recall answered with NFS4ERR_OLD_STATEID",
the NFS4ERR_OLD_STATEID answer to the resend has the client fenced.

Link: https://lore.kernel.org/r/20260802-nfsd-deleg-destroy-badhandle-v1-8-323aa7196055@kernel.org # [1]
Link: https://lore.kernel.org/r/20261015-nfsd-layout-recall-v3-0-ba3269f8ca22@samsung.com # [2]
Fixes: c5c707f96fc9 ("nfsd: implement pNFS layout recalls")
Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
 fs/nfsd/nfs4layouts.c | 45 +++++++++++++++++++++++++++++++++++++++++++--
 fs/nfsd/nfs4proc.c    |  6 ++++++
 fs/nfsd/state.h       | 10 ++++++++++
 fs/nfsd/trace.h       |  1 +
 4 files changed, 60 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 679da5ba96..78ce4fc94d 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -330,6 +330,7 @@ nfsd4_alloc_layout_stateid(struct nfsd4_compound_state *cstate,
 	}
 
 	ls->ls_recall_start = 0;
+	ls->ls_grant.valid = false;
 	ls->ls_fenced = false;
 	ls->ls_fence_inflight = false;
 	ls->ls_fence_stopped = false;
@@ -880,11 +881,22 @@ nfsd4_cb_layout_prepare(struct nfsd4_callback *cb)
 {
 	struct nfs4_layout_stateid *ls =
 		container_of(cb, struct nfs4_layout_stateid, ls_recall);
+	struct nfs4_client *clp = ls->ls_stid.sc_client;
+	struct nfsd4_grant_slot grant;
 
 	mutex_lock(&ls->ls_mutex);
 	nfs4_inc_and_copy_stateid(&ls->ls_recall_sid, &ls->ls_stid);
+	grant = ls->ls_grant;
 	mutex_unlock(&ls->ls_mutex);
 	ls->ls_recall_accepted = false;
+	/*
+	 * A layout stateid with layouts has its slot recorded, as
+	 * nfsd4_layoutget() records it under ls_mutex; without one there
+	 * is no reply to wait for.
+	 */
+	ls->ls_recall_retired_at_send = !grant.valid ||
+		nfsd41_grant_slot_retired(clp, &grant);
+	ls->ls_recall_resent = false;
 	return true;
 }
 
@@ -915,8 +927,10 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
 		 * The poll reuses the recall's seqid, against RFC 8881
 		 * section 12.5.3, so a client returning its layouts answers
 		 * NFS4ERR_OLD_STATEID too. A client that has not taken the
-		 * recall up is past that seqid, e.g. after a LAYOUTRETURN,
-		 * and gets a new one. ls_mutex could block rpciod, so the bump
+		 * recall up is past that seqid and gets a new one: after a
+		 * LAYOUTRETURN, or when the resend below repeats the seqid of a
+		 * recall that the Linux client took in although it matched no
+		 * layout segment. ls_mutex could block rpciod, so the bump
 		 * relies on sc_lock.
 		 */
 		if (!ls->ls_recall_accepted) {
@@ -994,6 +1008,33 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
 		}
 		return 1;
 	case -NFS4ERR_NOMATCHING_LAYOUT:
+		/*
+		 * The recall can reach the client before the reply to the
+		 * LAYOUTGET that added the layout, and a client that has not
+		 * processed that reply answers this way too. As the
+		 * delegation code does for NFS4ERR_BAD_STATEID, trust the
+		 * answer if the slot of the LAYOUTGET had retired when the
+		 * recall was sent, and send the recall once more after a
+		 * delay otherwise. Unlike the delegation code, trust the
+		 * answer to that resend: not trusting it would end in fencing
+		 * the client, and an idle client leaves its slot unretired
+		 * also when it has no layout. A client that has answered
+		 * NFS4_OK to this recall knew the layout stateid, so its
+		 * answer to a poll is trusted at once.
+		 *
+		 * The resend repeats the request with its seqid, as the polls
+		 * do, although RFC 8881 section 12.5.3 has a new one for each
+		 * request: a client that did not take the request in expects
+		 * that seqid next, and a client that did answers
+		 * NFS4ERR_OLD_STATEID, which the polls handle.
+		 */
+		if (!list_empty(&ls->ls_layouts) && !ls->ls_recall_accepted &&
+		    !ls->ls_recall_retired_at_send && !ls->ls_recall_resent) {
+			ls->ls_recall_resent = true;
+			trace_nfsd_layout_recall_resend(&ls->ls_recall_sid);
+			rpc_delay(task, 2 * HZ);
+			return 0;
+		}
 		trace_nfsd_layout_recall_done(&ls->ls_stid.sc_stateid);
 		task->tk_status = 0;
 		return 1;
diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index a50f9dcb3a..506007cac5 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -2968,6 +2968,12 @@ nfsd4_layoutget(struct svc_rqst *rqstp,
 		goto out_put_stid;
 
 	nfserr = nfsd4_insert_layout(lgp, ls);
+	/*
+	 * Under ls_mutex, which nfsd4_cb_layout_prepare() takes as well, so
+	 * that a recall of the new layout finds the slot recorded.
+	 */
+	if (!nfserr)
+		nfsd41_record_grant_slot(&ls->ls_grant, cstate);
 
 out_put_stid:
 	mutex_unlock(&ls->ls_mutex);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 2c00b334c3..71a4b6fa5a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -863,6 +863,16 @@ struct nfs4_layout_stateid {
 	bool				ls_recall_accepted;
 	bool				ls_recalled;
 	struct mutex			ls_mutex;
+	/*
+	 * Forward-channel slot that carried the last LAYOUTGET that added
+	 * a layout to this layout stateid, or extended one by merging.
+	 * Under ls_mutex. Until that slot retires, the client may not
+	 * have processed the reply to the LAYOUTGET.
+	 */
+	struct nfsd4_grant_slot		ls_grant;
+	/* Recall state for ->done, reset in ->prepare */
+	bool				ls_recall_retired_at_send;
+	bool				ls_recall_resent;
 
 	struct delayed_work		ls_fence_work;
 	struct mutex			ls_fence_mutex; /* serializes fence shutdown */
diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
index e0908cb21c..bd031b7124 100644
--- a/fs/nfsd/trace.h
+++ b/fs/nfsd/trace.h
@@ -681,6 +681,7 @@ DEFINE_STATEID_EVENT(layout_return_lookup_fail);
 DEFINE_STATEID_EVENT(layout_recall);
 DEFINE_STATEID_EVENT(layout_recall_empty);
 DEFINE_STATEID_EVENT(layout_recall_done);
+DEFINE_STATEID_EVENT(layout_recall_resend);
 DEFINE_STATEID_EVENT(layout_recall_new_seqid);
 DEFINE_STATEID_EVENT(layout_recall_fail);
 DEFINE_STATEID_EVENT(layout_recall_release);

-- 
2.43.0


