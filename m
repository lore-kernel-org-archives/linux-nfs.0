Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792702440;
	b=HLwGVkgKX/FnXHh5vGThVB08xIB1wARmY3sRlKP+MAWz7qbqYsGGwPkE1XUfvuiCOd6B
	 EFVgVtf9s6LbRKvyEH1gQzoka+P1s0PHHqk6B/Ir56UD8ppPKKBFrrOcvbfBN6gy66twS
	 MZQbe+xLNQDPFiJvSOSz1sPKqnvcSRfIAkLzz4WrjJfNa/HiYLQ6oz1c6/1Usc5eEAM1U
	 7OFN4wUncuxfl5TQtzVPP0H37s87zfcG/Vo7r0LfgH+/SDy6aRUFiIU1zYCnnKDdGQuRM
	 +lYh2P68iILTslmzk1czseAtw8Ifi4y95QC8n78xoRVXyxuoWsSa8t3eQbrBdID79lQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792702440;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 MIME-Version:Content-Transfer-Encoding;
	bh=OfF5VQBX8+FpvRRHsdD+Ho28/GSeQhKKMW4P+H4zV+0=;
	b=p2H6blmWGkkAYsgpMUqaXLVQ+ONgy+75sz1GcDc4DNv4ORNXP9TMh1qHfclXP/zj+ssE
	 4PI6+RIbaCkyBd5L87Y+KzIQSx2GeVHwYYdTesS2Q+a6/srYsGmy/2faHGQM+6zXTlh6T
	 LAEzOc6l5TxvKAsfeRrb3nzVb2UK/H+XUZzGNuuMBRBwrRanJI53P4rx4WokoFHk4FTvf
	 pZ+6yII/bMUnAq9Zat0pbWutb+BiiPQ0T9/d7rFCvuArzGpr/AR3AD2tkdCtMCm1ekD9h
	 pm+4rPcwsJcuqSJhzID1aNWWED984LdQALuRbZ7MZPU1TRy728/Bfvj2SfSUm7RGTrQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Kgj0iHvP;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 6B369606A31A
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 20:54:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Kgj0iHvP
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6B0E61F01825;
	Thu, 22 Oct 2026 20:53:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792702440;
	bh=OfF5VQBX8+FpvRRHsdD+Ho28/GSeQhKKMW4P+H4zV+0=;
	h=From:To:Cc:Subject:Date;
	b=Kgj0iHvPbEFdIohXkOZt17qdC/rNffEjQaLnjNcL58NQ0bg0jcOAu9z45H7ZtEgR4
	 DjxvwSae7dSdMQin7WHuI86PURnvdCm/GYbCJvj+FAovc9Nx5+PnQH+4B9DhyoOwE4
	 B1BSu2LlY8nUf6uIk8BipAJUwS8aSoaQnhm006Fc4VHYKSGCtZmO96Bydy9GKS+LRL
	 txOBpo5HauvmQkyZIgSKrxwZuR/Hay+CznOOeXzuUrKHg325f+wF9okXLp1xYZBEp/
	 NH9cMZdKW7nCamB203MesdQ/v47KZgBe3pRGrTsiot1AJMzX4PqIsor0bAiqzEY99O
	 N21yimvuAKYVw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Mohammed Alquraini <mohammed.saad.alquraini@gmail.com>
Subject: [PATCH] SUNRPC: Fix use-after-free in svc_age_temp_xprts_now()
Date: Thu, 22 Oct 2026 16:53:57 -0400
Message-ID: <20261022205357.3239985-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

svc_age_temp_xprts_now() moves each matching temporary transport
onto a local list under sv_lock, then drops the lock and walks the
local list without holding a reference on any of them. In the
meantime svc_delete_xprt() can take sv_lock, unlink the same
xpt_list node, and drop the transport's last reference. An idle
temporary transport holds only that one reference, so a peer FIN
that arrives between the two loops frees the svc_sock out from under
the second loop. The notifier then sets XPT_CLOSE in freed memory,
and svc_xprt_enqueue() reads xpt_flags and xpt_server from the freed
object and queues that object on a pool for an nfsd thread. KASAN
reports a slab-use-after-free in svc_xprt_enqueue() under
nfsd_inetaddr_event(), with the object freed by svc_sock_free() on
an nfsd thread.

The two-phase walk dates from when the second loop called into the
socket layer and could sleep. Commit 546125d16142 ("sunrpc: don't
call sleeping functions from the notifier block callbacks") moved
that work to the nfsd threads, so nothing left in the second loop
needs sv_lock dropped. Mark and enqueue each matching transport
under sv_lock in a single pass, as svc_age_temp_xprts() already
does, so that svc_delete_xprt() cannot unlink and free a transport
the notifier is still touching.

Fixes: c3d4879e01be ("sunrpc: Add a function to close temporary transports immediately")
Reported-by: Mohammed Alquraini <mohammed.saad.alquraini@gmail.com>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 net/sunrpc/svc_xprt.c | 16 ++++------------
 1 file changed, 4 insertions(+), 12 deletions(-)

Mohammed, thanks for the report. Please test and report your results.

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 5db42e53be62..076c624fe675 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -1075,29 +1075,21 @@ void svc_age_temp_xprts_now(struct svc_serv *serv, struct sockaddr *server_addr)
 {
 	struct svc_xprt *xprt;
 	struct list_head *le, *next;
-	LIST_HEAD(to_be_closed);
 
 	spin_lock_bh(&serv->sv_lock);
 	list_for_each_safe(le, next, &serv->sv_tempsocks) {
 		xprt = list_entry(le, struct svc_xprt, xpt_list);
-		if (rpc_cmp_addr(server_addr, (struct sockaddr *)
-				&xprt->xpt_local)) {
-			dprintk("svc_age_temp_xprts_now: found %p\n", xprt);
-			list_move(le, &to_be_closed);
-		}
-	}
-	spin_unlock_bh(&serv->sv_lock);
-
-	while (!list_empty(&to_be_closed)) {
-		le = to_be_closed.next;
+		if (!rpc_cmp_addr(server_addr, (struct sockaddr *)
+				&xprt->xpt_local))
+			continue;
 		list_del_init(le);
-		xprt = list_entry(le, struct svc_xprt, xpt_list);
 		set_bit(XPT_CLOSE, &xprt->xpt_flags);
 		set_bit(XPT_KILL_TEMP, &xprt->xpt_flags);
 		dprintk("svc_age_temp_xprts_now: queuing xprt %p for closing\n",
 				xprt);
 		svc_xprt_enqueue(xprt);
 	}
+	spin_unlock_bh(&serv->sv_lock);
 }
 EXPORT_SYMBOL_GPL(svc_age_temp_xprts_now);
 
-- 
2.54.0

