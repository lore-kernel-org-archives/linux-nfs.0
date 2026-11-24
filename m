Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795549757;
	b=x4SWcMZbKmJMtmN41yH4D2lEyz9T0GlA529YakwkVSNHU/G1fYRdjqcjGrvfhZqdhGWo
	 UG8LqnLnswIdFVdZHdRYU/a+o6vZ7/tyO9Qz57Sa6bve3F8Jk6bg7ZV5PuqseU29oHn43
	 7ViMbUaVi3HTzhbVLrQCHgmJN8g1cA6ZGizDu09tY6txf4GKPeDq5sWt0LXcJyYHZB/XZ
	 V7mwLFBdBZIbpdzEwz4APB8tPBUvknbgd6j6z5blCTr9grjVnNnZn3aueABmIUGC/Y1v6
	 egcQlIKcJGpn3hLzX8d3GCag5WUjeH0p0tyGUB0Qlx2XR6PCR6MQsBUh00v695oqNlw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795549757;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=DdV8mCrVdlTy+W2zhIYE2Cj4xwzWt453izMOIQetGoo=;
	b=Y8TDIo0+Ka4zS2GfjgS6XKkv8P5mf0oVyXyMGoC2wSWqAzGL/Empyq/Vfzjb5Eb3lnEh
	 8xc7bU60MiOdnH0esBkTqFAqxGakCyyowwwNWEsfCotKrMYTy6+D88QvWDCQrnauxtvA9
	 c0HX64J47xuvxpa72LwyiyinTB/rF6f1hMKn4Dl7h4bSvMgIhT9zNF46+VYDZUrJVCEdu
	 TD9JFrnkeXSwQf3JL0TGPYqHXozdKFAubJXkdykRqXTuNZ50YgN/8diRH6WY0z73mZPNA
	 sAUoMsg+2Vykh1blDZOX28FFYUXGJP5yPZ/ZR3kuP37nRklDASxBuH1GV78LeLJnqTw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PfpF7sHP;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6EE2B606A337;
	Tue, 24 Nov 2026 19:49:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=PfpF7sHP
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3F6581F000D2;
	Tue, 24 Nov 2026 19:49:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795549756;
	bh=DdV8mCrVdlTy+W2zhIYE2Cj4xwzWt453izMOIQetGoo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=PfpF7sHP5D+UdHbKu7hc2OG87EjsVqFU155APx6qjquQPt/CqItTGRP65kNR50jOS
	 TcZJfFNGjZ4XkIiAcJ8X0A06R2hr7pd9Mj7OlMYzyNq1u8KqxBLq07EVvlsEk4Lcfm
	 UOPp5rDXgluE5TH0+StnhohcbdKn2TU6rGz3vTL6JTUN89qSfUg0rgmFRlLbHGJ4hW
	 TUJHpA6SOyHyRTHb3S4l/5t9Gv9JS0WGnBJU7IAb2xCANSNMARvtZipOUGZxxgf7pN
	 9SvRotM/cnlqF8llS+t061q/gqVUC9Nj4c49tcbyzO4nhAW5lC27UARPzy10iiK3m7
	 R7YZvYO8uKuSw==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 24 Nov 2026 14:48:42 -0500
Subject: [PATCH v3 03/12] nfsd: count a delegation in cl_delegs_in_recall
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
Message-Id: <20261124-delegts-fixes-v3-3-6fe4ba705aef@kernel.org>
References: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
In-Reply-To: <20261124-delegts-fixes-v3-0-6fe4ba705aef@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2392; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=XsSZC4Cb4n47zUuvLr9M3tVFz4Y1vPJNNnSmdy8nAi8=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBeo1QoTCFQhsiym7XiX/nIAeD5mI/PdqhbUzK
 HjzYDhgmd6JAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawXqNQAKCRAADmhBGVaC
 FWk0D/0Ywle/Jp8UgC49gr9gWuV5TYjAJi2Fn7zR/Gild916zP+w8RCph1/OvbbuBJTHgAFAgPA
 D3S5eybQl+28l+cbyYkZf7n0Q/PRe3r9V89kCM6eEJGAp29hopGcpmdMpUpW5CIref4AhrgqiL0
 5GGmGJ+digfr5NcqZk1ru6r6ew45ovkGR1EGU1Ie4oNBKTRejUYjxkTT0f73pOKW+hUZVMlGJ09
 VHm0Zyi4xKWewHZNz+ydReUKfMBwYOse2lDvyRCeEdvKtZaBlu+uqucdl3HPFNsGGUSrIQKiJMv
 tNaSx/O5R5rkMtUl0jZHQeJkXiZEd1+Fvvcb0BhtNwDlENbzJp1zmHJrgjAI1AuShF9WOD+J4yw
 pJl4OpEFgR0SxWXWwgIY2zua59UcZ9cEB+nGIPuX2J3947RBo0GEuQ012pK/CEqqffU90DWyuCR
 HmqTXH1QySy4gctMDibXqJylZMXYhmMfQy4wCexFfidaxzqcGEGh7myXZ4FezCaeFqGsaHnphZ3
 mtS+RKHTYQHOkq9GTjMmsZydMllngXPzPVm4EEUEkzwJI7nPgrJHZY1YRyLoIICcwj60X4iTgdw
 /OJN7y0mP1dalVosG5m4abyWRMHMZT7BKdnwft6G0ONoHNfyF2M7LeZ20JjfD+SYFQ6SNIei+el
 0XC4YcacISO2d+g==
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
index f3d1065d3448..c2c082006d81 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -6654,11 +6654,20 @@ nfsd_break_deleg_cb(struct file_lease *fl)
 
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
@@ -6668,7 +6677,6 @@ nfsd_break_deleg_cb(struct file_lease *fl)
 	 */
 	fl->fl_break_time = 0;
 
-	fp->fi_had_conflict = true;
 	nfsd_break_one_deleg(dp);
 	return false;
 }

-- 
2.56.1

