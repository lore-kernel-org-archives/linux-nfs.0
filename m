Authentication-Results: smtp.subspace.kernel.org; arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
ARC-Seal: i=2; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=pass;
	t=1792544587;
	b=2+/OpEax8hT6eTbZaL0H73PAuuDj0dT3IPGuEkuliPO+9PUnQ6N7QxRS1s4xdy/Z9xeG
	 ynykf/+sS9jtN5zDUT+kcU8bbSvTollXeV1QGsQbHa4pwLm38RxalNotHNTWr1Whxw7+Y
	 NkvTUARmYWuv1M5KRzbrYUe4G5cqeCyUmVpXiJjRq0lsYHIz3m8GWXWqCflok3mtlNwiU
	 d9Y9d4PkyHzriGYDSl2xKAggKgoEFyCwKyRFJOnlqK0n3pRslCWe0NdNeGkzbBC0QH9CH
	 PRmca+8OsGsuPvbNW8UBznpTZYMkfuGv2IwTEYrZ7RUhEcWud+izsub9H/AafSruqoQ==
ARC-Message-Signature: i=2; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792544587;
	h=Received:DKIM-Signature:Received:From:Date:Subject:MIME-Version:
	 Content-Type:Message-Id:References:In-Reply-To:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=OqHXkQVK8xlwr8KTC1AMZpnmkw1krIUJz1OEBICVePE=;
	b=OUtvw2Byy5LQFlZHlV8gU/Aw0IMBIjRS6S/L4ey1XssTaYk3OXn4oOUeQXi7d+e8uFJT
	 C/D2uAE/lyOOQHBsKvYOrfyAVlYJImQceO15oX7PjDWVCt/3n2MFiyUxlYP7LV7gtrWsT
	 L1XqSJi+DCvh/Gykfqi3TJ5VjTAMo9RQJvol2BAqiw2Sp0INjjsnkyneyRNFE+oRyj9PD
	 7QeCXu75skI6wUh01F3XHJk/K30nLN7vijZQpPrTjQ6G/sviT7tSKaHAw0FKt7lpESnTT
	 0XACaVk2eDVKfQK6Xv85j/uKVRn0d6WDzjUYt4VnInLhogth2TqDL/rXFTlU2bwfyLg==
ARC-Authentication-Results: i=2; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VUZTQIUg;
	arc=pass header.oldest-pass=0 smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EA44D606A331;
	Wed, 21 Oct 2026 01:03:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=VUZTQIUg
Authentication-Results: smtp.kernel.org; arc=none smtp.remote-ip=100.80.115.77
ARC-Seal: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256; cv=none;
	t=1792544586;
	b=xzFaPpw0U1IVqCMBcB08Quf6e422Ik+u+5RLdLGgFJZ3jYaSkFzmzsUNVXu5h5dhQ5iy
	 CJdqe9G3SA8EmWsI3e92ASujTAxBC1X8fuFFidR9uv8M5ztwRd7Dd45sXxV/pUSVaf/H0
	 qbQm6a06IJ5km6eockgoebUkfO3YFCXivYi8H8BYq0Y5Ulms/loV3CkTTuE5Y0bFHqoL3
	 /oy5WCUqJp5pph6yCoCzrodFntPjjFe9jp6JyOSSlhcB36L6LKErdsDIO3dSLjVhdE55o
	 ep66R5iuhB8dB43rlyxA01R4anDP19jmr8SJxj0c7Sp7utYCBH+wG+XWxqD73+u+UNA==
ARC-Message-Signature: i=1; d=kernel.org; s=arc20260519; a=rsa-sha256;
	c=relaxed/relaxed; t=1792544586;
	h=DKIM-Signature:Received:From:Date:Subject:MIME-Version:Content-Type:
	 Message-Id:References:In-Reply-To:To:Cc:X-Mailer:
	 X-Developer-Signature:X-Developer-Key:X-Endpoint-Received:
	 X-Original-From:Reply-To:Content-Transfer-Encoding;
	bh=OqHXkQVK8xlwr8KTC1AMZpnmkw1krIUJz1OEBICVePE=;
	b=cfOwEEojFVWwaheZ8SdSqVxbFWSa41w8fnUKnC/w1Bf1TiVFe14W82AFls3JYgMsELvS
	 rxqMgwuPboLQIeCS0BJrKQ4QVkfqH/0cnuYai+f4t9kNnqFyuG4vAN9Ie3aptX12u9v3r
	 atGh5RiXPmhPOln9AyjMnIX6qvwSYx9dDoZTV6I5sIGHiEaBWLNAZSpYDBigYByRmIyhI
	 O9BUh7eVuTdxm9+y18IFzXHHoL4rvidwNRp7FfMxZpJ9w5ht7TUyl8cKfvjTfS5CLoCMy
	 LQeHClY91rfMh9uMLR/Jni7u1AMgafoGmYbN6nArDTo24BdgXn37bpnGmjdPoVy5CIQ==
ARC-Authentication-Results: i=1; smtp.kernel.org; 
	arc=none smtp.remote-ip=100.80.115.77
Received: from lkml.kernel.org (nexus.subspace.kernel.org [100.80.115.77])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.kernel.org (Postfix) with ESMTPS id 0A1401F000CC;
	Wed, 21 Oct 2026 01:03:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792544586;
	bh=OqHXkQVK8xlwr8KTC1AMZpnmkw1krIUJz1OEBICVePE=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc:Reply-To;
	b=VUZTQIUgCu5lEUikEIFeV10oCwyayMKwxWJ0qO7eMdXwn/FkHngdffUOXDvCc4XsE
	 j1+ssRzlEH8BGgngyZJZYRa4XC8eRkPf6c9ktVJKVtPGs7v/VGGqN6GN1mpxhpdlRn
	 Ol7RYqXSfj6ES27KgPxNzUiezTXESFSoxegNi1KQU1WqPkmjHkMnDUj1Q27CVjG68h
	 /+Z1bMhXlAq5CPbHmLs8ELbmGIg123NasKfZ9b3x9gTvNZzSZVeWPIGJJz7sFmHcfW
	 +h0VqTUkGeqh1bZkGp8A994HOjta6YyQB6Dxlivs3tJ20jLhpFPpyz5OzEBfvilKSh
	 TV+Lt/eYpu+hw==
Received: from nexus.subspace.kernel.org (localhost [IPv6:::1])
	by lkml.kernel.org (Postfix) with ESMTP id 7440C4328C;
	Wed, 21 Oct 2026 01:03:03 +0000 (UTC)
From: Daejun Park via B4 Relay <devnull+daejun7.park.samsung.com@kernel.org>
Date: Wed, 21 Oct 2026 10:03:05 +0900
Subject: [PATCH 3/4] nfsd: send a referring call with CB_LAYOUTRECALL
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
Message-Id: <20261021-nfsd-layout-refcall-v1-3-797096b92377@samsung.com>
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
X-Developer-Signature: v=1; a=ed25519-sha256; t=1792544582; l=10217;
 i=daejun7.park@samsung.com; s=20261006; h=from:subject:message-id;
 bh=rwrYK3CrIB/K7UTkQ6dMIZit5Nsq1coAEQCzRIFkNbw=;
 b=GL9FjfKYM8ilP9ZUBGClqKncyhLIQxyRaUQX9ZNDOvyrystB1JdapjhD0rCXMBP36JM6H+ksE
 kxWmecRxBFsA4uJPN4QPzWCSUm5J0Bk4H98CrNcylJhjG4d4TeNxTQV
X-Developer-Key: i=daejun7.park@samsung.com; a=ed25519;
 pk=4yUfDqGRZTIj0Ik43z1GoMZRWCNm/rgX6uJuM9dtNIg=
X-Endpoint-Received: by B4 Relay for daejun7.park@samsung.com/20261006 with
 auth_id=1122
X-Original-From: Daejun Park <daejun7.park@samsung.com>
Reply-To: daejun7.park@samsung.com
Content-Transfer-Encoding: 7bit

From: Daejun Park <daejun7.park@samsung.com>

The previous patch resends a layout recall once when the client answers
NFS4ERR_NOMATCHING_LAYOUT before it can have processed the reply to the
LAYOUTGET, which covers a client that takes the reply in within two
seconds. RFC 8881 section 2.10.6.3 has the server name the request that
created the state in the referring call list of the callback instead, so
that the client can hold the callback back until it has processed the
reply, and section 12.5.5.2.1, which is about this race, lets the server
name the LAYOUTGET in a CB_LAYOUTRECALL. Commit 4f3c8d8c9e10 ("NFSD:
Implement CB_SEQUENCE referring call lists") added the lists, noting
that layout recalls need them, and "NFSD: Send referring calls with
CB_RECALL" [1] uses them for delegations.

Do the same for layouts: nfsd4_cb_layout_prepare() names the LAYOUTGET
that the previous patch records as a referring call, unless the client
had retired its slot when the recall was sent. The resend keeps the list
without testing the slot again: a client that has not processed the
reply yet holds the recall back, and one that has finds the call
complete. The Linux client holds a callback back with "NFSv4.1: Return
NFS4ERR_DELAY when a referring call wait times out" [2]. Without that,
it waits half a second for the LAYOUTGET, then answers as before, and
the resend still covers it when it takes the reply in within about three
seconds: half a second of waiting, the two second delay, and half a
second again.

Only the last LAYOUTGET of a layout stateid is named. That departs from
RFC 8881 section 2.10.6.3, which says that recalls MUST carry every
request that created the state for as long as its slot has not retired.
The recall is misread only for a layout stateid the client does not know
yet, and such a layout stateid was created by a single LAYOUTGET:
nfsd4_preprocess_layout_stateid() makes a new layout stateid for each
LAYOUTGET that presents another kind of stateid, and the client cannot
use the layout stateid before it has the reply. For a layout stateid the
client knows, the Linux client takes the seqid of the recall as given
once the named LAYOUTGET is complete, since
commit dce72920c81b ("NFSv4.1: if referring calls are complete, trust
the stateid argument"), and a reply to an earlier LAYOUTGET that arrives
after the recall is not used, because its seqid is below the barrier the
recall sets (pnfs_layout_stateid_blocked()). One referring call is also
all that cb_sequence_enc_sz has room for. ->prepare runs once per layout
stateid, which is recalled at most once, so the list holds one call and
is freed with the layout stateid.

This needs the referring call lists, which are in v6.16, and [1], which
is queued for v7.4. It should not go to kernels without
commit f52792f484ba ("NFSD: Enforce timeout on layout recall and
integrate lease manager fencing"), which is in v7.1: a client that holds
the recall back with NFS4ERR_DELAY while it takes the layout in can need
a GETDEVICEINFO for that, and before v7.1 a lease break that holds every
nfsd thread does not give up, so that GETDEVICEINFO would never be
served. From v7.1 on, that case stalls the server for the client until
fs.lease-break-time and then has the client fenced, where the client
would have lost the data before.

With the test of the previous patch and its one second delay, this patch
lost no block (23 and 23 blocks, the recall overtaking the reply of
each). With [2] on the client and the next patch as well, which does not
act in this test as the lease breaks come from the other client, no
recall was answered before the client had taken the LAYOUTGET reply in
(19 and 23 blocks): the client held each one back. With a delay of four
seconds, longer than the resend covers, a client without [2] loses every
block whose reply the recall overtakes, with this patch as with the
previous one: 15 of 15 in each of two runs here, 7 and 8 of 15 with the
previous patch alone, where each such recall is about a second shorter
and the NFSv4.0 client was done after 29.0 and 31.5 seconds, so later
blocks met no recall. With [2] and the whole series, none (8 and 9
blocks). For a client without [2], this patch saves the two second
resend when the client processes the reply within half a second, and
the data when it does so in two to about three seconds; it adds half a
second to each such recall when the client takes half a second to two
seconds, as in the test above, and a second when it takes longer than
about three seconds.

The cost is on the writer that breaks the lease. A recall that names a
LAYOUTGET the client has not processed within half a second now lasts at
least two and a half seconds: half a second of waiting on the client,
then the two second delay before nfsd sends the callback again, after
NFS4ERR_DELAY in CB_SEQUENCE with [2] or as the resend without it.
WRITEs through the metadata server get NFS4ERR_DELAY meanwhile. With the
one second delay, the NFSv4.0 client wrote only 71 and 76 of its 600
blocks in 62 seconds with this patch, against all of them in 15.0 and
15.3 seconds without the series and in 37.8 and 51.9 seconds with the
previous patch alone. It needs about 15 seconds plus two and a half
seconds for each recall that meets an unprocessed reply, two with the
previous patch alone. The number of such recalls varies between runs of
the same code; here there were 23 in each run, one for every LAYOUTGET
granted. In six runs with this patch and six with the whole series,
which behaves the same in this test, there were 23 or 24 in eight, and
the NFSv4.0 client wrote 6 to 76 blocks in a minute; 2 to 13 in the
other four, and it finished in 20.3 to 49.1 seconds. With the previous
patch alone, there were 1 to 18 in six runs, and it finished in 17.2 to
51.9 seconds.

Link: https://lore.kernel.org/r/20260802-nfsd-deleg-destroy-badhandle-v1-9-323aa7196055@kernel.org # [1]
Link: https://lore.kernel.org/r/20261020-nfs-referring-call-delay-v1-1-0be8f0608f7c@samsung.com # [2]
Fixes: c5c707f96fc9 ("nfsd: implement pNFS layout recalls")
Signed-off-by: Daejun Park <daejun7.park@samsung.com>
---
 fs/nfsd/nfs4layouts.c | 26 ++++++++++++++++++++++----
 fs/nfsd/state.h       | 12 ++++++++++--
 2 files changed, 32 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 78ce4fc94d..33d78595f7 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -254,6 +254,8 @@ nfsd4_free_layout_stateid(struct nfs4_stid *stid)
 	if (ls->ls_recalled)
 		atomic_dec(&ls->ls_stid.sc_file->fi_lo_recalls);
 
+	/* The list outlives one send of the recall. */
+	nfsd41_cb_destroy_referring_call_list(&ls->ls_recall);
 	kmem_cache_free(nfs4_layout_stateid_cache, ls);
 }
 
@@ -897,6 +899,18 @@ nfsd4_cb_layout_prepare(struct nfsd4_callback *cb)
 	ls->ls_recall_retired_at_send = !grant.valid ||
 		nfsd41_grant_slot_retired(clp, &grant);
 	ls->ls_recall_resent = false;
+
+	/*
+	 * The recall can reach the client before the reply to the
+	 * LAYOUTGET that handed out the layout. Name that LAYOUTGET as a
+	 * referring call (RFC 8881 section 2.10.6.3) if the client has not
+	 * retired its slot yet, so that a client that honors it holds the
+	 * recall back instead of answering NFS4ERR_NOMATCHING_LAYOUT.
+	 * ->prepare runs once per recall; the list stays for the polls and
+	 * the resend that follow and is freed with @ls.
+	 */
+	if (!ls->ls_recall_retired_at_send)
+		nfsd41_cb_referring_grant(&ls->ls_recall, clp, &grant);
 	return true;
 }
 
@@ -1009,9 +1023,10 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
 		return 1;
 	case -NFS4ERR_NOMATCHING_LAYOUT:
 		/*
-		 * The recall can reach the client before the reply to the
-		 * LAYOUTGET that added the layout, and a client that has not
-		 * processed that reply answers this way too. As the
+		 * A client that has not processed the reply to the LAYOUTGET
+		 * named as referring call answers this way too: one that
+		 * ignores referring calls, and a Linux client that stops
+		 * waiting for that LAYOUTGET after half a second. As the
 		 * delegation code does for NFS4ERR_BAD_STATEID, trust the
 		 * answer if the slot of the LAYOUTGET had retired when the
 		 * recall was sent, and send the recall once more after a
@@ -1026,7 +1041,10 @@ nfsd4_cb_layout_done(struct nfsd4_callback *cb, struct rpc_task *task)
 		 * do, although RFC 8881 section 12.5.3 has a new one for each
 		 * request: a client that did not take the request in expects
 		 * that seqid next, and a client that did answers
-		 * NFS4ERR_OLD_STATEID, which the polls handle.
+		 * NFS4ERR_OLD_STATEID, which the polls handle. Unlike the
+		 * delegation code, the resend does not test the slot again:
+		 * a referring call that is complete by then is harmless, as
+		 * the client finds it complete.
 		 */
 		if (!list_empty(&ls->ls_layouts) && !ls->ls_recall_accepted &&
 		    !ls->ls_recall_retired_at_send && !ls->ls_recall_resent) {
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 71a4b6fa5a..075fd3d107 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -866,8 +866,16 @@ struct nfs4_layout_stateid {
 	/*
 	 * Forward-channel slot that carried the last LAYOUTGET that added
 	 * a layout to this layout stateid, or extended one by merging.
-	 * Under ls_mutex. Until that slot retires, the client may not
-	 * have processed the reply to the LAYOUTGET.
+	 * Under ls_mutex.
+	 *
+	 * RFC 8881 section 2.10.6.3 has a callback name every request that
+	 * created state it refers to and whose slot has not retired. The
+	 * recall names only this one. A layout stateid the client does
+	 * not know yet was created by a single LAYOUTGET, because
+	 * nfsd4_preprocess_layout_stateid() makes a new layout stateid for
+	 * each LAYOUTGET that presents another kind of stateid, and the
+	 * client cannot use the layout stateid before it has that reply.
+	 * LAYOUTGETs for one layout stateid are serialized by ls_mutex.
 	 */
 	struct nfsd4_grant_slot		ls_grant;
 	/* Recall state for ->done, reset in ->prepare */

-- 
2.43.0


