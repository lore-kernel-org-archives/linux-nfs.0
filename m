Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 818A317A2EA
	for <linux-nfs@vger.kernel.org>; Thu, 11 Jun 2026 01:59:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781143163; cv=none; b=i2kTkROK7Hgx9HV0DSxPLbfCo3ZQz+JwVo5vWGnH34zXqhtNzfTF2MayrVIP0BcUSsLgzf7rEIhMrzj3iRhlrwTkT49C5gdReu7FrHelVVQEifh6WpFiATC3G4WLHXN8vVCOAOU+89I+ghgqQuqZA+mrRnj/Dl70EpRTN+ePrek=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781143163; c=relaxed/simple;
	bh=zpFMW3RfdSY3FiGJxZieqquYzz0ssw9o+wPeg41YmBE=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=CgycAx8cvSBaEXPKc/a/J+WjarUcO1ajjM4kxW/5IcYDyb1LLhSeqShr7bklfvsCrCCQaP2be3E0I6lxfqkO5GEod+RaYRM97KNDCxevOpy0jmCBxiCL01wswORCm7OppeeAk+jgS+I+fQ1n1h1KQDsXCWvctOM3tpw5jDjrqYQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=nEvUjLK0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="nEvUjLK0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BDBC51F00899;
	Thu, 11 Jun 2026 01:59:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781143162;
	bh=XkqXHrQe/AHSmFOPjS3ccx1Mv0rf6ic8QtPTv8NTuo8=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=nEvUjLK0BbsFd40ufnQiUieI2ZEiyEteRE6nakCehHv/SLl0RN+DW2Hh66I4UX1Uo
	 EZO7IrfHdymg3k0n+0akC+I6KL1uZTUmpM6aDN44Ko0CfnurV/8Mrcultej/dcIDUi
	 J+guRc0rvlicBsOXHd7hxBsxUFBDoERLas4mFo6HsrsRsZ2RTomgxWKkp3VSifvTYp
	 9xcrM8dxFy8fBpJrrEXrIfenO1NfvEnjRahS+EZh8iQWMJ1ZloT3VTAyQAC+ZU8j+6
	 lmwbUJhUi8ZgiGuu1CROrcHqqSe3OUF2Y7wxjEyt2uuV/S0PdqNqhvILFd7tRpl0Wb
	 1r/QcilO7Jy5g==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 10 Jun 2026 21:58:56 -0400
Subject: [PATCH 4/5] NFSD: Document and rename the NFSv4.1 session slot
 shrinker callbacks
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260610-nfsd-slot-growth-clamp-v1-4-7b966700df0b@kernel.org>
References: <20260610-nfsd-slot-growth-clamp-v1-0-7b966700df0b@kernel.org>
In-Reply-To: <20260610-nfsd-slot-growth-clamp-v1-0-7b966700df0b@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Benjamin Coddington <bcodding@hammerspace.com>, 
 Jonathan Flynn <jonathan.flynn@hammerspace.com>, linux-nfs@vger.kernel.org, 
 Chuck Lever <chuck.lever@oracle.com>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2911; i=cel@kernel.org;
 h=from:subject:message-id; bh=zpFMW3RfdSY3FiGJxZieqquYzz0ssw9o+wPeg41YmBE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqKhZ2B0tfzO+L+LuXIYpOxfCUVMuHBKkM7dtTa
 Jp6rodAZAeJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaioWdgAKCRAzarMzb2Z/
 l1CkD/0TLMqIWcKYmtqFCyERa9RxhcQv+MHyJidwhhdXsbW5GzNf/SFHXISA/vfGommGENSOnS7
 xNXjVN62fyTMLANghIv2aq9qFA8EUT8x4AGSvQPKVrlL2zzD1PSRsTqhcraEh3ye7iMvGqVtpnP
 4+jjv+juHUA2HTg3mS8QxeYS2+JPpH6PHZwZ5FlthlDCJ2L3V6Zi9IEZm0K/Kb2VQ+k7MdJOzEQ
 rSGeBMsVufVwj1KEOi2LrvW/AM5fXEgSLz+Ttp6zIcfI/hlFgsrdSqRveTLy8PavpLqnN7qk6yZ
 n1Xu2FN5toYKDCbZvSGElTEHxGhxlqphMa6qsfjYD9CRXtDTNRReTWsw4KjWz2y4qAem2p7b9Nc
 p1PTX1vIJHHtC+m32a828+SXRN/rUIQLAsewdGbVDOKcyLLaOLwl0WEJRDd446fwD8dwpDns9tl
 uynPScL0DVaQkQhXa6E+khOscyIhj6hE/9ssNkaCtPOQ1OXGgY73sjRIS/jtyADeLIllE7I+G3j
 LjQo86u62LikkU+Qro79YJhwDpYUI5zSV3Ljy1L9yl4nh6ii7FI6Zohv3sIGMqkAcznDxy0Pg24
 HDXARCtmFTxYsE7N3mwXa1vsNTzU9nBRiIKYcg8THeXvt/qXHlbqgpfIwZSCuY1fZh5OQ13iPNv
 o0Iites35DvqH9w==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

Clean up: To prevent their reuse by generic code, rename the NFSv4.1
session slot shrinker's callback functions to make it clear they are
for use only by the shrinker.

Though they are static, callbacks are invoked from outside nfsd.ko,
so they need appropriate kdoc comments that document their API
contracts.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 36 ++++++++++++++++++++++++++++++++----
 1 file changed, 32 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9735e9a59f0e..7ce8462e3697 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -2196,22 +2196,50 @@ static void free_session(struct nfsd4_session *ses)
 	__free_session(ses);
 }
 
+/**
+ * nfsd_slot_shrinker_count - report reclaimable DRC slots
+ * @s: shrinker descriptor (unused)
+ * @sc: shrink control (unused)
+ *
+ * Return: a positive count of reclaimable slots, or SHRINK_EMPTY when
+ * there is nothing to reclaim.
+ */
 static unsigned long
-nfsd_slot_count(struct shrinker *s, struct shrink_control *sc)
+nfsd_slot_shrinker_count(struct shrinker *s, struct shrink_control *sc)
 {
 	int cnt = atomic_read(&nfsd_total_target_slots) -
 		  atomic_read(&nfsd_total_sessions);
 
+	/*
+	 * To prevent deadlock, one slot of each session (slot 0) is
+	 * not reclaimable while the session is active. Thus the
+	 * number of sessions is subtracted from the total number of
+	 * target slots.
+	 */
 	return cnt > 0 ? cnt : SHRINK_EMPTY;
 }
 
+/**
+ * nfsd_slot_shrinker_scan - reclaim DRC slots under memory pressure
+ * @s: shrinker descriptor (unused)
+ * @sc: shrink control; @sc->nr_to_scan bounds the sessions visited,
+ *      @sc->nr_scanned reports how many were visited
+ *
+ * Return: the number of session slots NFSD will release.
+ */
 static unsigned long
-nfsd_slot_scan(struct shrinker *s, struct shrink_control *sc)
+nfsd_slot_shrinker_scan(struct shrinker *s, struct shrink_control *sc)
 {
 	struct nfsd4_session *ses;
 	unsigned long scanned = 0;
 	unsigned long freed = 0;
 
+	/*
+	 * Each visited session releases at most one slot. After
+	 * nr_to_scan sessions have been visited, the list head is
+	 * rotated past the last visited session so the next scan
+	 * resumes from there.
+	 */
 	spin_lock(&nfsd_session_list_lock);
 	list_for_each_entry(ses, &nfsd_session_list, se_all_sessions) {
 		freed += reduce_session_slots(ses, 1);
@@ -9120,8 +9148,8 @@ nfs4_state_start(void)
 		rhltable_destroy(&nfs4_file_rhltable);
 		return -ENOMEM;
 	}
-	nfsd_slot_shrinker->count_objects = nfsd_slot_count;
-	nfsd_slot_shrinker->scan_objects = nfsd_slot_scan;
+	nfsd_slot_shrinker->count_objects = nfsd_slot_shrinker_count;
+	nfsd_slot_shrinker->scan_objects = nfsd_slot_shrinker_scan;
 	shrinker_register(nfsd_slot_shrinker);
 
 	set_max_delegations();

-- 
2.54.0

