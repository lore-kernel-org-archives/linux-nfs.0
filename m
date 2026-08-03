Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C2C9D416863;
	Mon,  3 Aug 2026 14:49:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785768585; cv=none; b=W9qeXgMXVgcq4MCGUr4V9khzIOPTdNDHDZOBSGoPxkDWmIgmYaCGksxP7US5S2lFhR6g1z7dGFqg9uMC6pVLuDuvhH/wIg0f8DpA6JxMpuBoluACBJhdmqftLCAy48fRLTUFuF8G176YQApg6gYQujY4kyIa9sGFuZTn3ErHBAk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785768585; c=relaxed/simple;
	bh=pe3+EpoHPffWMBYNVKGqe1v6LzLgQvq1CeMhX348vxQ=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=rM1CnhEfr57mGczo2Z0bk44LxGY5gQi2/xxajTHm9v+B+3M6YtyUsoDNyQ/04VGteLnJQZXUJJDEQUNWHja+eozbqJHsI2E/PcNCxkoclSi04R2P7SwyUt3cl5XojoIn+j5BKPW2GMQvLGcQrfNdHK+rv/aF/OlYqM5xuE5b2sA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aYCYjquZ; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aYCYjquZ"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E24051F00A3A;
	Mon,  3 Aug 2026 14:49:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785768584;
	bh=eAEG/lKzgqh1MGrPlc+dS4bPGLBQXoVo4If4x/zIEz0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=aYCYjquZuYzgCqF8NL8Ho8X7mfmbD2O4QmaHPBbw8crhSacEESFUQ6qe3A6lUjKdh
	 nLcT3apllQNFW+2VL2Wu7GE1p3zn/L5MYTW6WTXNl5x7KuBBkrmbhCMkKAV4sYErTH
	 6A2cyx2ec6gYWi53c2CFmkv0c/c3xvyYajuL3KxFj811hWJf315j7CByllMY+hV/LQ
	 CjaLJWe58S8W87CjMjWmBuXOi7VnQAVdU/p4rRgDxL40DEwP7qzaVbQMpr6RfZBRTS
	 k2RKA0M/fiOGJUqUcExXWOGWkIB7Bfz54OiQ+nzX+qZ2HfeME6nvgP4+wlQwpkWRZZ
	 RAVZDyDNbLhTw==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 03 Aug 2026 10:49:28 -0400
Subject: [PATCH 2/2] nfsd: fix nfserr type in nfsd_lookup_dentry()
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260803-dir-deleg-v1-2-51be76861821@kernel.org>
References: <20260803-dir-deleg-v1-0-51be76861821@kernel.org>
In-Reply-To: <20260803-dir-deleg-v1-0-51be76861821@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, 
 Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=744; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=pe3+EpoHPffWMBYNVKGqe1v6LzLgQvq1CeMhX348vxQ=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqcKqFFt9J7wbBuq5EJw9bt/aDmvxy02eRtDjfL
 lvZnFb9VYiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCanCqhQAKCRAADmhBGVaC
 FVNFEACEhEu0idd1Un9SKuPC4TZHMMs7+i0ANjQpNptwzrpLwpcqFhsE/IbdKBcGCLSk9RM/+xN
 6E70HJXP+E7J4rj8TxTs1frEpLlvJMIwYitiR+RrluIpC6o2Zr480d07jOAPbkmuT5WrDnHJ7Kl
 9z7XNjBi3MMtY1K5dLFOyIY0hEFi4I1xYii3prmBEDY+jH5giIsNKDUy/3szpOp3T77zwaVSAFk
 7Hm0UkQHF0qxAlDsy1dvDBl8vDEniBGhqQhJNRzcvnLPeAiDyVmpMzTfUsnYnoJfqvefPgB3PeL
 tYzvhGgVVRJc4TrjQ4x/0vtiT+zHnFufEz8TVfjI+RYhVCU9UI8NnyaICqkG2mZSqv9YMjKK5Ym
 1QZQyF0hpxtFoKmfFXvXbtZzlRCL2FvKb58D+SpNVKZgbLTtjoFtrL2dEibvqdhurVNemQcffYI
 zRZ6hdspGGJpJC/FDL5/95EG6NIjLu2+DQUdI+VmA6XXFnOQ0pCQ9LIYyZc/GcF83RUG1du+ZAN
 r1zy2UmHm0nDj9A0EBQWSOW6fASRPKnl+tq3qm2PeJgEb/e22tqM/Yp7pqoEaz9+wEpIqFLdOaa
 qdMptcSSqgt+5qdsDfxgQ075T42RT5uwv0B1X/w8qjKHvuzMohT0Z39Eu3sg5n3PX1z4RrvBGO0
 Qgj9nf9kuD+kFAA==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Both nfsd_lookup_dentry() and nfsd_cross_mnt() return __be32.

Fixes: cf78c5a7d742 ("nfsd: move check_nfsd_access() call into nfsd_cross_mnt()")
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 fs/nfsd/vfs.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index edb08c006a23..807e09521e0c 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -287,7 +287,7 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		if (IS_ERR(dentry))
 			goto out_nfserr;
 		if (nfsd_mountpoint(dentry, exp)) {
-			int nfserr = nfsd_cross_mnt(rqstp, &dentry, &exp);
+			__be32 nfserr = nfsd_cross_mnt(rqstp, &dentry, &exp);
 
 			if (nfserr) {
 				dput(dentry);

-- 
2.55.0

