Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EB7E12DECCC
	for <linux-nfs@vger.kernel.org>; Tue, 18 Aug 2026 01:08:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787015331; cv=none; b=AtokaU8u7rGjitmj1MpD8+GtVOvdJjixVKd9TXocnFNmkr0J6LqvY69FDSPcpNi313rRxl//rtF1C1G3lDaQhOrv4F7iYq8xTd7ntdmdTbbxuYWwLIK8hciyjZzHcTnsLD5IUlxTbjoojLOCtMs9h07i5J65simWPSvEBe9J6xk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787015331; c=relaxed/simple;
	bh=FZsq+9H7Q5fAxhgkglEcuqefApTWQEiYLIyVHMQ1wT4=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=tNi8Zgx/1e3+NVP/GZldUVaWY9R/ltJxRbvQf90SRf/9vN/4kN/l7lQK3ha7WFWYzo0RrnrhwjLBgWVZKaaPsLT3YKRJ5tb+83KdZ/O9b7StkIlL5EgenUaRX8PnhKBw+6H+KoODfMya08CLNcRbferJbpP4QYzUbkZ5XeXBCb4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=W2kieBQl; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="W2kieBQl"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 52C431F000E9;
	Tue, 18 Aug 2026 01:08:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787015329;
	bh=D7Ts7qKLlqwxo2FOw4zSh6HAyYJILBWUNEubXBlB0ec=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=W2kieBQlGTuLdw9BERyuoBVzHnOvUY1bPWa3wTcyCpJLwlWtqTUPfv1ovHXEgwW6Y
	 HMvZdUY7dyYwbJNgTKFJUcToSypkMAqfAeWpGxEZxIWBGv9uR3WaoC1pkrYMNaXBYY
	 7ExAhPaP+rtncrO0EdBICJ78J8ei+UyQ4bhCX3yx21mDAkwp0FUn7NC/vgubKMruBs
	 mCsEc5AJmAqMlob3xWRLqcWYXbWPo6qNeLjcJFeVWTvw8zVUrY/Lknmu8ghW/jwCVf
	 EQ5gDtJNkYqDK+NnbjWB1n/v2Nx07cBoS/dSiq58Uzmbz6b4LlmoGmIJ20yxDYQoXu
	 ga4EwhyPnnd8Q==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 17 Aug 2026 21:08:39 -0400
Subject: [PATCH v5 4/8] NFSD: Send a meaningful CB_RECALL_ANY keep count
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260817-recall-any-keep-count-v5-4-3b2cffce701e@kernel.org>
References: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
In-Reply-To: <20260817-recall-any-keep-count-v5-0-3b2cffce701e@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2890; i=cel@kernel.org;
 h=from:subject:message-id; bh=FZsq+9H7Q5fAxhgkglEcuqefApTWQEiYLIyVHMQ1wT4=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqg7Cd3ydN+WiK09J3tcdCP3wDXhTkQweH59UdS
 VWA6/WT0zqJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaoOwnQAKCRAzarMzb2Z/
 lyyQD/9IUgjf4quXYUkCqkoS4YmBfbGfb+COJ/5f82Xc3PzxFUMBydl07tyZZ8sARy4D8WvEvcG
 4GKrdlaub27PQM6LGhBqTovUeH7hobR9vhiQL2U8fn9qQwvRVIcoMBE9ZFV8RykcTVKIEBDn7VD
 Wu+Vkyja9sf8R03vg+fDXsju/A1Ec0mpq08YF0WK46OyHAQdmMU5CnEM7TkleoUiudM9TmIoK3a
 Uf3i56R2Xea1ILrtQUc8TwLKwUTZneubOgI+adZRnDFazsR1PKE244JsyKv+V2iqUBZC1NISrGI
 9zh8eIyQBR+h/TamawwQwvoWc0tFlOmdf6ohm4eTUvhsaq1ouG5+h3jHMt5+UzaeQ7zlkCfJXsl
 fHPACY/IkCCKJHOkq9Ykc1XonU5m0+JatfgnZMMQVxcqt9RhHP1usTEybPGnzuo03zFk2NGrwyn
 rIkj+7v/AF4C37eLIH3neE7pRo4lG7SeU7hImVa501Na8khO+MtRrc1THEYhTrZg6FAOMHq6aZI
 h0wqPyCTgAwcNX2q8XJvKLuE8TeF+XKplacbD58I+HDhSZ6Sb2PGE7ZTXxds7Pt//7Uy0cPTNcO
 vuyXyMaQ09g2n0Ywm/32/D33jFfqQJe6hqzO7bAyDKJ9eKvbZwa6tGTGEI9ke3G9XF4q7GlQsA+
 6CZ5LEIBdfUUdww==
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

