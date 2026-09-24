Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A278E43BDC8
	for <linux-nfs@vger.kernel.org>; Thu, 24 Sep 2026 21:22:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790284971; cv=none; b=VCr2VWWUvstPD7F5Jt7O1paBn1FgXbVJFQcgIXmUCyXcoYk2GkOd18RgcLErk60/iKHNmFkkvHB99i3+D2SJM8CpKypIxiaePhx/+0zMj6QboIFLZx0G90e0Xq8msDvIEFIUJ+1KCTXYdJYkF5GWUvg9v88hKVrYfKyKSg+0yEk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790284971; c=relaxed/simple;
	bh=12HX7lkrHXXCNlElnMJukU9GZVj9otC1fwq/yRdL14E=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=dQE8i7exmTVlhdajaTer3G/zaUkvP+fvRN+BW7aN5VTIKdXdLf0+oy/5k5bhh+PTb3V07RESYlqjOLfx4dfKAF+AxiR3LkNiOIcryUHT2SJU63C/DAoZAkKQ+KSpkObyeemYo5DJyaPorSrhxAgaCzu5ZTNxRudw4NlHV4/ZdjE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=b7AT3KkI; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="b7AT3KkI"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 98B5D1F0089A;
	Thu, 24 Sep 2026 21:22:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790284970;
	bh=xolijnKbT7d965PVPXYytTqHCMmp0O5PXSjeCV0g8lM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=b7AT3KkI9zYQUzricqp+T3AndA52YUhVCWecpIdskiawllvmzF22aIoR/dggZ9Xg5
	 BAjCdqGWTRZSwTjTPdsptW7kTyklhki28ygwH4YnRZ+laLmN03su7VPznRc+JTz5Ii
	 wY2tBiVIXb6WKAPKoFf6c26ZGNC+RBsPZWek1cdpluIaGr78LQg4q6Jez9511HvhaL
	 PkS2QJ+/jTfE1Dhbs0xBhllDQ8NSYKo4LCtH+KWaJXZOd1CO1TLby/8/Gr/D9Z6HDA
	 1wmrgi2/4B2SFbmV4KEM7HgL1kW+/s8TZb7f8vb/KjyjCWnrTDezawyEnE6kKc6fz9
	 3/h0d7mY747sQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna@kernel.org>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 2/2] nfs_common: Do not stream-encode an ACL with fewer than three entries
Date: Thu, 24 Sep 2026 17:22:46 -0400
Message-ID: <20260924212246.114355-3-cel@kernel.org>
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

nfs_stream_encode_acl() reports at least four wire entries for any
ACL that has entries, because a three-entry ACL is sent as four
with a synthesized ACL_MASK. The entry encoder then walks
a_entries[] up to that count. For an ACL with one or two entries,
which posix_acl_from_xattr() and the filesystem on-disk parsers do
not reject, the walk reads past the end of the posix_acl
allocation and copies the bytes into the GETACL reply.

Report zero wire entries for an ACL with fewer than three, the
same as for an ACL with none.

Fixes: 8edc0648880a ("NFSD: Add an xdr_stream-based encoder for NFSv2/3 ACLs")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs_common/nfsacl.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfs_common/nfsacl.c b/fs/nfs_common/nfsacl.c
index 38bb2c294d7c..24ee7f622b18 100644
--- a/fs/nfs_common/nfsacl.c
+++ b/fs/nfs_common/nfsacl.c
@@ -157,7 +157,8 @@ bool nfs_stream_encode_acl(struct xdr_stream *xdr, struct inode *inode,
 			   int typeflag)
 {
 	const size_t elem_size = XDR_UNIT * 3;
-	u32 entries = (acl && acl->a_count) ? max_t(int, acl->a_count, 4) : 0;
+	u32 entries = (acl && acl->a_count >= 3) ?
+		      max_t(int, acl->a_count, 4) : 0;
 	struct nfsacl_encode_desc nfsacl_desc = {
 		.desc = {
 			.elem_size = elem_size,
-- 
2.55.0

