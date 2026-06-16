Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 66BB944BC91;
	Tue, 16 Jun 2026 11:59:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781611159; cv=none; b=BbLO8GNEgsbL0Nr01oUKyK+IfMz+Eq2Ze9Ib0zyYI7yf1HR2zsP1oaonksKbsCi5e4XlU4bHK88Wjlt4cHKofyj9eeWQ37eurnHEQ86ZfwGiclEQdUYFINgHEG4K/Gs0IfBeTYRwlAZY92mbvEk4htRVmXM8gpO4JDrZVhGnWc8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781611159; c=relaxed/simple;
	bh=UHIDckaPpoRl9XMf5pwvDQYsIWtGnLynkL2xh6wGGC4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Wjk+gRTOT9u9NHE35z/5v3cZcIFQVfGgUoYWtnbgPKU0kB250iX01yuWvikjTEJcP5FNMkpRByTbxFZgN8gRmUwzMV+nvx16GmbjXaa5N8dn2XXoq7D0JS6u084+aNBMysy5k+enfcLHB28xj9U1Zc1O/reCZVHmZls3/7iUYrA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GnJlZBy9; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GnJlZBy9"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7B35B1F000E9;
	Tue, 16 Jun 2026 11:59:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781611158;
	bh=0Hf7WIq9PUXdLXS7/GfDTHUxhBcb+wOB48A7hRbLT+0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=GnJlZBy9r5XyS8lkO/EWU/JN3Z+MB7q8rBe+3WZ7lJWhvQEQBZwrcgqo/hVFTwYDD
	 oBpUoQqGbUFDXmkAuWVcLPglca8gfMOt2IDWjl7zSBRlj/nlhR9GwSkPLY95DgRFSC
	 lcElTTqaWpEnboErNPLHi2bOH0ITvNkS7xYgPomUia/wjvJfJ5DKY5aLgsZd1InbV3
	 noeJMFg7SiP5oJnz+Z9IIVYhldRH4jmbCKpak6bfhV97u0OEgVvOj11PZy1N+L6PIU
	 1Qxpttfm20CrQabD8dCKoEAM/g6kpTCuHlt8zvB6SWH5sA6WilWZOLOTBNLJa9IUww
	 XynCu2rfJVD0Q==
From: Jeff Layton <jlayton@kernel.org>
Date: Tue, 16 Jun 2026 07:58:49 -0400
Subject: [PATCH v7 06/20] nfsd: make nfsd4_callback_ops->prepare operation
 bool return
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260616-dir-deleg-v7-6-6cbc7eac0ade@kernel.org>
References: <20260616-dir-deleg-v7-0-6cbc7eac0ade@kernel.org>
In-Reply-To: <20260616-dir-deleg-v7-0-6cbc7eac0ade@kernel.org>
To: NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>, 
 Jonathan Corbet <corbet@lwn.net>, Shuah Khan <skhan@linuxfoundation.org>, 
 Chuck Lever <cel@kernel.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, 
 Alexander Aring <alex.aring@gmail.com>, Amir Goldstein <amir73il@gmail.com>, 
 Jan Kara <jack@suse.cz>, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Christian Brauner <brauner@kernel.org>, 
 Calum Mackay <calum.mackay@oracle.com>, linux-kernel@vger.kernel.org, 
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=3301; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=UHIDckaPpoRl9XMf5pwvDQYsIWtGnLynkL2xh6wGGC4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqMTqFAH3HfwJRmuvyhFQ3EvZ0ThtMbtrCVG/C9
 5+yDkTeyniJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCajE6hQAKCRAADmhBGVaC
 Fc6dEACefOUAApwUq4N+Uy/cDcS4jFAR8BgtLo3PXvrPsMAwn5zdmhxDFE9OYbAO7vx2HbYwsmw
 VDk6oFcN1Ap4eA9BEn0oDpK4u61L4/7k0I0//inVBYgWMe1burP6QZhPt9Zq7e7/7XiCs5NxCng
 ZBfYld8Aor6wSiLfzVMBODuWW96mRp3hotK2IQ3Oz+u7mboNAlQltQ/xxQI/yTqplacKSyuU4Wh
 pDAEvl/SiI5EDjvvWtYOZqH3YQzldndhMsXw+rqZ2RU9TNOMy43qXobRj+vCDqKfxVSm2Hx61R+
 szSpcX/+NDU83lvDNlGzIfWt2seZClwEy+z+c8ZDUv1UsRZIR3oSRJ4+yXNDZbQuOV+JCdb/LpE
 NRoHdGHZ4pLHwTmhXKJ7tW1R9u11NjrPbl3xJSlCaS5opxy3tw8M1k8OosPmjSPnlcqCiaubQIx
 W3LBi3qV/c2svTsSsq9W8NMca2mX429frDJjABMnDuv7wPyqdJek2UfRdYroouDAhyLdThT1r3H
 hiXNc3Ut8toSK3JW6RyW840GdqBHKL9JTNNakp/zCnAM509dl9GD6ZCGnkYf0gSfbRwg3LyzitN
 ss7BD+XGyoIJ4QQ77wRG/HHE089RTkA8cmqabozZWzNR9TMoSuoOQfP4TEeMi0ZFVMPzmUZ5ML8
 mTxEF2hFozMiRZw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

For a CB_NOTIFY operation, we need to stop processing the callback
if an allocation fails. Change the ->prepare callback operation to
return true if processing should continue, and false otherwise.

Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4callback.c | 5 ++++-
 fs/nfsd/nfs4layouts.c  | 3 ++-
 fs/nfsd/nfs4state.c    | 6 ++++--
 fs/nfsd/state.h        | 6 +++---
 4 files changed, 13 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7c868afc329e..c7f914eab3b0 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1790,7 +1790,10 @@ nfsd4_run_cb_work(struct work_struct *work)
 
 	if (!test_and_clear_bit(NFSD4_CALLBACK_REQUEUE, &cb->cb_flags)) {
 		if (cb->cb_ops && cb->cb_ops->prepare)
-			cb->cb_ops->prepare(cb);
+			if (!cb->cb_ops->prepare(cb)) {
+				nfsd41_destroy_cb(cb);
+				return;
+			}
 	}
 
 	cb->cb_msg.rpc_cred = clp->cl_cb_cred;
diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 279ff1e9dffb..4c3f253c7d07 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -659,7 +659,7 @@ nfsd4_cb_layout_fail(struct nfs4_layout_stateid *ls, struct nfsd_file *file)
 	}
 }
 
-static void
+static bool
 nfsd4_cb_layout_prepare(struct nfsd4_callback *cb)
 {
 	struct nfs4_layout_stateid *ls =
@@ -668,6 +668,7 @@ nfsd4_cb_layout_prepare(struct nfsd4_callback *cb)
 	mutex_lock(&ls->ls_mutex);
 	nfs4_inc_and_copy_stateid(&ls->ls_recall_sid, &ls->ls_stid);
 	mutex_unlock(&ls->ls_mutex);
+	return true;
 }
 
 static int
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index dcb282f4fe67..2189d8d360af 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -357,12 +357,13 @@ remove_blocked_locks(struct nfs4_lockowner *lo)
 	}
 }
 
-static void
+static bool
 nfsd4_cb_notify_lock_prepare(struct nfsd4_callback *cb)
 {
 	struct nfsd4_blocked_lock	*nbl = container_of(cb,
 						struct nfsd4_blocked_lock, nbl_cb);
 	locks_delete_block(&nbl->nbl_lock);
+	return true;
 }
 
 static int
@@ -5613,7 +5614,7 @@ bool nfsd_wait_for_delegreturn(struct svc_rqst *rqstp, struct inode *inode)
 	return timeo > 0;
 }
 
-static void nfsd4_cb_recall_prepare(struct nfsd4_callback *cb)
+static bool nfsd4_cb_recall_prepare(struct nfsd4_callback *cb)
 {
 	struct nfs4_delegation *dp = cb_to_delegation(cb);
 	struct nfsd_net *nn = net_generic(dp->dl_stid.sc_client->net,
@@ -5634,6 +5635,7 @@ static void nfsd4_cb_recall_prepare(struct nfsd4_callback *cb)
 		list_add_tail(&dp->dl_recall_lru, &nn->del_recall_lru);
 	}
 	spin_unlock(&nn->deleg_lock);
+	return true;
 }
 
 static int nfsd4_cb_recall_done(struct nfsd4_callback *cb,
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index f44ea672670f..4c6765a4cf22 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -98,9 +98,9 @@ struct nfsd4_callback {
 };
 
 struct nfsd4_callback_ops {
-	void (*prepare)(struct nfsd4_callback *);
-	int (*done)(struct nfsd4_callback *, struct rpc_task *);
-	void (*release)(struct nfsd4_callback *);
+	bool (*prepare)(struct nfsd4_callback *cb);
+	int (*done)(struct nfsd4_callback *cb, struct rpc_task *task);
+	void (*release)(struct nfsd4_callback *cb);
 	uint32_t opcode;
 };
 

-- 
2.54.0

