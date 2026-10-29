Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793281282;
	b=tXJ8zf4IllctxBjJjzhnnDKkOC8WQZy/5eKoTWW27xaYruxyYK+RDg09WZv1x1A6fehC
	 IlYe1wpNJnpItC6p6yMU/zx9gEUYX5lfyyEd0UoSQtQ2ktQV6QKp9BoESfppbWl6dFi9I
	 kL7ErD5j1TDT8/oBlTQNB0xeZfveUeryyguOOcw8O/Fk9TMR1z6OVqxGJE5sb9Ai6ImXQ
	 k1RZ+fZ4QYk9KduaTk4dszGqTJjylM6np4tdmdXO9likIRRiLLOXseMHimCUcQg5lyVJV
	 MVDegyBa42c3RXM01lNHyRHV1VqtlPE9lVSgj6WWPEUXxlgFxaJKpZ+KKFnjpl+PwNg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793281282;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=YykY1h0vsEP7iI6IGeQZJRI2CizACCWjN/47EdIXV68=;
	b=L/SEmovINJ2vC3J60M8WDNqeNLOtbeeC47+nTITZt0ACp+RRCmQb0p5Pusc3ocLq1vGI
	 OcZV9xLlTqILmN+v/FYXJeL2rSZb7lFUbZvcjOVyhvZKzOCstPF2A8pui0Fb7jEcswsnz
	 dYsnZY+dLIYx35Igo6z82L1pqGRzE+xVlEOFbjcPhLhxa4yZW0i+0J5GRIS29+IteDSVP
	 19UFN95keiQROya9CsSnE5To6zn3x97nJQ9u8mVGsyDqa3nX/EjJSoeQzSijTAvrt7VzP
	 NTTRIgiKgm3Pvq5krVcwcSyE7CY/pHqiF7FzRCa845QswIX4dSkI+reudZvPxx1kn6A==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kpPNyQdw;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A80F0606A32E
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 13:41:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kpPNyQdw
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C815F1F031E2;
	Thu, 29 Oct 2026 13:41:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793281281;
	bh=YykY1h0vsEP7iI6IGeQZJRI2CizACCWjN/47EdIXV68=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=kpPNyQdwfKy5TT/3Nu31ODOtkVH784iLjEy04Vq8/vNVlR6lq+0ZDdijjfq2esGC6
	 Flx1R3s5NVcZMoOju0kKf+Tit5BumRjahYutHZST07qlhpwUuvbbzOjUZLU4pioJdH
	 Fdqq5UeAC3ej5oLDBPrFVqzBOSwwjlc1gMj4DbcXHT5gRNm53rW5e2tGZHV6hXbomF
	 2bKlln4+No4ZL/zxEqK8t1ki2DGo0C9eC9MgmHz8BXsBImWBPxe3qm+9P/xnwoP4YE
	 UNWhKC9ni17WGyYoAEIvjC4mknG8XSNo5jgXWq8xtfCVyjs8auVOwqu6Yi6KifOXrg
	 LBVWygN2aywiA==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 09:41:05 -0400
Subject: [PATCH 07/10] NFSD: Destroy the COPY_NOTIFY stateid IDR at netns
 teardown
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
Message-Id: <20261029-random-stateids-v1-7-8648878fec8c@kernel.org>
References: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
In-Reply-To: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2242; i=cel@kernel.org;
 h=from:subject:message-id; bh=HyFvpNz25844i755wAJApfvW10A5+jLv7IIaTO7BBG4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq40z3p1EFruamdJNm6HCKiBnGaydEOqwB87q8a
 wFzZdvCjrKJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauNM9wAKCRAzarMzb2Z/
 l3XwD/0eat6Mr57ZoAMAehNe5+qZsiyViLPhBflwGfphJ9EwGh/jelxIlS3Cx38fFomlCfJnnGu
 M98euUHqKnza05KnKwfu0ptbaGpc4nZ+HVOt7oCKnFqbqF63O6nbOSgV+mLCc3Vm+fnvcEq6/s2
 uTpdTuw/7kTYIXkSIjmliePq4EMJzCSmxBzxwwWs6bvfsh7USndW56FP9oiarWCX9hoohAQKnbQ
 CV7klBiSAnMuAjh1YOeds51O+xcG9GEBUVXSoSE1NvOKheAsotYMUhqEzi5DratVhkyh1vnnyTX
 ruRek4FE0rrz49KRr6k8ZVB5VRDFpA78lua5gw9+mPlMU99zy8dcOBpKJ+ou8d9ZnpQEFW3x2NS
 2nyzDmYTgyJGF1NAuIyAOu+OMNfbuHxrVSA0VOPxi3pUJ5MrOWN6kTeotbGfp0KWCaqhXj9B5Hb
 gX3DqVEpSaEwMoE3Z4KXd0EhtmHnwLSfmpextxFheuu4d1dSZRBk8DOzuC2dKJcaJkSkhp2KasC
 0dl2kpFT+12L2jEKm17NZkA1je9Qonw5r8YTbvoaFUTITMyafgHb7TMpClteT+TxLHFcnCRDrZU
 E/EMdykVD6//7Wbz3F1VM0HCn0go3IjzmU7r56gp9nf0gjYa1wElpxImkJwPhGjNt/r+XdSDRKQ
 xjSXaJfXTTQAnUA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfs4_state_destroy_net() frees a netns's client hash tables but never
drains or destroys nn->s2s_cp_stateids. The IDR empties only as the
walked clients' stids reach their final put, and
nfs4_state_create_net() runs idr_init() on it again at the next start.

A parent stid can outlive the client walk:
nfsd4_deleg_getattr_conflict() holds a delegation reference across its
callback wait from any netns that exports the same inode. The re-init
orphans that stid's COPY_NOTIFY entries, and a later idr_remove() by
so_id on the fresh IDR can remove an unrelated entry. The IDR's radix
nodes leak as well.

After the client walk, revoke every surviving entry and destroy the
IDR under s2s_cp_lock. The late put then finds an empty sc_cp_list and
never touches the IDR. A survivor draws no warning: a late delegation
release is legitimate.

This patch depends on "NFSD: Serialize forced client expiry with
state shutdown", which keeps a forced expire_client() from running
after the walk.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 15 +++++++++++++++
 1 file changed, 15 insertions(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index eda976e826cc..78f69a188d34 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -10369,6 +10369,7 @@ static void
 nfs4_state_destroy_net(struct net *net)
 {
 	int i;
+	copy_stateid_t *cps_t;
 	struct nfs4_client *clp = NULL;
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
@@ -10388,6 +10389,20 @@ nfs4_state_destroy_net(struct net *net)
 		}
 	}
 
+	/*
+	 * A parent stid can outlive the client walk above. Revoking its
+	 * COPY_NOTIFY entries under s2s_cp_lock empties its sc_cp_list before
+	 * the stid's final put, so the put never reaches an IDR destroyed here
+	 * or reinitialized by the next start.
+	 */
+	spin_lock(&nn->s2s_cp_lock);
+	idr_for_each_entry(&nn->s2s_cp_stateids, cps_t, i)
+		revoke_cpntf_state_locked(nn, container_of(cps_t,
+							   struct nfs4_cpntf_state,
+							   cp_stateid));
+	idr_destroy(&nn->s2s_cp_stateids);
+	spin_unlock(&nn->s2s_cp_lock);
+
 	kfree(nn->sessionid_hashtbl);
 	kfree(nn->unconf_id_hashtbl);
 	kfree(nn->conf_id_hashtbl);

-- 
2.56.0

