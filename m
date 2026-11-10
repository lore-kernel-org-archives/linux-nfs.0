Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794332664;
	b=0zbmFQOxBhzTEVu2iegx7gZxn3K9UNDNisD6FTig5CKRXGx4Tn6AtM8M1dVId1eL0Qk+
	 Rbv4QlQo6uOZ7PgaprsnieLggYXEaJBattb4JNqGd0dtZamkpMqAQ1xNaq84PQ7OKRwUk
	 ARxZSrDFW1V9GHrgoFBcDQSV8JV/L7fp/2b+ulIkoMns5DobqPHaWhuK8aO785L6Hy9sI
	 BbmUkVHV27+CSTK+mqiYOznqYittKtq4uFt567XDK6uT/+dUPFho6J7JwjgT7KIp/lMI8
	 9u7qqDlj633g3zlWzp5ReEXrAttMkG99GCTCVlfZO7lN/XaxTG9NGsx1m+4mLWBSHbg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794332664;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=DQG5gHxZEdBveOyXfftRT5YqBueB2FYx8HpAcNzuYFs=;
	b=5VSHEJhRjVCE6i/biP4d54romZfms/HRSKwm9q5r9OB9rXP4BDamjh6Tmslx4ra8b0X9
	 nOT2GD3yBMbh4t1A0KrNhPLRSjE97HnpdtCCeV55+VgSv7igwsx3+nBuQg9DwieqW1yYo
	 wPEnaV7YOxkA4RCtyIP8K1n1OyrbHLLFat3CwLZYybtrS1GqGoN/nff7VpritkKrgeMxd
	 D+0QYIVLrX6+ZiGhaGjO0VKSx0RU58Gk9XmgMKyCiGuiRWOj+O74rwotsiGSn2JFQ+ThT
	 YytUdsvPl4REj9IuQpOEq3Chmy5EmMrqs3w565QFYI4IyYfmOaMOtvr9PTTzw3GmN6Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HOrSPspv;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7097D606A321
	for <linux-nfs@vger.kernel.org>; Tue, 10 Nov 2026 17:44:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HOrSPspv
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 570521F008A2;
	Tue, 10 Nov 2026 17:44:23 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794332664;
	bh=DQG5gHxZEdBveOyXfftRT5YqBueB2FYx8HpAcNzuYFs=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=HOrSPspvD4hKwL4F08tclQL3vS9YmDX2UhR0CGd9hmuKbH6wfLIY4lOKNHVqxB9tm
	 ddzHxNcCQ0Bl3DYag9IplPE/92Ax7xm+2FTxing9Fvp9w7vgKn+v+FZoQY+OzO6tTm
	 HHTDodWu/5effmYdjlUTJh12o1MMYIXWr+t52t/Fyg70pmb7jFzMYbX8WiIv7Jog3+
	 D6OIvnYbQKkhAXpDFm0HbZJ0Hm+E0JfY+3ZWEWCBPHGWUkENCD0Vkjk2ofL6Fboxl5
	 7NQ/FmXfGobrKoOIvEH0Dz2gl5ihv4/NXBTf1NE+sHBMnwdQvi4UA/+90DSO8lJG6Q
	 5NWYRBv0Hg+Sw==
From: Chuck Lever <cel@kernel.org>
Date: Tue, 10 Nov 2026 12:44:09 -0500
Subject: [PATCH v2 02/10] NFSD: Check machine credentials before expiring a
 client in DESTROY_CLIENTID
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
Message-Id: <20261110-random-stateids-v2-2-57e0996eb2a2@kernel.org>
References: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
In-Reply-To: <20261110-random-stateids-v2-0-57e0996eb2a2@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1803; i=cel@kernel.org;
 h=from:subject:message-id; bh=S/xAOrrdwkYdnELwrJq+Rv/her3WNIL87m00RL/vVpE=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq81f0jTQe/iQSNMnXmZ8hlESjirnPkYmXnWUIN
 935nex98qiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavNX9AAKCRAzarMzb2Z/
 l0AOD/93TfOu/JYehfySlSZ1tQFW2LP5RZsQ4g6xDPHQXX1JH6ptqqvpo2WPG1/RPLxat3Yqs23
 ytT5tbrjBw0I+sRCeFhM0NoXyfI7XASWqD4lHhpPWfNIGWbRP/4uh8FAqidEEYfo5EZHqzWGk6Q
 RJdW+hqQr2JUkgjzZw6dypGAQY+LQtlmfgAAzlahvcik3BtOsSgCqGiwhUIEo8PdvnBIB2vpQuZ
 CKvUbMHmua6pLpF1otQUwWiY//KTQp/3c0nRpcrtLa7PW98kU2ht8z3sX2jfgae0jD9M46vbcyg
 UeaVlG8tbKtsgXr7I/BtrRQV7G5387IVfDNmksgFOmpqqyDKFc2oQUu2S6eIVEHyCibX4N2bUSX
 MAwybwnwGC0u3puqBbauiF+c9uEtMLhux1B6ZaMJgMIs1T1MLsXgjwEjDB7mgCKk5MnWokXggSl
 NInJK7mGr3r3A2pFq1WnAwwxrvy3zyTGPtuaudmmn8CtWnbouq3PJPrgLUqhGH3G6Ks/+uCVeXo
 aCMek5lhMrCjOZbt3XH/o1SNOSpMD80xVcGyjTx+bqT5QmuKGpc/m3jbo3fLJ2obyA0iVbaskAk
 KVKxqX1Sbt9OQSljza44FIyJD+e7a4Df362ZosYN/051+0ri8IAYWJXOqIRDNRaO/S1SC2aKnya
 w0k0roajq/jy71w==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

nfsd4_destroy_clientid() calls mark_client_expired_locked() on a
confirmed client before it checks the machine credential.
mark_client_expired_locked() unhashes the client, and when the
credential check then fails the error path clears clp, so
expire_client() never runs. The nfs4_client is gone from every lookup
table but never freed. A requester that knows only the clientid of an
NFSv4.1 client that has destroyed its sessions can orphan a client
that registered SP4_MACH_CRED to prevent exactly that.

Check the credential before mark_client_expired_locked(). A request
carrying the wrong credential now fails with NFS4ERR_WRONG_CRED even
when the client is busy, where it previously failed with
NFS4ERR_DELAY first.

Fixes: fd699b8a48c0 ("nfsd: don't destroy clients that are busy")
Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d3ce40420fd0..010155cc6f97 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5324,9 +5324,6 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp,
 			status = nfserr_clientid_busy;
 			goto out;
 		}
-		status = mark_client_expired_locked(conf);
-		if (status)
-			goto out;
 		clp = conf;
 	} else if (unconf)
 		clp = unconf;
@@ -5339,6 +5336,14 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp,
 		status = nfserr_wrong_cred;
 		goto out;
 	}
+	if (conf) {
+		/* Unhashes conf; expire_client() must follow */
+		status = mark_client_expired_locked(conf);
+		if (status) {
+			clp = NULL;
+			goto out;
+		}
+	}
 	trace_nfsd_clid_destroyed(&clp->cl_clientid);
 	unhash_client_locked(clp);
 out:

-- 
2.56.0

