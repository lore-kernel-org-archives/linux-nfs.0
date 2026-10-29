Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793281279;
	b=bZEvv60cvZLTDVSavQOlC/pmNRTPhIcJVPp4XQfXLWB6RLefr4bPkFFUR3uRdR59wv8a
	 oaNfiZ+AFQngYYEm3lOGPHlXoA41YlbX02NdLMCPK5Qf1BP7Te3wb+XiczbzOVud4TGl8
	 jRYhiTiiXGJquwD5Y9ITNgzjuKFqRCoZZm148+TaH13dflhenorecsopJEinzmR4KH7/f
	 ytTJ88kpxRz1sIjewuxqSRBrvtJy50eov+AfJLKvnwButWWocg/mudWYe1zS5Ni9teiSD
	 9p9QeHaPuVlJHj892k7w93nPDhd6Nq9a3SwMjRL4Q+Ayd2Y3sNzHJE/V8RaVehlNktQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793281279;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=vtb9KWEMa3uDFSRBIXvc3I4hYzMBWSewsfvqeklugec=;
	b=Kz01lUVQ0zz72grzELZToAmMFQ97R6C/wblQq43gzjTKa2nLxlvoB8qMRY0NABkBnEXW
	 0G2Qfbb/35A9fq0XZ1NxsVOCm94FypTf0R6nBwHoKN6/hRCWg1AwNPNaJsCU7eE7liJx9
	 Qc4PBK7CHRlnrQbN7BieySWivAhQOjIKOTIAk6l+M0r6RHJJaQLIg2MOToRW36rePtICF
	 4RGY+oCy8zvdklYGa5Om91L8P/0I8OI2g/cDRo9jzlBYEUzVqDs/gOjNmNzsWpU/JyPJY
	 koF0jPXk2FrGaf2asJcl6vKW/i15HCSjyXMeDKe167abS7EGo3IXfx2ji4IRnK2OVMA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eZhqgcm5;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A5E98606A31F
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 13:41:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eZhqgcm5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B86321F031E2;
	Thu, 29 Oct 2026 13:41:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793281278;
	bh=vtb9KWEMa3uDFSRBIXvc3I4hYzMBWSewsfvqeklugec=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=eZhqgcm59xeNDI24rX/XnYmM/WPmyclzHGf/8U8RC7OAO5hd4ICeEjHVaMAsK52Gr
	 fagyu7yoSPDNtpffthacWmc2ohBcdFLbeh066d+UG5e+mft/+kfyy932JU8kPcC28h
	 zPnn97H/DjyOmbOVVOa3lhgkkPoO4Ul4R7z4ID0kNBXmR5s2JUioYDQpINj5DiF5OP
	 CT0AR/OPckTGkp6Zi6iaTCDc2/rUL5TtjVHDEP4Uow/9Tjq8h0OYMjZtWnwA+0Ls1/
	 sn4iOKBBBiRuQ/H7NWKAYId0jUW4oncIkDdeCuzSLppQWNJEDXqMdm/kvY34VGjITZ
	 e8LXy3u/MwRqg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 09:41:02 -0400
Subject: [PATCH 04/10] NFSD: Give each client a display id independent of
 cl_id
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
Message-Id: <20261029-random-stateids-v1-4-8648878fec8c@kernel.org>
References: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
In-Reply-To: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=4872; i=cel@kernel.org;
 h=from:subject:message-id; bh=6iADjAe1zoUbk2MPuQ1RsON8xWJtS0Ipb2xaaOwCbOw=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq40z3pFd4SdXKvx0xn+frS1DXFAfn0LBrwVEsJ
 Z5cOvkItQOJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauNM9wAKCRAzarMzb2Z/
 l/0qEACxwSiUxZgQr2p7lbW1ma5l6Gb8E2R7KDywvGtuky78eETQaHMwyJQ20ovydWO0Fzf/b+B
 5O7ddKs3cC0E/kx32e4vVDClQJhPOGly8x5H4YuuJiQGKvrj6XntKP7jt7/nr2K8/XIx0PT5jSF
 kW1u5qnxob2kLjtU/9jq6QBW5mhJW9IaBib9G49W82Kivj6LUmGiO4gErx4YzJ3WiHaN+W7V0GS
 nBw/9GtW7E2b3RVCxmH94rwU7K/sJXVI6O71EfteAiXygdiriMhetEf8Z+ULVkeuZohO8ohOzgr
 nGQLIe6gIi/Vbj1gSiOt4UByvdbCcmn3NqOavdV6JnC4iw/AFRN0JpswHsF29nDwINaLttmYytP
 XHK5DFxJN0FunzaEt5R88n4P2kMhEyc2zXLAyZXFibgg40TNDa34LzdPBY09uHhQE1V12JIjcWL
 DBekw7oNKKk8xZu+pL/LKzFAgv8o3/V7XhV+fPQ/2dELzed+HaXMlFmMYJeYcnciG7yUy9ysHLc
 /iEpbFW/O1QsAQmHZ+89F+XuO8tWPkcJ4L6PS3WsTnZZ/XiEKXmzda/79GYCAlavPsDRJX1EvL1
 K9/lwBnw5ibPltHlXJmG4aTbUqyzHlrIjCwca8nzQ0TAmK1Eho7+4t1mLYnUXhIfvOaZTz6D0UC
 qCtLcd9/2qx7d0Q==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

The nfsdfs client directory name under /proc/fs/nfsd/clients/ and
the two pNFS block layout fencing warnings print a short client
number computed as cl_id - nn->clientid_base. For cl_id to become
unpredictable, the displayed number must stop deriving from it. A
random cl_id makes the subtraction a random number, and two clients
can then collide on a directory name: nfsd_client_mkdir() fails with
EEXIST and the client sees NFS4ERR_JUKEBOX.

Add cl_display_id, assigned in create_client() from a per-netns
atomic_t counter, and print it at the three sites. Seed the counter
in nfsd4_init_leases_net(), which runs once per netns rather than
per nfsd start, so the numbering keeps counting across restarts as
before. The printed values do not change.

atomic_inc_return() also closes a pre-existing race: the unlocked
clientid_counter++ let two concurrent SETCLIENTIDs produce the same
directory name.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/netns.h       |  1 +
 fs/nfsd/nfs4layouts.c | 10 ++++------
 fs/nfsd/nfs4state.c   |  5 ++++-
 fs/nfsd/state.h       |  1 +
 4 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index fa3545963902..40252a57bcaa 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -162,6 +162,7 @@ struct nfsd_net {
 	u32 clientid_base;
 	u32 clientid_counter;
 	u32 clverifier_counter;
+	atomic_t client_display_counter;
 
 	/*
 	 * Serializes this namespace's control plane: ->nfsd_serv and the
diff --git a/fs/nfsd/nfs4layouts.c b/fs/nfsd/nfs4layouts.c
index 2d9feed1b371..1baf38195bde 100644
--- a/fs/nfsd/nfs4layouts.c
+++ b/fs/nfsd/nfs4layouts.c
@@ -1125,7 +1125,6 @@ static void nfsd4_layout_fence_worker(struct work_struct *work)
 	struct nfsd_file *nf;
 	struct block_device *bdev;
 	struct nfs4_client *clp;
-	struct nfsd_net *nn;
 
 	spin_lock(&ls->ls_lock);
 	if (ls->ls_fence_stopped || list_empty(&ls->ls_layouts)) {
@@ -1143,7 +1142,6 @@ static void nfsd4_layout_fence_worker(struct work_struct *work)
 		goto dispose;
 
 	clp = ls->ls_stid.sc_client;
-	nn = net_generic(clp->net, nfsd_net_id);
 	bdev = nf->nf_file->f_path.mnt->mnt_sb->s_bdev;
 	ops = nfsd4_layout_ops[ls->ls_layout_type];
 	if (!ops->fence_client) {
@@ -1173,9 +1171,9 @@ static void nfsd4_layout_fence_worker(struct work_struct *work)
 	if (ops->fence_client(ls, nf)) {
 		/* fenced ok */
 		nfsd_file_put(nf);
-		pr_warn("%s: FENCED client[%pISpc] clid[%d] to device[%s]\n",
+		pr_warn("%s: FENCED client[%pISpc] clid[%u] to device[%s]\n",
 			__func__, (struct sockaddr *)&clp->cl_addr,
-			clp->cl_clientid.cl_id - nn->clientid_base,
+			clp->cl_display_id,
 			bdev->bd_disk->disk_name);
 		goto dispose;
 	}
@@ -1183,9 +1181,9 @@ static void nfsd4_layout_fence_worker(struct work_struct *work)
 	nfsd_file_put(nf);
 
 	if (!clp->cl_fence_retry_warn) {
-		pr_warn("%s: FENCE failed client[%pISpc] clid[%d] device[%s]\n",
+		pr_warn("%s: FENCE failed client[%pISpc] clid[%u] device[%s]\n",
 			__func__, (struct sockaddr *)&clp->cl_addr,
-			clp->cl_clientid.cl_id - nn->clientid_base,
+			clp->cl_display_id,
 			bdev->bd_disk->disk_name);
 		clp->cl_fence_retry_warn = true;
 	}
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 5f9c3f2f13e7..87fb85215571 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3983,9 +3983,10 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	memcpy(&clp->cl_addr, sa, sizeof(struct sockaddr_storage));
 	RCU_INIT_POINTER(clp->cl_cb_session, NULL);
 	clp->net = net;
+	clp->cl_display_id = atomic_inc_return(&nn->client_display_counter);
 	clp->cl_nfsd_dentry = nfsd_client_mkdir(
 		nn, &clp->cl_nfsdfs,
-		clp->cl_clientid.cl_id - nn->clientid_base,
+		clp->cl_display_id,
 		client_files, dentries);
 	clp->cl_nfsd_info_dentry = dentries[0];
 	if (!clp->cl_nfsd_dentry) {
@@ -5738,6 +5739,8 @@ nfsd4_init_leases_net(struct nfsd_net *nn)
 	nn->clientid_base = get_random_u32();
 	nn->clientid_counter = nn->clientid_base + 1;
 	nn->s2s_cp_cl_id = nn->clientid_counter++;
+	/* So the first client directory in a fresh netns is named 2. */
+	atomic_set(&nn->client_display_counter, 1);
 
 	atomic_set(&nn->nfs4_client_count, 0);
 	si_meminfo(&si);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 5f4366848671..4ed417bf2262 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -570,6 +570,7 @@ struct nfs4_client {
 	bool			cl_mach_cred;	/* SP4_MACH_CRED in force */
 	struct svc_cred		cl_cred; 	/* setclientid principal */
 	clientid_t		cl_clientid;	/* generated by server */
+	u32			cl_display_id;	/* human-readable client number */
 	nfs4_verifier		cl_confirm;	/* generated by server */
 	u32			cl_minorversion;
 	atomic_t		cl_admin_revoked; /* count of admin-revoked states */

-- 
2.56.0

