Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793109122;
	b=GHzGs2B8irWKVmk7NQOweNKs32O/WKwbKCI5e+8RN5iHkFb+WTI1RwXtgV5k2PqAGYwe
	 6WA+tlDvFxqbrgcIz9z0TU5earWGUBtTsnMAr6GYaGnEqReTCNnEkv+n/RlCWbzvqevcH
	 YoDzbPwXlRcjZFF0x8az07Lx0FjlDLr1cxvXBGKZRmXfek289k3h0cx+tFhF0T6po0oDV
	 IpVIHH5SDGsYd42bjyLmZBAaAIpCdrfR2TUVxSqI4h4IjJiIcS/UIZuJDp63I6Qb/Z3WB
	 VcByd7QgdYUTDDm1Se6r41evVMNAOMcNCTNUGWUoq4dLfDpuK+xMmKnKzbvTuHTc9ag==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793109122;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=aNOXvyKD/8TXXpu5EjOKvn26a0UnfOUKicQBaq5loU0=;
	b=MRpQuAgCBtNRiT+a5yxzvyJX27kgdWxutDjDWagQV8BTLezqo6jBhwtLQ47CUBWSwspf
	 k1xIjvMb+wccKXjJpwFI004RU/LekE30qNgxRpA1a7l6Eo2opUPa1ybL9OHS9zQi84C4d
	 6DiZd2DCiTENg1HCyuBuzTAdFvwUNWZ/p8hANRE/mol3Oj8it1U1g/Kp6EIBYWdLRZCYm
	 CwmZQ4K9mfrh7cCQspvAfC6a1G5sBc/5t5Pci5kIvCnl5K4ub7dF9EOWQOc+kn6uNezF+
	 ctxdPANt8G1Cd6oCdKHJPPDbtElbDHxK2Twwl4kK326zOcBjOQuWVZmO2zB/N/V/tCA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=avEBqvpM;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1ADA7606A31A
	for <linux-nfs@vger.kernel.org>; Tue, 27 Oct 2026 13:52:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=avEBqvpM
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E0A7D1F031E0;
	Tue, 27 Oct 2026 13:52:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793109121;
	bh=aNOXvyKD/8TXXpu5EjOKvn26a0UnfOUKicQBaq5loU0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=avEBqvpMIBUVs8IFytG+0hBeq1lvtEJnHDJm/bSt2nYWcGlLcFoLZTv0KjN1alDZf
	 oziIL8MLDradJSGIdX6+Mdym8A9fwaQge2qXvwi6kvp2plrmPJzmF57iOv7u4c35hc
	 CFqbw/uFQAdR+P6mVIwToX/ZsqzQuH9CBSpWmI8BX2Jam81/wN8T97Zl99MbG80/Et
	 N8f2SVEpc0HU4kz9vHbYz9UYPiPNYtxbiceTpuyohOKqF7BeKfIz2REJEMEHj2Oisp
	 2JoZU/NBitx/Yk2MSNt4je4tZLgGlB394NyO7MRUVCWxXTEoMxGNkY4D5L9pZuXtIb
	 v2ZZWDZ7uxJEg==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 1/2] NFSD: Map NFS_ACLv2 entry IDs through the request's user namespace
Date: Tue, 27 Oct 2026 09:51:57 -0400
Message-ID: <20261027135158.164034-2-cel@kernel.org>
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

The NFS_ACLv2 GETACL encoder and SETACL decoder translate each ACL
entry's ID with init_user_ns, while the fattr in the same reply goes
through nfsd_user_namespace(). When the transport's credential comes
from a non-initial user namespace, GETACL reports host-global IDs
beside namespace-relative ownership attributes, and SETACL installs
named entries for whichever host-global principals share the wire
IDs. The fs/nfs_common/nfsacl.c helpers these codecs replaced had
the same mismatch.

Translate every entry ID in the request's user namespace. On encode,
use the munged variants so an ID with no mapping in that namespace is
reported as overflowuid, as nfsd_stat_to_fattr() already does. On
decode, an ID with no mapping fails the existing uid_valid() and
gid_valid() checks, and the decoder reports the ACL as invalid.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfsd/nfs2acl.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index b846624dfe82..8b6e3d717217 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -510,6 +510,7 @@ bool nfs_acl2_secattr_encode(struct xdrgen_aggregate_cursor *c,
 			     struct aclent *out)
 {
 	struct svc_rqst *rqstp = c->ctx;
+	struct user_namespace *userns = nfsd_user_namespace(rqstp);
 	struct GETACL2res_wrapper *resp = rqstp->rq_resp;
 	bool dfacl = c->member_id == NFS_ACL2_SECATTR_DFACLENT;
 	struct posix_acl *acl = dfacl ? resp->acl_default : resp->acl_access;
@@ -536,16 +537,16 @@ bool nfs_acl2_secattr_encode(struct xdrgen_aggregate_cursor *c,
 	out->type = tag | typeflag;
 	switch (tag) {
 	case ACL_USER_OBJ:
-		out->id = from_kuid(&init_user_ns, resp->stat.uid);
+		out->id = from_kuid_munged(userns, resp->stat.uid);
 		break;
 	case ACL_GROUP_OBJ:
-		out->id = from_kgid(&init_user_ns, resp->stat.gid);
+		out->id = from_kgid_munged(userns, resp->stat.gid);
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
@@ -632,6 +633,7 @@ bool nfs_acl2_secattr_decode(struct xdrgen_aggregate_cursor *c,
 			     const struct aclent *in)
 {
 	struct svc_rqst *rqstp = c->ctx;
+	struct user_namespace *userns = nfsd_user_namespace(rqstp);
 	struct SETACL2args_wrapper *argp = rqstp->rq_argp;
 	bool dfacl = c->member_id == NFS_ACL2_SECATTR_DFACLENT;
 	struct posix_acl *acl = dfacl ? argp->acl_default : argp->acl_access;
@@ -651,14 +653,14 @@ bool nfs_acl2_secattr_decode(struct xdrgen_aggregate_cursor *c,
 	switch (in->type & ~NA_ACL_DEFAULT) {
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

