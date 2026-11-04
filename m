Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793801482;
	b=z4Y4YpniHvfV299XY3NJ8vSVByG3ofHofI2KYYFOj1RDAWBkrpvMnuqVEIWaDv6aaQ/z
	 w0GaZCrBeWoAc1SSTQ/H/wHDVNPr+/g9d72Rqtw70A7KwJCQMUBx8qe7Yn69rRu194ze7
	 ZmuLrMaRCwBQHMyhOWnEt1s6E65wmtHzsiuvPaOopoCovbC0bW4ERRI7rM16YPKFWzrfB
	 CO+vliq1lYPQSJ2UYd3fsQpYTr22UAZEFbC+NtfKRQQmuZz6lLrWy2UiWulMzDwD1XgMc
	 9Dnyp+fOJ1adTT9d9TbUlVXv/D34ND2gTaISmjXnUFv216inIN1hVBVlunacikti3WA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793801482;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=3fGh67PErge46ER3pud+qERHkhA18TH9j6ch4ZdnSt4=;
	b=TLehBVMGV2mg+bAAwBqn+FsrSpNyFSsjWh5i5QBMZc7jJqr2xl762z0UnphXU29ukyxs
	 meFxrdg2WwtRvJFbUaZ/CVhtzqqRSa+A6mEltOduCVTtoOxCYG3HzhRAeD+j37xe3cFC9
	 VKIfwSmnOyurqvTK+BFeHXTbr+5P+uHTSH20+cSv08PMTqGmMpdvavtsRLXR99e5bpmla
	 wpxoIFD/Lu5RY1DiKKfWR+1el830UuLGqGKRNowGoZxxW+EQZNHOxNCz/5m1y5IB9ZrzG
	 rgx3cMMrqFjeMs7E7Ws1atYKZfoXgRY81t6SSFYqIJXWjowlJkUA1tVGN/KUc3GCaBQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=njIhyBWA;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1E31F606EE85;
	Wed,  4 Nov 2026 14:11:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=njIhyBWA
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 35EAF1F00A1E;
	Wed,  4 Nov 2026 14:11:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793801482;
	bh=3fGh67PErge46ER3pud+qERHkhA18TH9j6ch4ZdnSt4=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=njIhyBWAT14etXFWjKXBOT21qryUfnNfSiX9pX4BPM0CPySHmxPMkOGsiNFIeLWJe
	 vsIGlHaaqhnBLbKSdxtLmAx0AS25sGgNDTwffxSgla+PH6qfvBnRl1IdvDpWviBJW0
	 UKIlbyrHJ/AHy1PAgGbSRABH/7azmZgv/YZlWQVfpgl8jiWLOnnDwUlzxIfjQS26jO
	 JO8AwngVg+45cHrEZNl5qZp/8n0rqk/ij3sxgJXOSOYMAnvp/Zlj2HUx41Y8aMQYg0
	 BGenaj1caInDuk1Yf9y3qHP9VHeeq2oFCbn+xsW8aXmIkTGVCZVhKCCRJQzyEddz81
	 DdLdigyUtyJoQ==
From: Chuck Lever <cel@kernel.org>
Date: Wed, 04 Nov 2026 09:11:06 -0500
Subject: [PATCH v8 06/14] NFSD: Prepare bucket pruning for additional
 eviction reasons
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
Message-Id: <20261104-duplicate-reply-cache-v8-6-eea5b90e4318@kernel.org>
References: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
In-Reply-To: <20261104-duplicate-reply-cache-v8-0-eea5b90e4318@kernel.org>
To: Jeff Layton <jlayton@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1455; i=cel@kernel.org;
 h=from:subject:message-id; bh=UFXVU3zy18XoNoHOmBblSyNW/iYRGlM3crhR8t8x4Q0=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq6z0ARR+rq56+2RekttHqR+AT/o5W9zoHv/GMt
 BBReyHFa4aJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCaus9AAAKCRAzarMzb2Z/
 lyKbD/4ro+YUAQZFRtwTyh1t9dSZgh81pHtybdlsyOFDqVbVsPmTLT0hml85BBK/WLD1RRw31rh
 VOSpBvxHV/hCMRkimiouc++5Q6V6T0j55h0Ds8RViMjIpHJmyVScqW44ePLQjGbYb6QV/XRx9zm
 aFo0+zciPzB+ofMXbb38pZMUbQ96pwn5oz8rlB3ltS1sumv9ZfkqGKWpl6sxWYcSvmKeij2kwzS
 B7ZpNGUDcUedJDToJWnISV6I2ngjoZacaBnJrPWibgWwO53uKkCf8r5rJUhxF/d1x+ZhGpSvZ1I
 hdoXQ2l3AhOedrM0jUN7jScTsYVH3JEjXp1UE3A2UNDE8dwlxqb+MzfHFrIgvDSQzrcpvoHTmkh
 l7lVIvBZX/dOGBZ+nvak9E6bUouepObDn4WAAlFcX517mcTd2HGwxSuT0dE5h0Y+cv9NHRXjsGA
 vcPx7sVa7XtkJnf09JX3oaczvGARJ2+4NmO30VTTR6qRqr6GYSd4p0hzhxA+w1zHN7mMkbesZzJ
 5r4Gl7CEt6E35cl3/yJTdme+d8J2ixEjJTexmDUyd10w5kJFlyv3u5EWbTcI+wwUuKoKZCUfzWs
 UuFlI34UOEBuoWzZD73OIfu0R37omuG0KSfkFDsKkQkkkZ83bDVxkV1yizBbnHzKUlKkQcBlJ+9
 2bfQjh7xgk6YLqA==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_prune_bucket_locked() combines its two eviction reasons,
memory pressure and RC_EXPIRE, in a single test and stops the walk
at the first entry the test does not evict. A reason that needs
its own handling, a tracepoint per reason or a test that must run
ahead of the stop, has nowhere to go.

Test each reason on its own and jump to a shared eviction label.
The walk still stops at the first entry no reason applies to.

Reviewed-by: NeilBrown <neil@brown.name>
Link: https://patch.msgid.link/20260921-duplicate-reply-cache-v6-5-db5e13fd9944@kernel.org
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfscache.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index 01ad6a9ebe1f..988b955590cc 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -274,10 +274,13 @@ nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
 
 	/* The bucket LRU is ordered oldest-first. */
 	list_for_each_entry_safe(rp, tmp, &b->lru_head, c_lru) {
-		if (atomic_read(&nn->num_drc_entries) <= nn->max_drc_entries &&
-		    time_before(expiry, rp->c_timestamp))
-			break;
+		if (atomic_read(&nn->num_drc_entries) > nn->max_drc_entries)
+			goto evict;
+		if (time_before_eq(rp->c_timestamp, expiry))
+			goto evict;
+		break;
 
+evict:
 		nfsd_cacherep_unlink_locked(nn, b, rp);
 		list_add(&rp->c_lru, dispose);
 

-- 
2.56.0

