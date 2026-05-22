Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD5001E7660;
	Fri, 22 May 2026 14:36:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1779460584; cv=none; b=rMNe0HYYQ+tFXfdYn5NRrlx+MPdtmX+LkAn68NrVzE3FGx0JUeSXGe2x572BKr5OGPhTFSYWoXfHmqmlMYGKGxGg0Zbe5UFdSXc9cfq1Owoz6qj080p+uvFQ66+avM0MRsbiVZJYydr+XMhWngirhOoWoWIYjyB/xnj8h9IQHCY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1779460584; c=relaxed/simple;
	bh=g1G87csibOq77QWng42gvAAEG2piFsFsVpPpKjBmZkY=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:To:Cc; b=MKwE/cy0t01m6+nsWxJgli7rCk0KtU2MZ5qzVDajbjbJcFjfjKxrM//6chlQ2Xqumq0QZtv4vkHZsz7IOOwEqIkFZtrPsPIGGVH7n93bdF2NhqcaCfZ4hVY/OuqYkIGldgTUg3Lys5XQQVxUavlPwS/zSMlfKV34iYErpOjRYCo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QzO7d6Sj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QzO7d6Sj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C7C711F000E9;
	Fri, 22 May 2026 14:36:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1779460583;
	bh=va3SMbT7g0yBng6cNfy8yh2k1pddQd7COFqKpgaOkc0=;
	h=From:Date:Subject:To:Cc;
	b=QzO7d6Sj2fx3rnatqv+c06kUE6ci25Ukt1CBSAto6SFIXb/o2lUB5QfXtQUbvLzMT
	 avgzxd5WtI4eF2rq+LTw+dCzjuTeyqcJTFVdov4rSCGMv5c2VIk3LnMVja0YR0dbaq
	 2HpJ0pH88DwAGzG6k8TDmdZ8VNP9HR7BQXzBGc3FaPGxxaH9NZxOQ6e/zDGCSKziB1
	 lFEW2bFMcrhnVVoRyVx5WU3zj74SVX7S78YQsWxqQifNAjzBRx5p64i797ZMgwDf4Y
	 Xauw0QQnqL4Dc9R7c/XHjHcvlgQ6MJpwkAQiZ0Ff3on+JCC8CqCQA4nPEjXCZWnduX
	 phpTPeboxsm1Q==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 22 May 2026 10:36:14 -0400
Subject: [PATCH] nfsd: avoid leaking pre-allocated openowner on unconfirmed
 retry race
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260522-find_or_alloc_open_stateowner_unconfirmed_refcount_leak-v1-1-a66645e1e006@kernel.org>
X-B4-Tracking: v=1; b=H4sIAAAAAAAC/x2NUQrCMBAFr1LybaFJsVKvIrKE9FUX425J0iqU3
 t3g5zAws5uMxMjm2uwmYePMKhXsqTHh6eWBlqfKxnVu6M7OtTPLRJrIx6iBdIFQLr5AP4JEqwS
 VmdMbEyXMQVcpFOFf7The+n6A9bAwtb5Uzd//+XY/jh+ZtHl+iQAAAA==
X-Change-ID: 20260522-find_or_alloc_open_stateowner_unconfirmed_refcount_leak-997336e1ae1e
To: Chuck Lever <chuck.lever@oracle.com>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Chris Mason <clm@meta.com>, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=1740; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=g1G87csibOq77QWng42gvAAEG2piFsFsVpPpKjBmZkY=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqEGnhS6OnhPERuomFQ1Axhdk5o6M+FlcK8Kka3
 fZWGvoNOPGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCahBp4QAKCRAADmhBGVaC
 FfLmD/9AXEOSj/ZAMnPWaGQwpiPTiv4z7TdRV+ePvkKZ65+lbVc7BpdS4dlUQtOHFa9wlMw2A8o
 J/eAqZZdFcx+JRvXF0TvG8ZHxs8NE2NhJyhXXfqnrVEsHEe3uVh38P6EtBzJ6pbJ559IYeUP4iF
 wYJJhnmmLes09K8teTKZwu4caccRxJN1cjRAKkSim4u1huDNLFk6Z5epvEQZHOE2+6sKpPgno3P
 4c/WlQVy4Dw7g/zkwS3JVtEhmB7sXI0yWxoVKrD/iOr3avBBfZj6Sx2iJCZEQKTKsKYVkKisgWO
 NwSXs6+dKTphXJVNqoZ4i1g9abf7Y0Yq/ZJ6oJpZp5QBxclWSR0h0piGyNxLqX/tMgjTTpwXRXS
 idJt49vFKk9DQkFniFyoFtuoJj12+QJfUh/3//akKGv86djnjW2V5EY83VzgqDp8CndqbzsVZ9/
 DZg2S4MTa+FIGjPb4rcGIzoqxkHoOUCQigGnaIuu6QGJVqO1EkUIAiY5mMBUfJ1AHYNXDN+j3i9
 2iMuemnOaHI7Eoi+0P3f1wtBdxBlMM7rJ5Eqd7zgJ1SUCpd1MTtm808VOsBI8Vj55VActjViX8R
 K4VGLFpjJ07ZK1EwIFX4oB5LL0G0R5ie33iz6TRZkmedkCnFLFZCmGgnznRkX8TVT20wDw8Tlt5
 r7X6ZbxUgrTRb6Q==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

When find_or_alloc_open_stateowner() encounters an unconfirmed owner, it
calls release_openowner() and sets oo = NULL. Control then falls through
past the `if (oo)` guard — which would have freed any pre-allocated
`new` — and unconditionally executes `new = alloc_stateowner(...)`. If
`new` was already allocated on a prior iteration, the pointer is
silently overwritten and the previous allocation (slab object + owner
name buffer) is leaked.

This requires a race: two NFSv4.0 OPEN threads with the same owner
string, where a concurrent thread inserts a new unconfirmed owner into
the hash between retry iterations. The window is narrow but repeatable
under adversarial conditions.

Fix by adding `goto retry` after `oo = NULL` so the already-allocated
`new` is reused on the next iteration rather than overwritten.

Fixes: 23df17788c62 ("nfsd: perform all find_openstateowner_str calls in the one place.")
Reported-by: Chris Mason <clm@meta.com>
Assisted-by: kres:claude-opus-4-6
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2cf021b202a6..a42f34842d77 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5276,6 +5276,7 @@ find_or_alloc_open_stateowner(unsigned int strhashval, struct nfsd4_open *open,
 		/* Replace unconfirmed owners without checking for replay. */
 		release_openowner(oo);
 		oo = NULL;
+		goto retry;
 	}
 	if (oo) {
 		if (new)

---
base-commit: 33e9ab952a864ae00bce7e47c3e9add1c4b3d3a3
change-id: 20260522-find_or_alloc_open_stateowner_unconfirmed_refcount_leak-997336e1ae1e

Best regards,
-- 
Jeff Layton <jlayton@kernel.org>

