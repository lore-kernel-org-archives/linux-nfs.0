Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3CDDA42587A
	for <linux-nfs@vger.kernel.org>; Sat, 15 Aug 2026 16:39:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786811943; cv=none; b=PFrd62F1xkWEpOV/LgRZHrH5Ho1Yi78SJt5tjbM3Vzj3nsSx+kCSCNHAIjMA7YyD5C10Z9GOl0gH5XbvbwnbtooCmiVJ/CUx+zLn63Rv2uwg6F2wC3zJA7JISZcy8G3yF39zwgA2A9q1VrQkRtg3EGRqwkBY/whLTE37LUWSQPM=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786811943; c=relaxed/simple;
	bh=FZsq+9H7Q5fAxhgkglEcuqefApTWQEiYLIyVHMQ1wT4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=JBEraXjoNnvTG05xrGx/xMTtyyibpiVkOH7xoRva+V1b+A+Nvsr+XAys/6xjU43nZT0ksHqwxrHgeoATSKXAhnwJOo8PnLVZQYcy1gtM4CZq3tO9zhnU+afvRSF6p5xabHHvOZLixbmJxAkOxFVIGoZR2uUqfwbCcFUGis5sQGQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=U+Qiu9VM; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="U+Qiu9VM"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 948171F00A3F;
	Sat, 15 Aug 2026 16:39:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786811942;
	bh=D7Ts7qKLlqwxo2FOw4zSh6HAyYJILBWUNEubXBlB0ec=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=U+Qiu9VM09UFdBUUSNRfWtY6WmwEhZ1PxbegzF8bBVaVSSFt7FyZz/kr8+HjeftaR
	 vbYWiYRkoCE/MsujX4TPRLLw8/tZB0nz07F+v4Aam8Fm/IVnc7uc9/Oi0scsDHGf1+
	 ssO9+RouUdWdB9jaK+V0WxuCSli6P/S2PjedShFEWwsl//ZyVt2puMnm7iRjhmqsua
	 Dt2aFxgQWoXSx4htvgPU7PWxTUmZ9eh/D8SrojPUo4L/kBAQxAbdArK/2/P75gnida
	 Yzn7qoGXIAIO5W/zqLRrolz3Kj8NYI/N0IKN+q7RmvlcvglYtYPdgRjsKTh2JSc/Zl
	 4GmSC6bZhmrIg==
From: Chuck Lever <cel@kernel.org>
Date: Sat, 15 Aug 2026 12:38:52 -0400
Subject: [PATCH v4 4/8] NFSD: Send a meaningful CB_RECALL_ANY keep count
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260815-recall-any-keep-count-v4-4-bfb5b83d6cb1@kernel.org>
References: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org>
In-Reply-To: <20260815-recall-any-keep-count-v4-0-bfb5b83d6cb1@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2890; i=cel@kernel.org;
 h=from:subject:message-id; bh=FZsq+9H7Q5fAxhgkglEcuqefApTWQEiYLIyVHMQ1wT4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqgJYhBrvvstLxq4GA1Q79bgOZ1waH+yhroc7FR
 4TocgLokNiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoCWIQAKCRAzarMzb2Z/
 l3CXD/40eC9hUPc/U2hH4nyNHEAhCiogOGzOjEPAQY7yv2zQJsy5faMM64BOow0vP45ZNgOpmqq
 jWNE2M1pj/TMMgzXvJRIWohP44Ya4qjxun3fuilfrXCx0s0JipqXYV0hdV860Xs5h6s3vZ8zJv+
 62hosQKkqHmXO49Qpb8wgwNXjUfJ6/e0ksC1dOt6MmUdxoS+lPZI0Ee0jOWDwTYwIOBsDFlYxEc
 j8ER3112zxMC9L3clZjWOKQDv9K07ceS6hWtMASTt7wNnw3EvWl0kv4oDdGa+ivASXL7UKla60b
 hC2JpwJla/9WEouUpmla0bEVAUqZzjDqVXfWizTH+W9wUFa7TZ87JCJ6oy7P/CPTr5dImmMgLI5
 A+iXHkbw4mwwCgO/HjZcgmcn4Zi1rUujxJ3d9e8GDQXYjGdpqQ430vFb3/SeXPQtY3ET5cWAbMI
 hwhAVLzTid7GuqViWt6t1gWH+so9Hr4Na12lXsypZHF+PYcRJmhdc9ESA5591ZsGyKDJwlM1otf
 hBtQGnblqqXQhIgjDIeZySWQETI5Qf/G6d1+4gxjh5KU3VQc2LeRru4XlAq0+hDx4IttQi35e//
 ucXRYiyBq+CM+LJW+FdmIni+rPXYlJUlmZm9gLzh95epIL/raqECGnMMToH9nGSFhrLwbZCywOQ
 YtEktxgS7EgiI3g==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

deleg_reaper() sets craa_objects_to_keep to zero on every
CB_RECALL_ANY. RFC 8881 Section 20.6.3 defines that field as the
number of objects the client may keep, leaving the client to choose
which of the excess to return, because the server cannot read lack
of recent use as lack of usefulness. Zero asks for every delegation
the client holds, including the ones backing files an application
still has open.

There is also no reason NFSD has to reclaim the entire delegation
working set on the first sign of memory pressure.

Derive the keep count from cl_deleg_count so that each callback
asks for one delegation. Both the shrinker and the laundromat re-arm
while their condition lasts, so a client with more to give is asked
again on the next pass.

The Linux client ignores craa_objects_to_keep and returns unused
delegations selected from the type mask alone, so the count changes
nothing for it.

Fixes: 44df6f439a17 ("NFSD: add delegation reaper to react to low memory condition")
Signed-off-by: Chuck Lever <cel@kernel.org>
Reviewed-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 19 ++++++++++++++++---
 1 file changed, 16 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2214b4d60c7e..5c2dd6657fac 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7942,6 +7942,7 @@ deleg_reaper(struct nfsd_net *nn)
 {
 	struct list_head *pos, *next;
 	struct nfs4_client *clp;
+	unsigned int count;
 
 	spin_lock(&nn->client_lock);
 	list_for_each_safe(pos, next, &nn->client_lru) {
@@ -7951,21 +7952,33 @@ deleg_reaper(struct nfsd_net *nn)
 			continue;
 		if (clp->cl_state != NFSD4_ACTIVE)
 			continue;
-		if (list_empty(&clp->cl_delegations))
-			continue;
 		if (atomic_read(&clp->cl_delegs_in_recall))
 			continue;
 		if (ktime_get_boottime_seconds() - clp->cl_ra_time < 5)
 			continue;
 		if (clp->cl_cb_state != NFSD4_CB_UP)
 			continue;
+		/*
+		 * This read races with hash_delegation_locked() and
+		 * unhash_delegation_locked() on other CPUs. A stale
+		 * count only skews the keep value; the next
+		 * laundromat pass sees a more current one.
+		 */
+		count = data_race(READ_ONCE(clp->cl_deleg_count));
+		if (!count)
+			continue;
 		if (test_and_set_bit(NFSD4_CALLBACK_RUNNING, &clp->cl_ra->ra_cb.cb_flags))
 			continue;
 
 		/* release in nfsd4_cb_recall_any_release */
 		kref_get(&clp->cl_nfsdfs.cl_ref);
 		clp->cl_ra_time = ktime_get_boottime_seconds();
-		clp->cl_ra->ra_keep = 0;
+		/*
+		 * Ask for a single delegation. Recalling one before it
+		 * is needed costs the client an OPEN when it next
+		 * touches the file.
+		 */
+		clp->cl_ra->ra_keep = count - 1;
 		clp->cl_ra->ra_bmval[0] = BIT(RCA4_TYPE_MASK_RDATA_DLG) |
 						BIT(RCA4_TYPE_MASK_WDATA_DLG) |
 						BIT(RCA4_TYPE_MASK_DIR_DLG);

-- 
2.54.0

