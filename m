Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7AF6F33F58E
	for <linux-nfs@vger.kernel.org>; Sun, 12 Jul 2026 15:09:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783868954; cv=none; b=WVcNoBm1lYCllcBdBli6xgbiNW67+fcmfN9gieTDO2OCTs58f3sgeruWXAt4rnUImYiAsjXrFv7EuIoX/hkGBQnJhkIApaTItoTSSpaw4Paq3Y92DMTEk5rNujAp9/BvgxqM2u2BPaDNztiIWLLUgXvhdzDhaUCXZwAfXVYxu4M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783868954; c=relaxed/simple;
	bh=Mee4xtfyNaSH/SxXUGZwdtEhVaLM7DEjdb2FJu+3/8s=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=NZraHBm9LL3+ymgIVpG9L0FxHjHKbyaWgaHVj9kzhEGr3e8dq9LCvqUGAaWLHBfp8bwei9jqe2SeCK4RzWqbneG1DLT0KpjlWsi1YlbyBsliYgCSOENXJBKBnQQg2w+gecgxWNQ/JMC2rTy+7xHnOI9t5YwMMP7bhXCaXDktF/c=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=eFFe8/pa; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="eFFe8/pa"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 964621F000E9;
	Sun, 12 Jul 2026 15:09:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783868953;
	bh=qTLvHS+pZksw+YAZ0EMUrYFKZ6SwGc82es8e0Fox1t8=;
	h=From:To:Cc:Subject:Date;
	b=eFFe8/pav+HMmZmCJrpO6CDvgjHWzecpwSJt1WC6X5LMPHKplhgffjqBpMArJ5vzr
	 TOAFI0XJ2vjck8QgL6VcwFbGnlDVnqixS+SPKj4sx8oPcKK5sbQEoDNC4ipCT3wpaM
	 QJ08VRpDyjChVk2YupFuPPwtMrhJv3qZylOs9iA/+ykmKBdi3PJNbmdP5kG1eRnRsT
	 mlAA8ixXAuASGJxAHRa6nlErB06sXd7lHjqt9LbDx8OoWczf4J/UCWtDo7z5tJNqxB
	 4wb/XGdTjBhJGQHz8DZF2PvcQ1ZlP5LZsc1LvTR0IY5m6UXSVQvJVFrc1pKKuSoz40
	 yOQhbM/JIkzGQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH] NFSD: Encode only the status in NFS-ACL v2 GETACL error replies
Date: Sun, 12 Jul 2026 11:09:11 -0400
Message-ID: <20260712150911.48461-1-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

The NFSv2 ACL GETACL reply is a union that carries file attributes
and ACL data only when the status is NFS_OK. All error cases are
void results. However, currently the NFSv2 ACL GETACL result encoder
decides whether to append the "OK" body by testing only whether the
file handle resolved to a positive dentry, not the actual reply
status.

A GETACL request that resolves its file handle but then fails for
another reason (an unsupported mask value, a getattr failure, or an
ACL retrieval error) therefore appends file attributes and ACL data
after the error status on the wire. Worse, when the mask is
rejected, fh_getattr() hasn't been called at all, so those
attributes are serialized from a zero-filled kstat and are junk.

The logic before the xdr_stream conversion used the reply status.
Revert to that approach (but keep the xdr_stream conversion in
place).

Fixes: f8cba47344f7 ("NFSD: Update the NFSv2 GETACL result encoder to use struct xdr_stream")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs2acl.c | 31 +++++++++++++++----------------
 1 file changed, 15 insertions(+), 16 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 827f90194c43..2998640f259d 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -253,22 +253,21 @@ nfsaclsvc_encode_getaclres(struct svc_rqst *rqstp, struct xdr_stream *xdr)
 
 	if (!svcxdr_encode_stat(xdr, resp->status))
 		return false;
-
-	if (dentry == NULL || d_really_is_negative(dentry))
-		return true;
-	inode = d_inode(dentry);
-
-	if (!svcxdr_encode_fattr(rqstp, xdr, &resp->fh, &resp->stat))
-		return false;
-	if (xdr_stream_encode_u32(xdr, resp->mask) < 0)
-		return false;
-
-	if (!nfs_stream_encode_acl(xdr, inode, resp->acl_access,
-				   resp->mask & NFS_ACL, 0))
-		return false;
-	if (!nfs_stream_encode_acl(xdr, inode, resp->acl_default,
-				   resp->mask & NFS_DFACL, NFS_ACL_DEFAULT))
-		return false;
+	switch (resp->status) {
+	case nfs_ok:
+		inode = d_inode(dentry);
+		if (!svcxdr_encode_fattr(rqstp, xdr, &resp->fh, &resp->stat))
+			return false;
+		if (xdr_stream_encode_u32(xdr, resp->mask) < 0)
+			return false;
+		if (!nfs_stream_encode_acl(xdr, inode, resp->acl_access,
+					   resp->mask & NFS_ACL, 0))
+			return false;
+		if (!nfs_stream_encode_acl(xdr, inode, resp->acl_default,
+					   resp->mask & NFS_DFACL, NFS_ACL_DEFAULT))
+			return false;
+		break;
+	}
 
 	return true;
 }
-- 
2.54.0

