Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9ADF4414A15
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 21:22:49 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790284970; cv=none; b=MkazHVXjrqdx5RSO6RtKDXXcNxWjgYc8t67cNiOb0mlMjgIhv4PEphYIJNOTfFLBnLk0qBqvTsTG0z89spAxkJIpuPCGa11uVWRr0nNz2Dm8QIy8c8aTdLW5Oh4xOLvkNiNXkH8HC6HG/aNk/3nVP3vKCIRDIXWmkJCAs4gRmrs=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790284970; c=relaxed/simple;
	bh=f3Idy7rXL71t5zhf0/HYEqKJ0oQZu9e9s3V0ruLBJTo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=fY4s8bD1dK6ZDUf1c7yCKtI2sNYtkq7yl00o1ZyAU8F9l7UIAAb9kwpmJBbfFevCeraCxGYSkEW4F+liNvmOaKPcaYJ1b5oaWLzw3wABV3OsSl6AcwixG6bpfygTbuaVQQTvsbSBx/8XBgBtl2nr0/kGnzH5omQw0GkkWUfHAto=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ecvatVD6; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ecvatVD6"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B07D41F00898;
	Thu, 24 Sep 2026 21:22:48 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790284969;
	bh=U+BM/4nV130L8BoSSnY4C4RUE8CnigI0wMoLkYtKe2w=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=ecvatVD6PMUJXwL9/j32xY4C9aLH7ybSoB193lLSOka44IJ863HByGGtmsiuwfeNV
	 dMrdg+alySPezqM3K2+WhD4qwR/KeSrNP4aaj1eoDjn94129AxjRAqBDMgH/avdvkX
	 x5/dIgpdPSpptqHZ37MdOLcoeRwUPpIadoK89kDsxUMT54JO5grAY7QeqatOb/VS2C
	 gCtTO+/rQGgKl5CY71As++uZeRGHVbfw71GALMcGf4e5LCDYOkZcNFABI+gkIgxiA8
	 ju21Q0hSs95pT1k5kg7S0kDwvdLvVhJ1PvEDX0Kl2AmRfa6TcJmQizmXoYXOuM1XEi
	 Bmzd4Gf+1tPgw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna@kernel.org>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 1/2] nfs_common: Do not encode an ACL with fewer than three entries
Date: Thu, 24 Sep 2026 17:22:45 -0400
Message-ID: <20260924212246.114355-2-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260924212246.114355-1-cel@kernel.org>
References: <20260924212246.114355-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

nfsacl_encode() reports at least four wire entries for any ACL
that has entries, because a three-entry ACL is sent as four with a
synthesized ACL_MASK. The entry encoder then walks a_entries[] up
to that count.

A one- or two-entry ACL cannot arrive from setfacl, because
set_posix_acl() validates it first. It can arrive from an NFS
server. The NFS client caches a GETACL result without validating
it, and posix_acl_create() hands the cached default ACL to
nfs3_proc_setacls() when the client creates a directory. The walk
then reads past the end of the posix_acl allocation and copies the
bytes into the SETACL arguments.

Report zero wire entries for an ACL with fewer than three, the
same as for an ACL with none. Count them the same way in
nfsacl_size(), which otherwise sizes such an ACL at four entries
and leaves the reserved bytes unwritten in the SETACL arguments.

Fixes: a257cdd0e217 ("[PATCH] NFSD: Add server support for NFSv3 ACLs.")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs_common/nfsacl.c | 3 ++-
 include/linux/nfsacl.h | 5 +++--
 2 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
index e2eaac14fd8e..38bb2c294d7c 100644
--- a/fs/nfs_common/nfsacl.c
+++ b/fs/nfs_common/nfsacl.c
@@ -93,7 +93,8 @@ xdr_nfsace_encode(struct xdr_array2_desc *desc, void *elem)
 int nfsacl_encode(struct xdr_buf *buf, unsigned int base, struct inode *inode,
 		  struct posix_acl *acl, int encode_entries, int typeflag)
 {
-	int entries = (acl && acl->a_count) ? max_t(int, acl->a_count, 4) : 0;
+	int entries = (acl && acl->a_count >= 3) ?
+		      max_t(int, acl->a_count, 4) : 0;
 	struct nfsacl_encode_desc nfsacl_desc = {
 		.desc = {
 			.elem_size = 12,
diff --git a/include/linux/nfsacl.h b/include/linux/nfsacl.h
index 8e76a79cdc6a..e4155e69c8dd 100644
--- a/include/linux/nfsacl.h
+++ b/include/linux/nfsacl.h
@@ -26,8 +26,9 @@ static inline unsigned int
 nfsacl_size(struct posix_acl *acl_access, struct posix_acl *acl_default)
 {
 	unsigned int w = 16;
-	w += max(acl_access ? (int)acl_access->a_count : 3, 4) * 12;
-	if (acl_default)
+	if (acl_access && acl_access->a_count >= 3)
+		w += max((int)acl_access->a_count, 4) * 12;
+	if (acl_default && acl_default->a_count >= 3)
 		w += max((int)acl_default->a_count, 4) * 12;
 	return w;
 }
-- 
2.55.0

