Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7DC9C48095E
	for <linux-nfs@vger.kernel.org>; Thu, 13 Aug 2026 18:40:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786646454; cv=none; b=nBIeGQjZLVCLl4KYr51NHCnKgVoVGyJDaAe7JQrnakwoqq9mDJzv6osPv961Wui8DEAE3NgCbCzytPDX43b1Vf2VFGJluR7raNXPAB22O5v77U76tRm/EnxJqX9uxEiA43CeLVRpVTXfApnXS6d37/EfSPNplNpa4rvhIWJxr5U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786646454; c=relaxed/simple;
	bh=nxSWHTIbIb4qXGFSmgpBkw64fCqY20eL8YMPRxE9NVk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=M1oKbMv3TnPlzPPJGr11BVPwPIco7EnmW5GZN6C8nKcNdIIFE6FT4+B7alMoi8CeyS0O0F6P5kenqsoNwcO0WH9B3GK463labE33XIAURYZhDYfHfCkvgWNrLkqkEIG/PSImouKPm/Fyaepw/7vcKmE/PRBNkGuZEwtGtVXYrAc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=RprM2nHt; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="RprM2nHt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 978C21F00A3A;
	Thu, 13 Aug 2026 18:40:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786646453;
	bh=dWyw50cJ90OmZXvRUQV0gFmM4bVAqP+kAfMj1d+mSxM=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=RprM2nHt2KubZfgPAHIG+CJiSrbwVvSz8Sxl4Kj55X4Uu7HU0q5HpycfmobvJhrQx
	 vW0Jp4CsQJ42f7zSY5ova03EJMTiXj/fcYNaaHYHwJ0G29RdDLfRlsKZBwQCZkbuJO
	 wrAD3a3lZ0cFmRjdOm4r6q585KtZBrh85ZkX7aD3kloWRtANJmbJ+0ibFjOlEkQgE3
	 kln22jjf2PfJO4ZGtmA7ykH7wvPFOmIcETDsfQKHeMiOF0CpPw812f67dOmrEhjztL
	 /1mcsLfLufK6ZYrVRgRgau4gYxsRN9wQK9Z+05hh2t1l48ZqgStT5O6Kd/TR3e2sYk
	 jjnNFvBxz9FOw==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 13 Aug 2026 14:40:33 -0400
Subject: [PATCH v3 4/8] NFSD: Send a meaningful CB_RECALL_ANY keep count
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260813-recall-any-keep-count-v3-4-a96d243c0b13@kernel.org>
References: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
In-Reply-To: <20260813-recall-any-keep-count-v3-0-a96d243c0b13@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.16-dev-da966
X-Developer-Signature: v=1; a=openpgp-sha256; l=2890; i=cel@kernel.org;
 h=from:subject:message-id; bh=nxSWHTIbIb4qXGFSmgpBkw64fCqY20eL8YMPRxE9NVk=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBqfg+w9XnQjB+8lTC99SomZJCtPpO+KmwDV8mRU
 PdTV4F/HY2JAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCan4PsAAKCRAzarMzb2Z/
 l4qID/9UVcFCdxLOxwvsYsTuAO1xyT3WxdMb53dTWBytcJYE28HBGSqK+KkcDsqX9mex+rGHqmS
 to5CHJIZQK/Q+kaq6d6CVotpijxJNs9WmHHSzB94jqv95hiePFp7cUQTCMlc6ZIEWV1G51LUp22
 lf7snRshGzF5YDdY8GOELkYL/WyRDIYMvzDhJ/lwttoKxJOAD8GNnX29l/QoTOy+0q/hyXq/OFK
 JWDWH8pXY7v4Lzz5TPEcvkk95QcEv3CEzOzKSpRJicxAXPTQo9Q/9So5cXq7jiJYgqiuH4J7GrW
 x8HN7/D7mI2Q0Q+2NrU3a/tr/HtZKyOunu849fHTSBMkkQ3GeaDoAkHp9zx96p8xRcLd+eqdP5i
 zbm0ozbe27d2QweknrvZMUyUqoAojUBO9p2SkebGGDyxaWF+iXphWyuYcNJfrB0xwV6eRA+tkQN
 6sU4GteQM1ux6xikQOFWjRFIEuJfXd6+nLCS/cAj6ZTkbt8+U6sqbwkuan1QsbnTdQWMu7P3CDW
 kUHLlUWyGeTuW2+6hZG7U4f7DMJ/0n5EOg26NTWlowUyhiCmn1wivSCRyYj1UQ2IGLkD8OWCF5Y
 AcRAJIaRKZxKo8dKA+YopKoO2JuOOqERIOVrbQTofCuStuOmK5PFkMdswjRaZ1Tyvt7XI92DwbH
 gpKqEZxU9kMNQlA==
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
index 3017a93261ff..7d8d7df9953b 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7944,6 +7944,7 @@ deleg_reaper(struct nfsd_net *nn)
 {
 	struct list_head *pos, *next;
 	struct nfs4_client *clp;
+	unsigned int count;
 
 	spin_lock(&nn->client_lock);
 	list_for_each_safe(pos, next, &nn->client_lru) {
@@ -7953,21 +7954,33 @@ deleg_reaper(struct nfsd_net *nn)
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

