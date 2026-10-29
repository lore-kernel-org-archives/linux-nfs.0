Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793281276;
	b=GY+1VtcxPigQz3mMSXQflcs1mHP2Vcvxr2+u8m4KEBFtQ+LngddwnKPSIALEu9ksc1O+
	 ORPVEZEt0yyMUP3gC4IPGXFbWvQmdKePsAqIapkfZVJwbWNDA1uPR3aU0swshUacnQsUD
	 sqEGeLkYlAuHD1zl0ESlUyqmNTzfu8QjTKbTb2F/3b8iNlytfCsXoLFs4kLqsdh8/3KdZ
	 ldEX22UFtP/+P9N5SwXZFlyuEunjtYnG3GV9Wg7vbIlj/CFlW9WrmGQ1qZDcCQ7a/VmyD
	 3J5dYCe8iEoGF9JsZ5F+5vtb6cKtxZBzqWY7mOUq6kh+xbrwUMlhSwg7abX8FMtcgtg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793281276;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=29Oh/oZBFa22tCLYhtkn0CLBy/knTtwIJDkasxHm/fw=;
	b=JXwkWsRjAAV+45/erj8UJn2uf5og5+IgSZgWhQARaDP4euiB1rvh1C/tg1oRWbx1gCrw
	 F1jwcvnhh1t9Dlxb55cguVD95pC8tIrvUVHAMobvTU/DIXz1g8x+o02LymSVN1AnPkiS7
	 9XI5p9X1WV2nQ38Q3TzzDxyQH9OnNVuiVk8yaHt5k/cM2m+XghvuAoKtVWlYfozH2I5l/
	 oNhWtB6XmHvRdqHkHjnNe6K6KsAW1k2j3TFxRUuvi0kMZN+gLb9Lo4o4XtMJKpQQtPFqt
	 9UUYtOvTfTdYB/KH9hHgTT20Bx9n8uR1BgXYN24Xv8R2EelazGDeXzsXF3sM+WU6NSQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JBQcbLUI;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A4112606A323
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 13:41:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JBQcbLUI
Received: by smtp.kernel.org (Postfix) with ESMTPSA id DE7EA1F031E2;
	Thu, 29 Oct 2026 13:41:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793281276;
	bh=29Oh/oZBFa22tCLYhtkn0CLBy/knTtwIJDkasxHm/fw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=JBQcbLUIMM85mEZMUZKrdS+Q2enCagizJ2xw5ppzk5lRGsEu/+fAOwX9xwzNnoTib
	 gBOYRqyyNZ+Q8KBt/aXAXd/2tjRS7An4+M1BOuhCKxcwL1SbZNlyRhZ5zNZI6nsb4h
	 fbeBN9Ro4Cjjvad0ouFUdDBKRCbqyip24XFc14geUk/7mNu8sqYIOCC+mHu8NjOS9B
	 H5MgoXYMERzl9H98EvI3phntX6DjwsW4zWqSgRggrMQX4QcoexX/I6gLDNp9/CDV7O
	 15sei5YNmtPjQsoVhVpzuD3otBo9s6cRtSahRorLdiXtuUyJm4GrmAGKk5h0hvPIMC
	 wrwtwc5j/Bmlg==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 29 Oct 2026 09:41:00 -0400
Subject: [PATCH 02/10] NFSD: Check machine credentials before expiring a
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
Message-Id: <20261029-random-stateids-v1-2-8648878fec8c@kernel.org>
References: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
In-Reply-To: <20261029-random-stateids-v1-0-8648878fec8c@kernel.org>
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=1756; i=cel@kernel.org;
 h=from:subject:message-id; bh=2GltPGbwxabjEB2PW21iDkfRaCvHRxOHoB1rlrOUgk8=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq40z3M38tFiExR+t2K5nmG2Lg81++HL+RuMYrg
 /7vX99Vu+mJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCauNM9wAKCRAzarMzb2Z/
 lyC9D/9jVdaQXcqJC+EHRgVuMYgZtox7sC315MyFzvtQAaysde0bZUt9u4WwDL3oamxpRifVOd+
 dstWDeT+kjMjNZXHg1dbjRYybdC5MuvGxO2WZMdqfDEJKkL+4VwtWzn48l/fHNBkop2RHLpTkLZ
 3wM/6Qe7ANT+b9lKK6661b4M//bdjo/py2xYxiWI+OC7YQUMZxFoRDLaZRgMNCH+MZ1E22xNbtN
 o4Hb7Vf2wPnv2EtqwbubOcNpmjFk6VbunSmbSsz/2R2JEueeu0JgMggDLxHGhMHBKjxW/paw5cF
 kXa2P04vi0llVw64+qPHId6bwLbeDmmJGpr0p4ox6cVzCSsPKDjraTEPb9RAfU2/Z6M2ayUXePz
 CYXTXCGBZNS5VqEadQOb8eFlwN2NmHkPT22PtzftQ4PcodbfIMOfMulXu98S3GuZ+UrnDRJgVJK
 yiuvgbhe6GEBkP7ARZ1ZKLEwpMgExPHJqYnfWIFLp/ptFFevkbsOu6b8XDunVY8GwHwEXDdDFhP
 BfVFvHSh2+hKglmfy4+gqgOKQf7Ow5bSp7N7lEpJwbQjtQ+DQEmfmUcd5ubTN1qvVKxXuL+vxm1
 BHeXDw9iKkGz1cwsoMIRZmss48+fTFSQT215LyZ2zL3xK87+uWy5O0d6/4wHK86/jsKBRorjecn
 +6wz00DMLWq8Dcw==
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
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4state.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a613a9f6c330..f0e4fe5be21a 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -5314,9 +5314,6 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp,
 			status = nfserr_clientid_busy;
 			goto out;
 		}
-		status = mark_client_expired_locked(conf);
-		if (status)
-			goto out;
 		clp = conf;
 	} else if (unconf)
 		clp = unconf;
@@ -5329,6 +5326,14 @@ nfsd4_destroy_clientid(struct svc_rqst *rqstp,
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

