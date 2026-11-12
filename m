Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794516195;
	b=VMll748bf6eDE8evaDlAjTFAnO3BAGykYUvNmpEjz79bBAwk3E44YcILtSbAzYt6MspM
	 lBEEUaAbpVrLntXff9Cdiv7yMCev+S+mEd9tNYuutNGfgcIG4SutJON4hzmmfgOnTYWLx
	 cf+VpvLs7uTk25anyMILngMBdxQFgHj0b+0CjXrueyQxwZkPOuo62ocEiY5LCZi3Wwn26
	 ve0YfgyiBvEa0bQwoSG9W74URpBv4XxJUOHq+18QDutx+JjzwG9+AEDcDoBKFcDgGNpvu
	 s1Fx7Xc/EyY4/1YsrQhjlIdxFSx3xNXJKPBVIJSfuomuYqrKMjIRsALiAXsyZhI0U9A==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794516195;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=qE6HET4kUSbC3t/vFAoNIiLFoBEe7YFboPriSBzNQTI=;
	b=TEw0ov2u45k66wvGDtPXjmtcmqY02upxmjgeCAUHAvL4YVRHjCKhLNklXcsAktwv58Yu
	 wDIKRTSBBKjUs6L4lzY1UHKKcyF85Xl4FgcWxAbK8sdxgS3XEteKZfjo1bnBfOLwJRoCz
	 nBoxyx5YUQC0bmPywYoDXQD0ysWBsJw9+l3AeLpOpjaCQCbQEcm7lPfnIahfU+LiwobSt
	 7qzHrXq6dpbtd855tYfR8JbmGhXt/9Ge60inSyXAFB0te2t50IYUjiWSTQkXTy8t+bBKD
	 gPio51sNIEmZCMn0h8iUMoX8sh3fygeli5b0FMy472BpkDvBNqCC/ABeCXvoeh0gamA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cz6L4n3t;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C00A5606A32D
	for <linux-nfs@vger.kernel.org>; Thu, 12 Nov 2026 20:43:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=cz6L4n3t
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A04A41F000CB;
	Thu, 12 Nov 2026 20:43:14 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794516195;
	bh=qE6HET4kUSbC3t/vFAoNIiLFoBEe7YFboPriSBzNQTI=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=cz6L4n3t1YBDC0df02to42k6A4UnCNfHrj7BIqdAbwqN7Towt8uVB7UFflAObDCLU
	 Iy0XB3HQg8WKbIyW9+qfxbORLEE5+/3+fODdqGZZxGB5Q1HGz3FSQReEGZO6qOv2jH
	 QZmTGQ+i+truiXqzVOVMyZNnwI9wCQ7gKTUuxfPLcW0jJukBWhz7NUNaGamtyDkMVJ
	 CRAvfQsHOKubz8C+CEpCUu6PCOQGTBIfpIzgVYpEPHzCInB7sn8R7RRnPT+knter9R
	 6JdmZUIj7lR1VGbAYKQe/XYcHQYZnoFeULtyK53a30i8Z8fOQNyyajoivCgXdwYsf8
	 cZWm6ah9J4Svw==
From: Chuck Lever <cel@kernel.org>
Date: Thu, 12 Nov 2026 15:43:02 -0500
Subject: [PATCH v3 2/7] NFSD: Do not validate the transport before a
 deferred flavor check
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
Message-Id: <20261112-verofess-2-v3-2-487532e4d7ca@kernel.org>
References: <20261112-verofess-2-v3-0-487532e4d7ca@kernel.org>
In-Reply-To: <20261112-verofess-2-v3-0-487532e4d7ca@kernel.org>
To: VeroFess <coderzeng@gmail.com>, Jeff Layton <jlayton@kernel.org>, 
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, 
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, 
 Al Viro <viro@zeniv.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, sashiko-bot <sashiko-bot@kernel.org>, 
 Chuck Lever <cel@kernel.org>
X-Mailer: b4 0.17-dev-9c833
X-Developer-Signature: v=1; a=openpgp-sha256; l=2406; i=cel@kernel.org;
 h=from:subject:message-id; bh=X9YcMAUfFLulvqoRf3ZIcz2Cctwog/nwTL4UEXBIDGo=;
 b=owEBbQKS/ZANAwAKATNqszNvZn+XAcsmYgBq9iTeWGonzTjjZy9D58YrdXrqVa9GqCILs3jbJ
 o9kcKLwNqiJAjMEAAEKAB0WIQQosuWwEobfJDzyPv4zarMzb2Z/lwUCavYk3gAKCRAzarMzb2Z/
 lxKbD/9bOEncMTzGxVWZEAFQI6dEkHmlZBlz9Vo9Th8DMe8SY35aAh7bV2LkMGsHU5/NrzhuSjl
 YSiiLds5J4mMTFjgs8CcAILBXwN4YFXDewmWciAcuWh82NJaGyh3P1T4x38U5zWZj+4sdOll/Kk
 4whw4+Yi+7C4OmiVi+Y6PDe3U1TBuiDEJpBL2gWRSXP6fGoaOVHNSOeNkXVfAByLqy1i7SDBHE9
 M63R8fLrafPz8FfEnXytC0mht4DhrltbwTTr3q4LC+03SIJoH6/8/AV38NiqRkmqAw5w9Htfn+j
 sIc6F5TQG5yi+0KWCFj0cOHnkPdAu3Ut/FPQc7/T5u7eU8G6lxnxrR0ZhGflEUcosnTwI3VJQZK
 JQocp5BVEZp/QrOfqVr/zXcfVvjrBiK6Lk7HGyHeJHI/iV3fn89LHqD+Y4KEm94AEIDQZuzDeZh
 +mi1vO3N+Fofbq0JZ5XAohF8DPPR13dicJA1JXSjYY4yysqokiPVp9Kexkp1cBnlCZEMnL3Vq62
 kKPs0PuxbRFUtb80XH4VXWxcg8NloTrzfrJ+eF1KS7Ia+1RS089RV5F8yUGjnlGnKK2scNG/pG9
 3PncNLGg4UVgUqoCFov9VesCoFE2l4NNpc6u+WAHTQTDZNodAMzl1z/2XYUZ9M19E/V/Y/9pLXW
 fyZ8Dgo0ynOQjDg==
X-Developer-Key: i=cel@kernel.org; a=openpgp;
 fpr=28B2E5B01286DF243CF23EFE336AB3336F667F97

fh_verify() marks the transport valid once a filehandle passes the
export's checks, and svc_check_conn_limits() closes only connections
that are not marked valid. Since commit 6a7d0b390a0b ("NFSD: Defer the
PUTFH export security flavor check"), fh_verify() skips the flavor
check when the caller passes NFSD_MAY_BYPASS_FLAVOR but still marks
the transport valid. A peer whose security flavor the export does not
accept can send PUTFH on any number of connections, and
svc_check_conn_limits() never closes them.

Mark the transport valid only when fh_verify() has run the flavor
check. READ and WRITE with an OPEN stateid do not call fh_verify(), so
also mark the transport valid when the deferred check passes in
nfsd4_proc_compound(). A connection that carries only those compounds
would otherwise stay subject to closure by svc_check_conn_limits().

Reported-by: sashiko-bot <sashiko-bot@kernel.org>
Closes: https://sashiko.dev/#/patchset/20261111-verofess-2-v2-0-01596ca4d8b1@kernel.org?part=2
Fixes: 6a7d0b390a0b ("NFSD: Defer the PUTFH export security flavor check")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs4proc.c | 6 +++++-
 fs/nfsd/nfsfh.c    | 3 +--
 2 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index db4a07b2c1a8..60e365678d4c 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -3501,9 +3501,13 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 				clear_current_stateid(cstate);
 
 			if (current_fh->fh_export &&
-					need_wrongsec_check(rqstp))
+					need_wrongsec_check(rqstp)) {
 				op->status = check_nfsd_access(current_fh->fh_export,
 							       rqstp, 0);
+				/* READ with a stateid does not call fh_verify(). */
+				if (!op->status)
+					svc_xprt_set_valid(rqstp->rq_xprt);
+			}
 		}
 encode_op:
 		if (op->status == nfserr_replay_me) {
diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index f76ce9cc405c..6a18cf52ab8e 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -500,10 +500,9 @@ __fh_verify(struct svc_rqst *rqstp,
 		error = check_security_flavor(exp, rqstp, may_bypass_gss);
 		if (error)
 			goto out;
+		svc_xprt_set_valid(rqstp->rq_xprt);
 	}
 
-	svc_xprt_set_valid(rqstp->rq_xprt);
-
 check_permissions:
 	/* Finally, check access permissions. */
 	error = nfsd_permission(cred, exp, dentry, access);

-- 
2.56.0

