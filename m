Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677239;
	b=jPv6C5jOaQklB3/LwMiITIBPeEXb6L1Oj2medkrmObvPqF9BCV1SJ9RhG5x+kbJIhwdc
	 Ie3h0e/kfY6bQce/R4d7E33knOY1VwEFSXg+v4rmxPg2yEkPPnn2wwz3Uark1NolUaXei
	 lcaORSSteyRdxIbR01380xwymIehDVmRqungxlT9yt61/jOw+ucklr78xs/yPjHNpZZME
	 iqfSLxWxfmO0qvXt8W8ubJfRU6bGQE3p2cWEvgll5aCpuTdcZAhqxe4sJZpvOylqce4Bw
	 p6UV16GHxjk488d8oolwbYllGV5K2Ex1t1iBt+t5eKaL0Ue9tu7GN/OtTDOAv8AeOgA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677239;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=l/SYOztz3S1wk1X+qq29s1VhuKD7EJEaLUhpfaRqnBY=;
	b=H/Qw5ryLAi80hBVgilplXO7ORR2xu0ksetlaI3rXzWzHp7GWWYLG2bRbwXqFd5swUhMv
	 MeGnaseWkqO8Avayq/WewsWhyv7JL6RxEt29dKoLJF+dGRfB+3W4cw/g0Erv4hgFeyuOg
	 I1JFgSCZgQleeqXbXxsACsb2YrUhjYNyA8aG7SGA0runtu+qd1fzywn5GBAedmPMT9DKs
	 HE9KaO2RVSts5hbu5SqyqfOgZRIPjTIAaoaqGTqL16+kuK+8cJboU98cIdnaHGZHHDBqw
	 C06obQJHN8O5Ik8254WbVOS4xCX7CbC4nTm2UXwoSts8fSnIaqPFXr1kQ+gFyWUbFUw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NNoOVqI0;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 508FD60A383A
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=NNoOVqI0
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6D33C1F000C3;
	Thu, 22 Oct 2026 13:53:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677239;
	bh=l/SYOztz3S1wk1X+qq29s1VhuKD7EJEaLUhpfaRqnBY=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=NNoOVqI0EMBhRgJiXv/O5AzOHGCaow+KJFicZ7fmAffpEYJuzEyeUQsCqsaywj6M5
	 B4AuX2qKEHy4Qw5knwsUOXDGapIKn2f2IBnf5iy7sEWKLEHXgGRE73Qm0aCcI/PJFO
	 n143tNw23yZ6uYbANpBOW/Ej5VrASfLWdicugP/gyvUQ0Jryyw24qjHgVSvAhlFm8s
	 6y7v1qPz+bLsWG/i3pHDFp15MCkHbTly0ne4hPGfbmN00PeJADKgiv0BZJ0pHrWd6V
	 sgtA0/95swa4vUp8DCEnYXru98jkZFQPjhEY8+u0y3PKBPHOSmo2iLg8zJkoarrS4U
	 1IGmzPHdFKCew==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 17/17] NFSD: Map every NFS_ACLv2 reply status into aclstat2
Date: Thu, 22 Oct 2026 09:53:41 -0400
Message-ID: <20261022135341.14265-18-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261022135341.14265-1-cel@kernel.org>
References: <20261022135341.14265-1-cel@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsacld_map_status() translates only the three fh_verify() statuses
that have no NFSv2 equivalent, so every other status reaches the
encoder unchanged. fh_verify() returns nfserr_perm for a request from
an insecure port, and both it and fh_getattr() pass errno values
through nfserrno(), which yields nfserr_jukebox for ENOMEM, EAGAIN,
and ETIMEDOUT and nfserr_serverfault for an errno its table does not
list. NFS_ACL version 2 shares its status space with NFSv2, so 10008
and 10006 are values an NFS_ACLv2 client cannot interpret.
draft-ietf-nfsv4-nfs-acl Section 5.1.5 lists the status values an
NFS_ACLv2 server returns, and these are not among them.

Pass through the statuses that are members of aclstat2 and map the
rest to ACL2ERR_IO, the status nfsacld_map_errno() already uses for
an unlisted errno. Translate nfserr_notsupp to ACL2ERR_NOTSUPP, the
status nfsacld_map_errno() returns for EOPNOTSUPP. The existing
BADHANDLE, NOFILEHANDLE, and WRONGSEC translations are unchanged.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs2acl.c | 23 ++++++++++++++++++-----
 1 file changed, 18 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index a805d2ac76db..b4ab0bb1808d 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -187,15 +187,28 @@ static __be32 nfsacld_map_errno(int errno)
 static __be32 nfsacld_map_status(__be32 status)
 {
 	switch (status) {
+	case acl2_ok:
+	case acl2err_perm:
+	case acl2err_noent:
+	case acl2err_io:
+	case acl2err_acces:
+	case acl2err_inval:
+	case acl2err_nospc:
+	case acl2err_rofs:
+	case acl2err_notsupp:
+	case acl2err_dquot:
+	case acl2err_stale:
+		return status;
 	case cpu_to_be32(NFS4ERR_NOFILEHANDLE):
 	case cpu_to_be32(NFS3ERR_BADHANDLE):
-		status = acl2err_stale;
-		break;
+		return acl2err_stale;
 	case cpu_to_be32(NFS4ERR_WRONGSEC):
-		status = acl2err_acces;
-		break;
+		return acl2err_acces;
+	case cpu_to_be32(NFS3ERR_NOTSUPP):
+		return acl2err_notsupp;
+	default:
+		return acl2err_io;
 	}
-	return status;
 }
 
 /*
-- 
2.56.0

