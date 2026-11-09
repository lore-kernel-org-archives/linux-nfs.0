Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794254011;
	b=tFnRA/HStyyo/o7SABofnpztpzk0MvxSgZagTkgQc3I45JoNNSWvbeRpNBQv5Bb/9B9g
	 1GfMzmzfXCqjnfn2ZspHTZv1GQXdVUPZzEKfk/MT+Gsl17mbLmGzeYEvMksai3098s9q0
	 CYlfk2ZpFTpInTn1udslKqx5USIasyfj/RV+uWGh1Cv9tibdkWpbPVovQtS6OFmCM1Rs/
	 YL6WMBXJ6FONA4P3BoJrt8CSbx45rRyXw1YWf9DiLol167IEGMXgeU2i5VXlUVWS4P4Uu
	 Rs53HE5v8yODyk1MPtVf+YKkGgPdDWbcjZyY+cTwEJN2f8DRQUXbq0s+f8wd8gYJEqg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794254011;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=FsNY2SK3ODIJsftMeulpNs6x14Hha1KqnFoT7tg3dBI=;
	b=stRH+jjqitTJxMG6Qt9wgFU85BJwx1IhNdCiSBQHCwLCpr92d56JWayUL9s5j7yRwI27
	 XHDARwKQYngcwqGiJIA+uJqMgkjzW4BZPLCr6OCGlDhGirGhHMSBj1l4vNItWCECROF2s
	 lxTcRcsOq7dhDCgjO7sqZGN/0aPTfRN0Ce/V2k5T1WjsQCa3AYfPKfSXfI0u/32G0AHIM
	 3HDYdL9FLYs6Tp113znnvo2mTYpNF5oeBFIVR+5vHGZ97SWpDnGwMNiTXaFDN4rL14E6v
	 M7NlxIwnVevN4k2wiKgsApkPiY53uHGzdCq6A5L99REwLpenGqrlmX+cvMJz2wydetQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="ex/7dhj3";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2F89560A263E
	for <linux-nfs@vger.kernel.org>; Mon,  9 Nov 2026 19:53:31 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=ex/7dhj3
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7234A1F00902;
	Mon,  9 Nov 2026 19:53:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794254011;
	bh=FsNY2SK3ODIJsftMeulpNs6x14Hha1KqnFoT7tg3dBI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=ex/7dhj3QvTl61PI94TFEiIfr+hJlQXw9xTHBca3sz779f3LJgm/gV9I/3D0W8dBH
	 IsqvMNthSRviI9pMinusHnYYn1qb7b3VHYuMr77eNhQMRhgEwVKJUWLwmmlxtzUDkT
	 zMKzrZ9IHaRPz3AnBNlbsrrW5OsFfsN9Gf499Gjxtlq5whoWPQlu7HA2IfWmUkYNOz
	 Ccf3bm7wklKLqFceDUPTD2Vq7ajt+FAHl3T1LAhIvRYjYHcbFXw7JDMbUeAVGcOx7B
	 LeaBhj7TVg/qzpg34BgeVTwW4tYHVAALe5kZ7z5/WIkdumoFkVZ2ZXiBuFauYD3b8a
	 Eb3n1LK+C67LQ==
From: Chuck Lever <cel@kernel.org>
Date: Mon, 09 Nov 2026 14:53:17 -0500
Subject: [PATCH 01/13] NFSD: Drop the READ payload when the NFSv2 GETATTR
 fails
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
Message-Id: <20261109-xdr-page-base-v1-1-a4f4411d760d@kernel.org>
References: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
In-Reply-To: <20261109-xdr-page-base-v1-0-a4f4411d760d@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Mike Snitzer <snitzer@kernel.org>, linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev
X-Developer-Signature: v=1; a=openpgp-sha256; l=1542; i=cel@kernel.org;
 h=from:subject:message-id; bh=JCi/y8+FGBxzaj+mnHPXheW37sJw5SJ0RjDxG455YQU=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq8iS3IlU8CpWBq6114aBb5lMoqzuy1fhG/T/Yq
 WPHGxep8KeJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavIktwAKCRAzarMzb2Z/
 lzQfEACgUq2aiBSIjt/McKeTeQrSziaKf6Q26jTJJf/0evQh5rF6SD3d123exlEbelYnmrmn2k8
 aIjnO4PiGSPTgVGOD2ZbZq+zkhJ9uuGjuIaj2EB++7Tf8reSJHyn+5JA1d717ZfHxkaE7g/X6xk
 te+ES6JNQ4EdvWtS4xlawwVO1ni876AwVzKsXIi4Dl7JcHSKOCF8e+8RcoeWknpsbgK6GLbnLl9
 90Nj5uktYzTXT5ZdGRyeYpHH/R4JhooYhD66KjvQaLR5AStRPpyL7UgHkYoihwjh9ud9tn/MUGY
 gpNZevYZ8SCpAV4nCHE9Ae1MNH86bjsfza9jj3sZVlerHDJVdLqoYSbiPnGKaqs2wNF2DGShchx
 fOR++yeoG1922F3iEq6ykDGCjzqNTirzpvgzPMGeMhk8Mz7e0uf6NtoUHBCcn6ryt6k8QlgYon8
 uGAs673TWcicrqr5t61hvcBOKdYT9VUW/7aY/AdU5MSiBtfMrV1RSax5jnt3kcCUyWTB5FvT8e0
 E8ez0iAmrJI+LtJz7qGZZl3yoyt7gRQP0OWRf+VkG7MGwZDgpXydEUw/QCeqdQIc8583RSrknhf
 EV37aR8X7m4rzS9AjNLMeSNZJU0HDg+vaN/l4B81sdLpanMvZ+Il5/0WdaewcVjrX3dSCxoy1Rx
 QbKfTjP4AQWRAFg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd_proc_read() calls fh_getattr() after nfsd_read() has completed.
When the read was spliced, nfsd_splice_actor() has already set
rq_res.page_len to the byte count, but rq_res.len does not cover
those bytes until the encoder inserts them. If fh_getattr() fails,
the status flips and the encoder takes the error branch without
calling svcxdr_encode_opaque_payload(), so page_len stays set with
no payload accounted for.

TCP sends rq_res.len bytes, so the stray page_len has no effect
there. svc_rdma_xb_dma_map() walks page_len and maps those pages
into the Send, so an RDMA error reply carries the file data after
the status word.

Clear page_len when fh_getattr() fails. NFSv3 READ fills a
post_op_attr and cannot flip its status, and NFSv4 clears page_len
in nfsd4_encode_splice_read().

Fixes: 846f2fcd7785 ("[PATCH] knfsd: Provide missing NFSv2 part of patch for checking vfs_getattr.")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfsproc.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfsd/nfsproc.c b/fs/nfsd/nfsproc.c
index eb2a0605c1e1..9871b52dec04 100644
--- a/fs/nfsd/nfsproc.c
+++ b/fs/nfsd/nfsproc.c
@@ -601,6 +601,9 @@ static __be32 nfsd_proc_read(struct svc_rqst *rqstp)
 		if (resp->status == nfs_ok)
 			nfsd_stat_to_fattr(rqstp, &resok->attributes, &stat,
 					   fhp);
+		else
+			/* A spliced payload is already in rq_res */
+			rqstp->rq_res.page_len = 0;
 	}
 	if (resp->status == nfserr_jukebox)
 		set_bit(RQ_DROPME, &rqstp->rq_flags);

-- 
2.56.0

