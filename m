Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793109123;
	b=CT4lvspRiSoSHicvYszoTUBCBMkCSI9scXK2M9VInYHN3REzHjWGuHlt7TBOdQhDuGHe
	 E1qRdAm1RvNevH5/UYpiSsSy3SF4ikVU3KeYDVLmOKy89U4tELQCZO8gZiO2sQf+PLuWt
	 FUb0fUwat/ErBfIEHHjzmhUWE2ZreRbKWsWj8WIlDwIHop58yIsAZUIDQHnnHe1SfeVlA
	 +7A1LwLmbeIcv3Ihgp8BKC+KCUsB5M4/5HXftNSnQDvnb2X6EmuSixuMofeKgsGkjNIiY
	 001jW9ZX6QzA1wc8gQGr32wQBOluZFSI8x+lHGKNhHe2X0/bS1BAkTrldFFX+vfULzw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793109123;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=6N6gr0n21ZUbaOSGT3hBoEuV0Akrsrxoyqq7KPCJ1Rc=;
	b=0JvNGEQZ8naUa56r8f1GLNt5GmZxcDiwJB4qlHovrX1zf+C5Xhf4ivy/meafrbs4Qs6F
	 f64Fqd6JDP3fn+nCht+ruCI8kqwgdNxN1ySCzARfLcRD3e0o+XeDbwyoo3ag3MYfLDHKO
	 IVNrcDSfjfc93gBsVVEdMa1eF2kc2WJWCT8aFEKwqRO6oxgSvH66tixxt12nXHWRFNdfT
	 TOl8Yq0C0+2dSHOKSigPcIy+mCKqzi5BGF9fJM8AVI4NFEJotnNSP2dzRKyG7/lJGigr+
	 nAnghFfIkxqDkeEfluFHJWrn6bpO62iDO6ZDXragxSBBEWFt5z1NAMPx+QFvw7kzB7g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kVHWlHbt;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4774C606A31A
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 13:52:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=kVHWlHbt
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 251F41F01825;
	Tue, 27 Oct 2026 13:52:01 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793109122;
	bh=6N6gr0n21ZUbaOSGT3hBoEuV0Akrsrxoyqq7KPCJ1Rc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=kVHWlHbtu5kZjKm6ozyVd06hQDoioBfyTmJgeBhD+jzW37atX083oifTsi7wpzRIZ
	 OxLr6nYBt3vu2NGDEPohLRaUUMfsrfb367kCouy/zTP7PikOXzwYYQYD3IEtwNAeaQ
	 gfzcwZnIS+S8fl/BzVj+Fph3Zk8AD+9wHT2CKaHG66mlvPZNBX5IPO/e10Hj7O5kNE
	 L+9//8OGFrhH/b8zTrJbXfabP5HSdWYmMupsgH205qnvhalFEEC3ExPfh4NFUCR5xA
	 ehOfDDRUPfDowkNP+zdRHp0hI8+o1YJ9MFZTZn/3joJ7px0WJ6CGItbvQSysuyRvwt
	 8nqVlZTYJQvWQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 2/2] NFSD: Map NFS_ACLv3 entry IDs through the request's user namespace
Date: Tue, 27 Oct 2026 09:51:58 -0400
Message-ID: <20261027135158.164034-3-cel@kernel.org>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261027135158.164034-1-cel@kernel.org>
References: <20261027135158.164034-1-cel@kernel.org>
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

The NFS_ACLv3 GETACL encoder and SETACL decoder translate each ACL
entry's ID with init_user_ns, while the fattr3 in the same reply goes
through nfsd_user_namespace(). When the transport's credential comes
from a non-initial user namespace, GETACL reports host-global IDs
beside namespace-relative ownership attributes, and SETACL installs
named entries for whichever host-global principals share the wire
IDs. The fs/nfs_common/nfsacl.c helpers these codecs replaced had
the same mismatch.

Translate every entry ID in the request's user namespace. On encode,
use the munged variants so an ID with no mapping in that namespace is
reported as overflowuid, as nfsd3_fill_post_op_attr() already does.
On decode, an ID with no mapping fails the existing uid_valid() and
gid_valid() checks, and the decoder reports the ACL as invalid.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs3acl.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs3acl.c b/fs/nfsd/nfs3acl.c
index 70e685ba1167..b426b3e64df8 100644
--- a/fs/nfsd/nfs3acl.c
+++ b/fs/nfsd/nfs3acl.c
@@ -378,6 +378,7 @@ bool nfs_acl3_secattr_encode(struct xdrgen_aggregate_cursor *c,
 			     struct aclent *out)
 {
 	struct svc_rqst *rqstp = c->ctx;
+	struct user_namespace *userns = nfsd_user_namespace(rqstp);
 	struct GETACL3res_wrapper *resp = rqstp->rq_resp;
 	bool dfacl = c->member_id == NFS_ACL3_SECATTR_DFACLENT;
 	struct posix_acl *acl = dfacl ? resp->acl_default : resp->acl_access;
@@ -404,16 +405,16 @@ bool nfs_acl3_secattr_encode(struct xdrgen_aggregate_cursor *c,
 	out->type = tag | typeflag;
 	switch (tag) {
 	case ACL_USER_OBJ:
-		out->id = from_kuid(&init_user_ns, resp->uid);
+		out->id = from_kuid_munged(userns, resp->uid);
 		break;
 	case ACL_GROUP_OBJ:
-		out->id = from_kgid(&init_user_ns, resp->gid);
+		out->id = from_kgid_munged(userns, resp->gid);
 		break;
 	case ACL_USER:
-		out->id = from_kuid(&init_user_ns, entry->e_uid);
+		out->id = from_kuid_munged(userns, entry->e_uid);
 		break;
 	case ACL_GROUP:
-		out->id = from_kgid(&init_user_ns, entry->e_gid);
+		out->id = from_kgid_munged(userns, entry->e_gid);
 		break;
 	default:
 		/*
@@ -500,6 +501,7 @@ bool nfs_acl3_secattr_decode(struct xdrgen_aggregate_cursor *c,
 			     const struct aclent *in)
 {
 	struct svc_rqst *rqstp = c->ctx;
+	struct user_namespace *userns = nfsd_user_namespace(rqstp);
 	struct SETACL3args_wrapper *argp = rqstp->rq_argp;
 	bool dfacl = c->member_id == NFS_ACL3_SECATTR_DFACLENT;
 	struct posix_acl *acl = dfacl ? argp->acl_default : argp->acl_access;
@@ -528,14 +530,14 @@ bool nfs_acl3_secattr_decode(struct xdrgen_aggregate_cursor *c,
 	switch (entry->e_tag) {
 	case ACL_USER:
 		/* An id with no kernel mapping makes the ACL invalid. */
-		entry->e_uid = make_kuid(&init_user_ns, in->id);
+		entry->e_uid = make_kuid(userns, in->id);
 		if (!uid_valid(entry->e_uid)) {
 			argp->invalid = true;
 			return true;
 		}
 		break;
 	case ACL_GROUP:
-		entry->e_gid = make_kgid(&init_user_ns, in->id);
+		entry->e_gid = make_kgid(userns, in->id);
 		if (!gid_valid(entry->e_gid)) {
 			argp->invalid = true;
 			return true;
-- 
2.56.0

