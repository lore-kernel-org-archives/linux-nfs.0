Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BE73229A1
	for <linux-nfs@vger.kernel.org>; Tue,  1 Oct 2024 20:34:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1727814840; cv=none; b=YycWkVOR/flp+0peJvOWOmqkISiCTik5GwODfwxC8Yv23o7w3AprPQ26BMf9D2d5tMuXbxO95CDxcb94de1dLEQCrX6RNmi3PrlmTjnmyWkzOjWQlNz9wzzSxahYNf4q3UYYTFWN6rnyE5LnfN1Pl7hjBSsHGrU1aelRfZOI/Vw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1727814840; c=relaxed/simple;
	bh=cXO6Wp7k2OmhudSclTGqhq9ZHputSqedfNPyxqfq4Xg=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=ZmP31Aq104WRyFlHPdxYvwsjmh7E3oPk/0XHDNaBU8MyT+ndYusQRN7G0HMZsR1eLojQeD9MRdpuesHVDH1u93yQ6QEttCh0PQf6TnNk4sJOInPTnQmGLTL48oqT/YmiRxrn8EkvUEp83SVZsDje8xVirKe4XSzM/4tW0QUZrBA=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=CV27aJEj; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="CV27aJEj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EB941C4CED1;
	Tue,  1 Oct 2024 20:33:59 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1727814840;
	bh=cXO6Wp7k2OmhudSclTGqhq9ZHputSqedfNPyxqfq4Xg=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=CV27aJEj5dmiAasohww1VMeMLyrBI1OK2yiVp33TvUVw1giAem6pM6VEDbLS+nC/i
	 4Ri//yMVKA+1/pFam41fxpQUssmxO6N+37Q9OvKuMQgWdx3VtSBNxber2AXWcedKv7
	 6K9Y7wuzs59H+Ixh0BGtpS+qDs+aaRKlo+KGS+E8GNYBNjUaXytLvOZHAQgrJyw1Ro
	 mrYCxbjblhHS1XEA/p9lH7GIZPD0+DhiIe/8iOXOL0vRLScOxY/2ux0qTeDKUui/br
	 d0M6P2hq7Zra55yfYyxo8giZOKUUQRY5vE/ZlmvwiBW5y2/x/wP70ozyKWE0SmW+g6
	 jTu8xeP0fKLig==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH 3/5] NFS: Rename get_nfs_version() -> find_nfs_version()
Date: Tue,  1 Oct 2024 16:33:42 -0400
Message-ID: <20241001203344.327044-4-anna@kernel.org>
X-Mailer: git-send-email 2.46.2
In-Reply-To: <20241001203344.327044-1-anna@kernel.org>
References: <20241001203344.327044-1-anna@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Anna Schumaker <anna.schumaker@oracle.com>

We have a put_nfs_version() that handles refcounting on the nfs version
module, but get_nfs_version() does much more work to find a version
module based on version number. Let's change 'get' to 'find' to better
match what it's doing.

Signed-off-by: Anna Schumaker <anna.schumaker@oracle.com>
---
 fs/nfs/client.c     | 8 ++++----
 fs/nfs/fs_context.c | 2 +-
 fs/nfs/nfs.h        | 2 +-
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index f5c2be89797a..63620766f2a1 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -80,7 +80,7 @@ const struct rpc_program nfs_program = {
 	.pipe_dir_name		= NFS_PIPE_DIRNAME,
 };
 
-static struct nfs_subversion *find_nfs_version(unsigned int version)
+static struct nfs_subversion *__find_nfs_version(unsigned int version)
 {
 	struct nfs_subversion *nfs;
 
@@ -93,13 +93,13 @@ static struct nfs_subversion *find_nfs_version(unsigned int version)
 	return nfs;
 }
 
-struct nfs_subversion *get_nfs_version(unsigned int version)
+struct nfs_subversion *find_nfs_version(unsigned int version)
 {
-	struct nfs_subversion *nfs = find_nfs_version(version);
+	struct nfs_subversion *nfs = __find_nfs_version(version);
 
 	if (IS_ERR(nfs)) {
 		request_module("nfsv%d", version);
-		nfs = find_nfs_version(version);
+		nfs = __find_nfs_version(version);
 	}
 
 	if (!IS_ERR(nfs) && !try_module_get(nfs->owner))
diff --git a/fs/nfs/fs_context.c b/fs/nfs/fs_context.c
index 7e000d782e28..d553daa4c09c 100644
--- a/fs/nfs/fs_context.c
+++ b/fs/nfs/fs_context.c
@@ -1467,7 +1467,7 @@ static int nfs_fs_context_validate(struct fs_context *fc)
 
 	/* Load the NFS protocol module if we haven't done so yet */
 	if (!ctx->nfs_mod) {
-		nfs_mod = get_nfs_version(ctx->version);
+		nfs_mod = find_nfs_version(ctx->version);
 		if (IS_ERR(nfs_mod)) {
 			ret = PTR_ERR(nfs_mod);
 			goto out_version_unavailable;
diff --git a/fs/nfs/nfs.h b/fs/nfs/nfs.h
index 0329fc3023d0..a30bf8ef79d7 100644
--- a/fs/nfs/nfs.h
+++ b/fs/nfs/nfs.h
@@ -21,7 +21,7 @@ struct nfs_subversion {
 	const struct xattr_handler * const *xattr;	/* NFS xattr handlers */
 };
 
-struct nfs_subversion *get_nfs_version(unsigned int);
+struct nfs_subversion *find_nfs_version(unsigned int);
 void put_nfs_version(struct nfs_subversion *);
 void register_nfs_version(struct nfs_subversion *);
 void unregister_nfs_version(struct nfs_subversion *);
-- 
2.46.2

