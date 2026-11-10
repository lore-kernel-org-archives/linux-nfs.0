Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794332666;
	b=bIlJOqor3iqzjI8fQ3H+OTQxadPMyFabpB3bFtjA9p3qHXDmUDTg6CjjEYVE8nybHGJn
	 nINlUmGvCPzPBa9NcenoO7KrBL/89rxQqz9HBhv/NLRDrFTz7JlIZmf9WTUCAXkmpFY99
	 vnP5ZaGrN5vFk/PWmIams2yzihekj/8QYNZa4awU+mGOg4Xcn0RmhuqQw4mYloSr+IlcO
	 NEmwdkToeMwgfwjWGHmymlfraK8NnFoBjfbm5Qb7p+b5kXXfSohhdKNH2tl5AMhRrsQyn
	 vR8RgucBoEfxuaB3B8bnCq3B8EC9IiILSTj4ceH34FYBSbukbBhM5gGufyYubVbskEA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794332666;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=R56fmqGuZpB54JjB/UFYIgCObxMigvMWY5huWCREW8o=;
	b=lz+b55xlVB+cZwffGIhHsSdLbYF9GF+egm0TuonW1dXhc84jVaiyIGiQrEzw46dYN0iK
	 LAJLy0kUSz7iNkFzKyF/BVw+OTIEsk4R1qus090W8bq3ncRAMh7XO5xs/0WAzaSX3AWhr
	 Q1zKgeKb1jC4Ug4WO8cy92ni+F3u+Kx3zPSlbjUWLul9BUhFDPeNwrD9OJtjNk0OM9G2m
	 SiAYsoPoRd9ZIKCTnhxlla6p3Cl2u57UD3CgsXPszugi6qrZPRP9raIBs+aKhzpNthKxq
	 IOJq9l+Zn26Coi7GTuv13csXXQ6VFw3S2zurE6A3/zsfVDKgWxLU3Ag5eg0tnJ74z2g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eOFjm5Jg;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4EDEB60A2603
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 17:44:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=eOFjm5Jg
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7ECE71F008A2;
	Tue, 10 Nov 2026 17:44:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794332666;
	bh=R56fmqGuZpB54JjB/UFYIgCObxMigvMWY5huWCREW8o=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=eOFjm5JgB7P7j3HMzdtmfl35GEQhQRTZrzYiUQ8eKNR+wpSPzdaTIvkdDHNS1u0+/
	 pi17LmA0f4gLAbsYFrf1soQ2yjRKsY6a6VZOe5b2FgSrjvJKosP2l4qgO7MPIzVvQY
	 yjf2hd9sNqvwIfVL0AHLH0U+iwAFG2PaBWJTWt8NVQQGtburtWRs/Z0e7kF0XeYmfZ
	 gN6W4G0SOpWEdTfG5/j83CUFAj7foOiKNm8ustvpeqatpfyLG/y5kpsMwTlqC9Q3VP
	 ShnrT+ijgDfwzvOrc0mS4Js2/8l83xRbTVFidLsix9FPP5vkWEKG9qBdF+3eCNw1BS
	 A7gNd8hxcNxOg==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 10 Nov 2026 12:44:11 -0500
Subject: [PATCH v2 04/10] NFSD: Give each client a display id independent
 of cl_id
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
Message-Id: <20261110-random-stateids-v2-4-57e0996eb2a2@kernel.org>
References: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
In-Reply-To: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=4919; i=cel@kernel.org;
 h=from:subject:message-id; bh=kBnAV77d8tpvUwFR+Ti1ImUJc8EBNqmc+gSoNajeCUc=;
 b=kA0DAAoBM2qzM29mf5cByyZiAGrzV/TI8Qwj56SAA8xGQhzE6apT1nfjgSLvnyXwnVEkfPWG8
 IkCMwQAAQoAHRYhBCiy5bASht8kPPI+/jNqszNvZn+XBQJq81f0AAoJEDNqszNvZn+XBFUP/Ruw
 1ANoO4JWjXGjxOsuSIcHhNnI9mXZSA57B129B/zHkCsV92/Ge3MrsI87yAfq2Yijv1748Wle0Lc
 EE0PFO0hNWGxOvbGaPxowN+iv4iBusbqGrDBwtvI2URnwRqYcb6C121dGH6EQ4W8rWbJvLpX4AS
 1gKT+vEteUZcy1QhSltNKPXHjE9sO09EdbAIqAh6j8Dr5CmI2ngenxW1XeI1EZVSo26UNmM6Im+
 qWjaiqCmwggScMFbdD7nNYU+GkR4lhHDebEO38HWvEW6JeVXQU66vcPS5tpRvNg9uCNFOAt7b4h
 GyLsDs2nAPnqveO1IygJrtZI4nEXtjgmGJnFBEYyLqgnLr6COko6dnatejF3QCi6nmmH0lGm34R
 q8buIHjIRuKo1/nkoHcRjyADRruORR2KLqiufkdjsWf7tBZY8Z8r1tKJobOzdFnwNVHDxwpN2Yl
 HXESnO2W8LD0y1pe/mGod+cMkJ0bBV0b2jueDKQMdQvSV3k0hvkAUJ8QFikk5ZcFEMDJx3AcCVa
 5j2DASHJVAZJ49mDhtDDdG2a1dp0RKye/chpCSaYTMo/Uq5T0p5ANKPw5UeJH7XIA5sgVL644FP
 UjYVR9Sg3/RoYH1Ripv2APwxfWlwXc4FfHfZi9gT0pRYb0RDBvr8hR4W0GJjyEpiRFZzIfcu0Jf
 +Vycc
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

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/netns.h       |  1 +
 fs/nfsd/nfs4layouts.c | 10 ++++------
 fs/nfsd/nfs4state.c   |  5 ++++-
 fs/nfsd/state.h       |  1 +
 4 files changed, 10 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index 66e8cfff238b..da39d064f5e9 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -168,6 +168,7 @@ struct nfsd_net {
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
index 56d2944c91e7..845ded94f81f 100644
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
@@ -5748,6 +5749,8 @@ nfsd4_init_leases_net(struct nfsd_net *nn)
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

