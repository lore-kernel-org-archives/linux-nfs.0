Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795438763;
	b=sR0H3polrJG9jALakcAKDcVAYe/AAfJnh9FjgElGa0m0tbDa5Bty6k507pJyPBQMOmoQ
	 /oIZBTAgCXNAFIjL/95DLolcGlpcTsce9H+dvPPEkdevmEjKBkTYCEgPBag0djqVlzSV/
	 lUZhlWKE5WFbJRNX8C14/AHwqAxPJAYoHpVMLaUvkbTcA1fVGejl8HzH1mYRzpCqk/tWI
	 pFFJkKvrg1hDvsqDqF/2USDe9QiPcfgdjtpppM3MjRjTvxW1wM8k2ONinf9MrqC0/3xSD
	 1ym65udTeQATGMJaa5kFENs8PDTuN1CdTe3N0LrcSK0mptfNxlMwvrgOMLkW5AL2N9A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795438763;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=AMJWoA7IqPAf/PU7cw+CfHnIHdrvkCU+XAirDo3aOOA=;
	b=5fTEgeaBA8Qp8sgbF21H5HAWOb6b5kK7eIS6i5Sq7VtYEqNT/Jlmfy7LA289OlkrZiTO
	 LLMAafrXo6ExINaB4gnzF+yCc0wNbsfQfv6j5W0tIoJWJF3m9AZkct9HJiNLbUiU46RLr
	 hzsI7HwXJyhi4C2At1I6ATAXaMa4kt/pNGLKKFzgQeP8GE0qtlNWEJgpg6IEf0HAosWO6
	 PoaWCla0IVnr4AktLxaperSvQZLmO3Xv5ByJk65YyyeK1PpfWSawrZZp23B1iRxZxAJaF
	 FIkxlUEt8YKRivu+oDyQhiMnp4xOTMtaCAEe2FQot2llDJq9u5PNvwepA8fzCIcScag==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=P8nZCvvM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A0E48606A32C;
	Mon, 23 Nov 2026 12:59:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=P8nZCvvM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B0A9E1F000F2;
	Mon, 23 Nov 2026 12:59:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795438763;
	bh=AMJWoA7IqPAf/PU7cw+CfHnIHdrvkCU+XAirDo3aOOA=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=P8nZCvvMSvih1b7VqcM2vk17w2IYS4H+i6CYzb4PT4pNmMbDcqWugpyRLJr0nq7/A
	 9PQiokhRPT4z5GUbZSCb2WM/gnTfkGBhQJWXwu+IEOj9bbOUcjUibCaK3gvZ2cNtYG
	 M23qScHHqbnMyU27PxBPc1giOZlvgVjWaoSgpblUAbF/vjpaQN5K72KG0QejfHZhbv
	 c88bX5uoBeNBk7aLsRxaIY8EPTVG44PXBh72ZfAXiAIVND7GT5Au5+o4z4pVa1LklS
	 Jf70bXHS8Ql9LSUTGfhOFz7Mfsupb5DA6+JNM8JZnZOj2es+6PJj2k+PKlo3EpOvy8
	 JviaK1AwLGBnA==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 23 Nov 2026 04:59:06 -0800
Subject: [PATCH v2 03/11] nfsd: count a delegation in cl_delegs_in_recall
 only once
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
Content-Transfer-Encoding: 7bit
Message-Id: <20261123-delegts-fixes-v2-3-960ce0fb2fed@kernel.org>
References: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
In-Reply-To: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2392; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=j7burE7X/bnixPzu1cHjcxVfoh85BFGyFaCXaxXHWq4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBDikwRxI/fJy7LxFN/gG+6P9pHKjaxVlk4n3K
 3M6YP+ydcuJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawQ4pAAKCRAADmhBGVaC
 FSnSEADCa2x8ureq4afza36nLofum7QT0qAKOGPa9flVmb1TNJif2eaTJ2lh0pN6rABAFUOWVk1
 UtrUirqx7aPQB6NSCEgSD88S6IjKaVb3tp/ooftZrfDow3TDH3s5ZdP16+EPWvl0CUAI9LCPVtD
 HYmzUFhhZNSPB2gXdjPcfNWw0Ghx0KPjOEy0fmlG5qiSwtRfZpWAEc10S/9RZeApZfUm/RGG7W8
 qwUdwAFaJp6G+WnlMfaAE09z7fieWGmEs4OwaumWqzu2go85Fb2Tv3UuMdwRNAcle2Om4yEI0pa
 c+8uK/jTdaxfPI3z+9YsrBqROniQy4+a6AqLB7RpiM4udjuvrksmm51KIFWkoPJp293bJ+S2r/v
 PcSiTTsRwPuaC5gp3+gJQZo/1XhMj4LxhpH8nEXQCwsn+L5lHGQM2PQ2D7k57g3hGBHSTWMYokX
 xSYDUG7Tmscrm9srtEQ3OWhYbEogelrY8xv5bebW3VAi0DGkXlAQUeqSQ7WXfIt+rXbXYejEVUr
 UYu4/Z51Sk94L5J4ruodP6AhKenQaqJVcdhKInBExze1zxZhCPbO+v2WssNuBlJK+KRz9sQpdFT
 ULY4n68BkhGU2yQuEsJFGxC750hCac9E6wQFsy8NAyolHd3cuKgoe46YZbMYT5NfLTXZiUtCS6b
 5U1m3h0Y3xVhGrA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_break_deleg_cb() can run more than once per lease:
- __break_lease() calls lm_break for a read breaker
  (FL_DOWNGRADE_PENDING) and again for a later write breaker
  (FL_UNLOCK_PENDING).
- nfsd_handle_dir_event() and nfsd_recall_all_dir_delegs() call
  nfsd_break_deleg_cb() directly, possibly repeatedly.

Each call increments cl_delegs_in_recall, but nfsd_change_deleg_cb()
decrements it only once, at F_UNLCK. The leaked count keeps
nfs4_anylock_blockers() true, so the client can never again become a
courtesy client.

When dl_recalled is already set, skip the increment, the client expiry,
and the stores to dl_recalled and fi_had_conflict. All callers and the
F_UNLCK decrement run under flc_lock. Setting fl_break_time to 0, the
nfsd_break_one_deleg() call, and the false return stay unconditional.

Fixes: 66af25799940 ("NFSD: add courteous server support for thread with only delegation")
Fixes: cb7444b27c85 ("nfsd: add notification handlers for dir events")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 20 ++++++++++++++------
 1 file changed, 14 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c4c0f6cfa14d..5c2151b329c4 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6645,11 +6645,20 @@ nfsd_break_deleg_cb(struct file_lease *fl)
 
 	trace_nfsd_cb_recall(&dp->dl_stid);
 
-	dp->dl_recalled = true;
-	atomic_inc(&clp->cl_delegs_in_recall);
-	if (try_to_expire_client(clp)) {
-		nn = net_generic(clp->net, nfsd_net_id);
-		mod_delayed_work(laundry_wq, &nn->laundromat_work, 0);
+	/*
+	 * lm_break runs again for a write breaker after a read breaker, and
+	 * the dir notification paths call nfsd_break_deleg_cb() directly.
+	 * Only the first call may count the recall, since
+	 * nfsd_change_deleg_cb() decrements cl_delegs_in_recall only once.
+	 */
+	if (!dp->dl_recalled) {
+		dp->dl_recalled = true;
+		atomic_inc(&clp->cl_delegs_in_recall);
+		if (try_to_expire_client(clp)) {
+			nn = net_generic(clp->net, nfsd_net_id);
+			mod_delayed_work(laundry_wq, &nn->laundromat_work, 0);
+		}
+		fp->fi_had_conflict = true;
 	}
 
 	/*
@@ -6659,7 +6668,6 @@ nfsd_break_deleg_cb(struct file_lease *fl)
 	 */
 	fl->fl_break_time = 0;
 
-	fp->fi_had_conflict = true;
 	nfsd_break_one_deleg(dp);
 	return false;
 }

-- 
2.56.1

