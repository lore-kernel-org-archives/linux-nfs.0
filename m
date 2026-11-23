Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795438773;
	b=ka1pZOmvJ2778wO9yBIxGxi9vSBKeneqzlDo33YZl4JhzAtcesiVvOP66xwLYnzgJBC0
	 9UD5A6Iiqhfq2oJme2RGlhylHMiQwnU5Rk9JDWOHffG/LF/vRXMSEm84JxtJutKjyNWa1
	 ZAHey8NCwh1oK3AtEIWBADrqLnPlRWRCq1vUdSEam56+O9Q5D/OEgRiTXs1cMfrzwkquV
	 8OuzD4+0RSz2DtQm64g6dMEhpmu8hZQ2sLePU95o7vSqoJMxY9n29RvEZ+9XeMfX3JqUN
	 /snGtJw/3F2HVmgFE19zjZOd3Rmb5InV7HLngdYNWCEl2zOS0s7K8S7+FEfy+/EeSHQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795438773;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=FK6ByRtHtF2usZ+DFHgMwQJo5GajmTJ0FUrz0TaRmkc=;
	b=Q5u7G8CtojjRmPCg525Zsyuxhah6AW+gWxfC/i0TnNLp73+3pqQhnNdRcZLpwKeSY3gt
	 924rpPGdJCjBBUJKrsiD3zbvUYmOUlzUx1LpME+5vkjRolGY6QQqfE7Hi2GKJGB2y7b5R
	 KIJIZPP5luhENDA5E5UYQzCOvAhvj5xxlFkNrmLK6GkyhZOgLIPs1zpG81y0BgWVfmGxK
	 WvQrnMcWWzEubsPrMcy4WeNVoIvZKxtpFGboHg1oKo0nr67SD+cNvfFUgGlMd1SlN7f6l
	 /IYDp72VjaIgqyq7k0lsKtQTJla3x9GHfCb1HfKypFjVEYL3SnIwvCen+tI8d1jAzbQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iXN5b19B;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3356560A2607;
	Mon, 23 Nov 2026 12:59:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=iXN5b19B
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 108141F000D3;
	Mon, 23 Nov 2026 12:59:32 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795438772;
	bh=FK6ByRtHtF2usZ+DFHgMwQJo5GajmTJ0FUrz0TaRmkc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=iXN5b19B2F55EaPwSm7Q+Iv215Zo6GQvtB8DIQNsiTkwbTm/v/mfgoB7J4EcF+tsS
	 m8axj/FAX/dFHFVxC7gsTZA8eXKROZJwYSGMOuvvlFBM7KvZv0/xf6Is8qPXbqjsrh
	 ASctSx2hle739p/ov5nHVDaQF4AYzocuaLiGco3nusD3bCdA88RkRImUyAtPohKiDn
	 1WunkMCTA/B2BWwqKq6/0a5M3Il7MpUKPnTaHaGjjCcW2wtjbib7jWQoS7LFifTHl8
	 TPMarM9szkX6D7CDBiuJz3PcuuLvrluqganOhygkBQVJIAHHQvxXgpXHQ6ny1rczMm
	 0lynac7Ont9JQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 23 Nov 2026 04:59:13 -0800
Subject: [PATCH v2 10/11] nfsd: check fi_had_conflict under deleg_lock
 before hashing a delegation
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
Message-Id: <20261123-delegts-fixes-v2-10-960ce0fb2fed@kernel.org>
References: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
In-Reply-To: <20261123-delegts-fixes-v2-0-960ce0fb2fed@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, Christian Brauner <brauner@kernel.org>
Cc: =?utf-8?q?Aur=C3=A9lien_Couderc?= <aurelien.couderc2002@gmail.com>, 
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=2002; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=Fg2+c36e0SWvYFoKZfwC5xdM8DWh8Q37YV0PPJeBqg4=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBrBDimjW9ib9jBpIQsJ11FrVPL9rTxpj49SeBn6
 PT9rP6+ACGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCawQ4pgAKCRAADmhBGVaC
 FcGFEACLHCyB2QfqxsZQ4eIuRSqYMKC0kfjPA45PBxqJ/ueOHEDHvZ2enGuid15/kuW5PPdh1h+
 4ViNTjCH/Dm6FSzTlREy0CgjQ/oR1roo588l2Y5tQ0uA+TjWk/Ww5QO+omE/rXTKGAiVOdb72Lg
 pVbNZPFiO5G4geKWH7E7ftjWAOj6FPQtYyE0aE5dQjywtHkdouXgTIRQT+r8CFBx2sKQa945A4X
 gWPv2rdhZyJSyF7z5pUNrr8H0VJJXConk7uoiiAQwqHDYhCR17UXBO84lkVp6F+6PtUy+uPa7Fd
 DLwf1gpyUCDfPgVjhNi5ev8spzUhCxp8LJiLqLvDNNFVDA0bY8SEJYpkJCGASz5ext+7YyjFPyZ
 LYuax9YsJ/dbcATiEWFbJdbrkHrvxphmMEq8aZC5JK85C587vTW7gxBjYIAgzgkpTSbvDqzPrND
 q6s8+uqVpMxQL9xV0Y/uDx/Z7J+/uUCK/NjG3Poe6SrDZXMj3Xl2AbTrHebQvxk9Lfr4SSoLG8I
 hd2juQ8p0yr9UZsGTRLBzNhGuPnNup3nxYwZ8DDh2J5k8K/jqjGx278XjElEUVvi8i3Jl3h5Egn
 pY6Ck4SJyYVmoHhy3Pwg/3vi6IMtuKbpbsDfND5X13U4nkt/jNKR7FJDg5b5hGMbZWee9oK0Pr7
 4DLUl0eC5KmWM6Q==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfs4_set_delegation() checks fi_had_conflict without a lock, then takes
deleg_lock and hashes the delegation. A lease break in between sets
fi_had_conflict and queues the recall. The recall's prepare callback,
nfsd4_cb_recall_prepare(), takes deleg_lock and puts the delegation on
del_recall_lru only if the delegation is hashed. If the prepare runs
before the hash, NFSD grants a delegation that is already recalled but
not on del_recall_lru. The laundromat then never revokes the delegation
if the client does not return it.

Check fi_had_conflict again under deleg_lock. The break sets
fi_had_conflict before queueing the recall. A prepare that ran before
the hash therefore left fi_had_conflict set, and a prepare that runs
after the hash finds the delegation hashed.

Before 5ea9a7c5fe41, nfs4_set_delegation() made the final check under
fi_lock, which nfsd_break_deleg_cb() also took.

Fixes: 5ea9a7c5fe41 ("nfsd: don't take fi_lock in nfsd_break_deleg_cb()")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/nfs4state.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 466416708072..9ea3b0e9b7ec 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -7428,7 +7428,17 @@ nfs4_set_delegation(struct nfsd4_open *open,
 	spin_lock(&nn->deleg_lock);
 	spin_lock(&clp->cl_lock);
 	spin_lock(&fp->fi_lock);
-	status = hash_delegation_locked(dp, fp);
+	/*
+	 * Check again under deleg_lock. A break after the unlocked check
+	 * has queued a recall whose prepare takes deleg_lock. The prepare
+	 * doesn't queue an unhashed delegation for revocation, so the
+	 * laundromat would never revoke a delegation granted after the
+	 * break.
+	 */
+	if (fp->fi_had_conflict)
+		status = -EAGAIN;
+	else
+		status = hash_delegation_locked(dp, fp);
 	if (status == -EEXIST) {
 		held = nfs4_delegation_exists(clp, fp);
 		*held_type = held->dl_type;

-- 
2.56.1

