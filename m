Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B43FC473C8C
	for <linux-nfs@vger.kernel.org>; Wed, 12 Aug 2026 15:00:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786546830; cv=none; b=rYKT8nAc2cVWkq4sqfRqtcpH2YgiVbUGKZkMCQ9VwPQvuPrlAq/BJEsKAx28T4YibJwcGSjhaZyK4kCggjofDbs2wH/WrH6ZHeJJer8ONMcRXvVZfAa2Khc56WCsK+P+uxnhcx1DjlsnkYdJKaFZw1IOOFJuItK7I08pM4vdlgQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786546830; c=relaxed/simple;
	bh=E7o11+OBgJEhb3VdL2UDBs5YekVOvKNcrDXxHCXuRrs=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=NfJbzzmq675ynOUt8TAo6AsauFz77fyVHthcTR+rOqEOl4PV0Iyb8eIHDWbd1QeNZYiauWWJ3Z42WG2yG1RqhA9xUIDWgjNDrG9wjyUgoBJJN51N2e4GnfkRROBfn1s3bXBjZMK/8myJ6uTH/XV8lSh1rBonY+CmnhH2T10HNGM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gqEoLDN6; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gqEoLDN6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0790A1F00AC4;
	Wed, 12 Aug 2026 15:00:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786546815;
	bh=tdxB8vBDra85oOq1QPUfnHxAtpZxUMaT78Mh5WQQw8o=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=gqEoLDN6fDV5lLdT6F9APW43Paa5kYVu2hlnt0mMvEg8k40iDWlV2kCNNWT8ASBz2
	 ThCIZk14slrmpBWllqML5cfNEd2W2g2pMePp9bX4aUYihAIxLBZotvFqZFtfo9647x
	 EJqxDI7o9PVM0eIMpGMb7zlBzGvThALbsGQpIOvOzB6gDfhP7bWoTRgJpEhqubWzuc
	 YTvk2gKxmgvCjtqr7lvvdsAIgb/ChtGjrhMB3+7003IGS1T+FpDfiesb9Z342mhRiT
	 C0a3BNnSsL6Rz+TIwzKMCy8VCzn5EoXV/qjV4iRlVPcp7kNbyYB2bNkGWSLSumazck
	 WkfCrasu4oycA==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 12 Aug 2026 10:59:58 -0400
Subject: [PATCH v2 4/4] NFSD: Send a meaningful CB_RECALL_ANY keep count
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260812-recall-any-keep-count-v2-4-a82f4ca23812@kernel.org>
References: <20260812-recall-any-keep-count-v2-0-a82f4ca23812@kernel.org>
In-Reply-To: <20260812-recall-any-keep-count-v2-0-a82f4ca23812@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=3070; i=cel@kernel.org;
 h=from:subject:message-id; bh=E7o11+OBgJEhb3VdL2UDBs5YekVOvKNcrDXxHCXuRrs=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqfIp7uwag+zBVT8qzb2+HyX1tD1V3BhElLS07r
 YAgvaapNh2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCanyKewAKCRAzarMzb2Z/
 lyEpEACac3pVnQTkCH5Td8wWbWsnA2qr86yogVKRsLdJ2n3hD/Hsfun0hwAjyzDMv850jRB3niO
 PPs04ZDm4sRnPmTvozwdOWW01cA9hAsLMDjbvrTe6eKRAA7w+XzxmHu/6KxJJ63SeiN5YjvA52S
 u3P3ZFOSSAmaYpDCSV5dEgOfcZraBrXmjzCEYhTHdkRCf7lK9kLdsRwFtclsRJOAl6pvQb8JiS/
 fxGLTivSd5u9RE0G9H5Aenwb5X/92yBxni+9+85c50bv3WVTX4gic0wWB8mQKQtXmlG4FjUDhLi
 K913AJjdPO2M4DfTfrRb4ySJcFZDHMaNKpNVX5rBedzmvVIc0eDNlEntUa1CkP9acDk5NUQjNrS
 B8SN80s3ZJj7CKR2SocF1OAkZePwamCUGTpDKZLQ5ZqSxFo6uAm3HenZWc7Qost6qFNo4KT5R/y
 C56SyjfHfGdMv0sxmJrGuj0Dby+Snq/8CAFFkUuNQWsmhRwLFOZXwYzdCF1+0eu0JhxIaneQMOO
 q3ntFT5oy8qO+Cke44PPeaJUVgNddiRppJljAV3YORyK5b4LedSJkYoaycvRLJfRal1E8CZvqEu
 1TFfy2auYdXRrImQXM3naNWG1CVLypWZdXdBTHW0xwSBfx049yxguSLOOZ1eLuz5GmlFp9VFEgf
 hHl6LepPmk0B1gw==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

deleg_reaper() sets craa_objects_to_keep to zero on every
CB_RECALL_ANY. RFC 8881 Section 20.6.3 defines that field as the
number of objects the client may keep, leaving the client to choose
which of the excess to return, because the server cannot read lack
of recent use as lack of usefulness. Zero asks for every delegation
the client holds, including the ones backing files an application
still has open.

A client that returns those must keep an OPEN stateid anyway, so
NFSD trades a delegation for an open stateid and recovers nothing.
Plus there's no reason NFSD has to reclaim the entire delegation
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
---
 fs/nfsd/nfs4state.c | 20 +++++++++++++++++---
 1 file changed, 17 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3017a93261ff..c8be38bc3c76 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7944,6 +7944,7 @@ deleg_reaper(struct nfsd_net *nn)
 {
 	struct list_head *pos, *next;
 	struct nfs4_client *clp;
+	unsigned int count;
 
 	spin_lock(&nn->client_lock);
 	list_for_each_safe(pos, next, &nn->client_lru) {
@@ -7953,21 +7954,34 @@ deleg_reaper(struct nfsd_net *nn)
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
+		 * Ask for one delegation at a time. A larger request
+		 * reaches delegations backing files that applications
+		 * still have open. Returning one of those trades a DELEG
+		 * stateid for an OPEN stateid and frees nothing.
+		 */
+		clp->cl_ra->ra_keep = count - 1;
 		clp->cl_ra->ra_bmval[0] = BIT(RCA4_TYPE_MASK_RDATA_DLG) |
 						BIT(RCA4_TYPE_MASK_WDATA_DLG) |
 						BIT(RCA4_TYPE_MASK_DIR_DLG);

-- 
2.54.0

