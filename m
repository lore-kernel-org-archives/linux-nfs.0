Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793997655;
	b=I1kiOERIqj8OHk66UvcgGcsqy+K1+tOSk+nFO7QE30d2yTwavJZ+Py/ymK7PRf2tcC3U
	 ndCXsK9bSouBJHL3bKo5y7kTrR90+AfZQH3GRyk1wY+gNGw+9XtvNusjvH5bfXg5ZuLx6
	 DaVVr7jcR8Q5K/xn0kGXgQFFZr/A4hKK54YidjMPHsDoQS0GfkgUChZY6xFvusr7cf2X+
	 a8OU+0ml6UVu3fzI/5NqzGwHSxIF7VWslEf7eb49dAGhrufeXYO8FHy89fBPIL5H8M95q
	 aJW5bWbBOxDMynyPsXjx2wvvZHPJz1KwN0gbgqawPiLAX3996ped/GjWPFK23Whwr+Q==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793997655;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=K14UjXEQmeSTiLk2QyqeVUH8AJQO2qKcVtrJkED7TDo=;
	b=wDHTvbwOcU58KrpXUpAoW3MSK8xw4G3BnK0coHOc+4TvL3Vu+j/3wVRRak3kac1lhXya
	 4CpIAeR677qux412QgL2ZNfxlpqHGGMgUkdyBWxhoZF8mP+CT8H6QJnsheqtOwct2wThq
	 3fzaHF1lpjQks2SMe+CbMjXxwBttWPx+JJeRIWJN92APC0PyzGla07pRI9lxiBZ7TzYc1
	 w3tj7VHFAFnnCtuW4sVqMnmoS4QiVXzqFK7b7TSZdaHARzfY1pK9UH6Y4fd4ScKoSJAGW
	 jPh6hcyEDT6WHjGxc5/gJrVopl8/BOrdFBACzDojPa7bb14lOP7J9rsfYbhORWjQFYg==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BSOkc2Xx;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0169D606A33C;
	Fri,  6 Nov 2026 20:40:54 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BSOkc2Xx
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 01B211F008A7;
	Fri,  6 Nov 2026 20:40:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793997654;
	bh=K14UjXEQmeSTiLk2QyqeVUH8AJQO2qKcVtrJkED7TDo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=BSOkc2XxfN16vl3fp5wCarZig/ew/y+hmonlDP9+xi8GHuoVgWUwZsGwTGrfLXOq3
	 BdSr+6muATNDw/kIMsjp08gTuj0Bo6JyYEeeqZ7B4AiXbkCw8taKxQAnouhMVxcnbt
	 SdbIM69wyvQcFsoPO1d1/ero47KmEJCjFa01uY8osF0FKacuMbvLqjb6CQeuWdk/vE
	 7qQhvwWd+c/kfLvzn5jC1yiZKSaeiww6H2QxpKCLSSA1KTDgzUEbn0HukcVF7LQsmz
	 k7VQl/aVW9Ptan8JLjpiR2WjA7gMjTo1TTyusFi4R8TE2wNB1Wz0mD/l+hI8/zpQYy
	 st0sgvQnCB8iQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 06 Nov 2026 15:40:30 -0500
Subject: [PATCH v2 4/5] nfsd: don't vet delegated times against an
 exclusive-create verifier
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
Message-Id: <20261106-deleg-cb-getattr-times-v2-4-8433618ab9a1@kernel.org>
References: <20261106-deleg-cb-getattr-times-v2-0-8433618ab9a1@kernel.org>
In-Reply-To: <20261106-deleg-cb-getattr-times-v2-0-8433618ab9a1@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: Tom Haynes <loghyr@gmail.com>, linux-nfs@vger.kernel.org, 
 linux-kernel@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2906; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=rallKbkOrPTHB7og7rmcR3hD7hb8l3Rr4MKaHFfPrW8=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq7jtRivcvrHzlA51CxzH0iAqLF2c8NfElPCa3k
 0Uagbj9A9OJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCau47UQAKCRAADmhBGVaC
 FdGPD/9IPuJv+iRtKegOAGNiYpEOaJGXRbf5ikU1Fp1zcjBnLKc9/brn4J3MECVAOvjq5/jCbnG
 VIylweqt6clpSuyDRg8UV7gHOuH4NF97jsPQIPm27IWHceh2SptdvkPSEj49rUYYmASTJCt+1hJ
 fyq+XHaQyQKgYhyIwSx7EnHJILNs/WAUGmCV0PdbGkU75Kz3OwwC4iox6rN7mH0vlMF6UJJXgr3
 aqQuCbJL6bQa976rL3W7UL9ItjnASMT7WRyN69z09jYHS5hOAl2LXZ5CIys10glhsfes0JugLfT
 KjAli5aHCL+fLtW81d6Y4uTQyRSmVrJ5HKLaOw7weWCHDQXxlpa6OfzCd7ywO7irHIhRHs9V8zL
 Bl5VoNrif2AHGYRb3tgIjx3B9xyqHxPWHCbIN7su1hUXLXM2/+NlZlwU+PYOkDdk1IMjUOHgOzd
 nGZ+oTcALpBwFZPEcsK4ZID1tRJ6I+V1Pax4euCCEEwtiQR3/4pW/SGLZNtDPQm/RajcatfIGKF
 8KZ2Ps+CerTFK4q98jE+qISTFy2BKwo7Tin3QXYQB7yO6ZkjJnVyTHtP/RajsZLhKT3FwLrnOSX
 p6RswEPyzQl138l1CRVhiu0HqI4yWLmlMOzKMx3MHQBXaMIDPpOGo4EbfNmjFgWwjyK8curS06g
 QCZjo/h+O4lj8mQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

An exclusive create stores the client's verifier in atime and mtime
until the client sets real times. A write delegation granted on that
OPEN records those as dl_atime and dl_mtime (e.g. 4777.0 and
681509.0), so vetting the holder's times against them always passes,
including times older than the file itself.

When the OPEN did an exclusive create, use the ctime at grant, less 1ns,
as the floor for atime and mtime too. Vetting rejects a time equal to
its floor, and a holder time equal to the ctime must still replace the
verifier. Move nfsd4_create_is_exclusive() to xdr4.h so nfs4state.c can
use it.

Fixes: 7663e963a511 ("nfsd: track original timestamps in nfs4_delegation")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4proc.c  |  6 ------
 fs/nfsd/nfs4state.c | 14 ++++++++++++++
 fs/nfsd/xdr4.h      |  6 ++++++
 3 files changed, 20 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 4e5d5852bf57..25613c1ffaaf 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -245,12 +245,6 @@ static void nfsd4_set_open_owner_reply_cache(struct nfsd4_compound_state *cstate
 			&resfh->fh_handle);
 }
 
-static inline bool nfsd4_create_is_exclusive(int createmode)
-{
-	return createmode == NFS4_CREATE_EXCLUSIVE ||
-		createmode == NFS4_CREATE_EXCLUSIVE4_1;
-}
-
 static struct file *do_lookup_open(struct path *parent,
 				   struct qstr *name,
 				   unsigned int oflags,
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index f276c16b3ea4..360b8886dbc0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7543,6 +7543,20 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct nfsd4_open *open,
 		dp->dl_atime = stat.atime;
 		dp->dl_ctime = stat.ctime;
 		dp->dl_mtime = stat.mtime;
+		/*
+		 * An exclusive create stores the verifier in atime and mtime,
+		 * so the only real floor for the holder's times is the ctime.
+		 * Vetting rejects a time equal to its floor, but one equal to
+		 * the ctime must still replace the verifier.
+		 */
+		if (open->op_created &&
+		    nfsd4_create_is_exclusive(open->op_createmode)) {
+			struct timespec64 floor;
+
+			floor = timespec64_sub(stat.ctime, ns_to_timespec64(1));
+			dp->dl_atime = floor;
+			dp->dl_mtime = floor;
+		}
 		spin_lock(&f->f_lock);
 		if (deleg_ts)
 			f->f_mode |= FMODE_NOCMTIME;
diff --git a/fs/nfsd/xdr4.h b/fs/nfsd/xdr4.h
index ecab2249e9bd..feda5464f260 100644
--- a/fs/nfsd/xdr4.h
+++ b/fs/nfsd/xdr4.h
@@ -280,6 +280,12 @@ struct nfsd4_open {
 	struct svc_rqst *op_rqstp;
 };
 
+static inline bool nfsd4_create_is_exclusive(int createmode)
+{
+	return createmode == NFS4_CREATE_EXCLUSIVE ||
+		createmode == NFS4_CREATE_EXCLUSIVE4_1;
+}
+
 struct nfsd4_open_confirm {
 	stateid_t	oc_req_stateid		/* request */;
 	u32		oc_seqid    		/* request */;

-- 
2.56.0

