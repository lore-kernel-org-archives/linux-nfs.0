Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792677235;
	b=OwXsq33zJqMhAvRYqrsHTO50VOoAfWaIl5noIHz6GiG5jh37MQ6Y9PZoRRol+VzA25Gl
	 qAOazZL6SrQ4QNIQ80C2z4Bova070svSNn5aaaJnzbIFaTGZaDpjNwD5T7LjSzF/cO/xM
	 bYneFT+fShpOyXg7ugrssOUC1b73GsWyAxn64h9Ulu/l57dy5NnYvZBvpoaRCIiQLmTwV
	 1wWO8SfOaRlD8XkKm3bQJeBj9RjqrjXnWTFSV3dqQngJhqPISm+BoxTUa5gj0cT84CHOr
	 dYocVSFZdZo1nFPh7oiJXxEVPGgxlFbjAx5f2TpvKakRZM55XpfvD5UfWQ1NfWwdXZw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792677235;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Transfer-Encoding;
	bh=7oGrY3/2E1AS6Wdr5LoXyjXOAa+wsWsYdMQyyHvYpUc=;
	b=BwySpeQTzU0vLAPhcnY+mN8P0eOMf6HCw4+yLbiTs26Grnz40RRT6oNRXdnCgluECM+y
	 +4D1KX3SDL0Xt6ZRTq2D88Jx1g3DnqoXGr3BnDnO1TPk3LfBGszRkSACnHNo+YucwGLi7
	 /TOslcbi91IaZz6qGsED/jwIuN4Dc2RYKCyBDhzCaW+GGNJuyC5wosEMXM3ciH9o/VlTa
	 /R2A0iKh8xjBGBjYda1PMPC9c3pTTmscNGg3mPfeP4S49FThP5ltn3ohxBLnRMCHIeLZw
	 G3x85CT5x19QT2SQ8k/5O22MSNLk/03+PAybkNWKNkpR/M1mUVLdgy+SfNMRcVjPY3w==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XNEnbffH;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3180F60A263B
	for <linux-nfs@vger.kernel.org>; Thu, 22 Oct 2026 13:53:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=XNEnbffH
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 75F5B1F000D2;
	Thu, 22 Oct 2026 13:53:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792677235;
	bh=7oGrY3/2E1AS6Wdr5LoXyjXOAa+wsWsYdMQyyHvYpUc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=XNEnbffHjOGv79knJilEzsMyR/MDec+Fm3tljRfShVfpO80LLh4MVkZBspNEiDmgY
	 vl2BR5Se5qbxF6ThKXBP53ETn4nem3yI9YH3i3qoVFQQy76FGnE96SJ8qrqP/LEXHg
	 NOoyzIfP/F8h0cRE4hMEm/Wea/zTP9cGaHDAgYPMcnW3LzIDNMMGFwfCZEjM0+PFR5
	 iN94q6sKF9ivgGLVpoOQkwfF0vo1NkvHHLjOTHIZ73HN1aT69E71p4gojXQPqnU638
	 QpJAOruLs6xosfB3UDzSPno34iJyntVXbPluWG2tu9mjxBrp/iwOeuT7oKzJ32cQCs
	 K06CuMHPa1+WQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1 12/17] NFSD: Implement NFS-ACL v2 ACL encoding and decoding with xdrgen
Date: Thu, 22 Oct 2026 09:53:36 -0400
Message-ID: <20261022135341.14265-13-cel@kernel.org>
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

The NFS-ACL v2 GETACL result encoder and SETACL argument decoder
cannot be generated the way the other procedures' codecs are: the
wire secattr is a Solaris projection of the kernel's struct
posix_acl, and the per-entry transformation between them -- tag and
id mapping, the canonical four-entry expansion described in
draft-ietf-nfsv4-nfs-acl Section 3.4.4.2, and counts gated by the
request mask -- is application logic that xdrgen cannot synthesize.
Keeping those two codecs hand-rolled would force the generated
NFSv2 types they call, fattr and fhandle, to keep external linkage,
and those symbols would collide at link time with the public
definitions that nfs2xdr_gen.c already emits for NFSv2 proper.

Supply the nfsd side of xdrgen's hook-driven aggregate codec
mechanism. "pragma aggregate" markers on secattr's two aclent<>
members select the streaming codec, whose generated framing owns
the wire representation and drives per-element application hooks. The
hooks hold the posix_acl logic factored from
nfs_stream_encode_acl() and nfs_stream_decode_acl(); both arrays
share one hook set, with the cursor's member_id distinguishing the
access list from the default list. Wrapper structures pair each
generated argument or result type with the legacy application state
(svc_fh, posix_acl pointers, kstat), placing the generated type at
offset zero so rq_argp or rq_resp addresses both the generated type
the codec fills and the wrapper the hooks read. The hooks reach
that wrapper by way of the svc_rqst, which svcxdr_init_decode() and
svcxdr_init_encode() leave in the xdr_stream's application-private
pointer.

On decode, the begin hook validates the declared count and the
request mask, allocates the posix_acl at its known size, and
publishes it into the argument wrapper before any fallible
per-entry decode runs, so a mid-list failure leaves the ACL
reachable by pc_release rather than leaked. A zero-length published
default list stays NULL, which set_posix_acl() treats as ACL
removal.

A well-formed request that is nonetheless invalid -- an undefined
request mask bit, an empty access ACL, a perm bit outside rwx, an
undefined entry type, or more entries than NFS_ACL_MAX_ENTRIES --
instead marks the argument wrapper and lets the decode succeed, so
nfsacld_proc_setacl() can report ACL2ERR_INVAL rather than
GARBAGE_ARGS (draft-ietf-nfsv4-nfs-acl Section 3.4.4.2). The
pre-conversion decoder rejected most of these cases with
GARBAGE_ARGS. It accepted an empty access ACL as a request to
remove the object's access ACL, an operation the protocol does not
define. It also cleared undefined perm bits from the mask entry, an
accommodation for Solaris clients that the draft does not carry,
and it did not check the perm field of a user or group entry at
all. Reporting ACL2ERR_INVAL is a deliberate, minor change to the
SETACL wire behavior.

Because the containing codecs are fully generated, the NFSv2 types
the ACL specification re-declares stay static in nfs_acl2xdr_gen.c,
and no public pragma is needed.

Subsequent patches convert the GETACL and SETACL procedures to the
generated codecs.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 Documentation/sunrpc/xdr/nfs_acl2.x |   2 +
 fs/nfsd/nfs2acl.c                   | 246 ++++++++++++++++++++++++++++
 fs/nfsd/nfs_acl2xdr_gen.c           | 136 ++++++++++++---
 fs/nfsd/nfs_acl2xdr_gen.h           |  12 ++
 4 files changed, 372 insertions(+), 24 deletions(-)

diff --git a/Documentation/sunrpc/xdr/nfs_acl2.x b/Documentation/sunrpc/xdr/nfs_acl2.x
index 8ec8bffbe77b..25c0b54ece1a 100644
--- a/Documentation/sunrpc/xdr/nfs_acl2.x
+++ b/Documentation/sunrpc/xdr/nfs_acl2.x
@@ -91,6 +91,8 @@ struct secattr {
     int dfaclcnt;
     aclent dfaclent<NFS_ACL_MAX_ENTRIES>;
 };
+pragma aggregate secattr aclent;
+pragma aggregate secattr dfaclent;
 
 /*
  * The values for the mask element of the secattr struct as well
diff --git a/fs/nfsd/nfs2acl.c b/fs/nfsd/nfs2acl.c
index 0698c9dc85dd..13e7415aa97b 100644
--- a/fs/nfsd/nfs2acl.c
+++ b/fs/nfsd/nfs2acl.c
@@ -31,6 +31,45 @@ struct nfsd_attrstat {
 	struct kstat		stat;
 };
 
+/*
+ * Wrapper structures combine xdrgen types with legacy structures.
+ * The xdrgen field must be first so the structure can be cast
+ * to its XDR type for the RPC dispatch layer.
+ */
+
+struct GETACL2args_wrapper {
+	struct GETACL2args	xdrgen;
+	struct svc_fh		fh;
+};
+
+static_assert(offsetof(struct GETACL2args_wrapper, xdrgen) == 0);
+
+struct GETACL2res_wrapper {
+	struct GETACL2res	xdrgen;
+	int			mask;
+	struct posix_acl	*acl_access;
+	struct posix_acl	*acl_default;
+	struct kstat		stat;
+};
+
+static_assert(offsetof(struct GETACL2res_wrapper, xdrgen) == 0);
+
+struct SETACL2args_wrapper {
+	struct SETACL2args	xdrgen;
+	struct svc_fh		fh;
+	struct posix_acl	*acl_access;
+	struct posix_acl	*acl_default;
+	/*
+	 * Set when the wire ACL is well-formed XDR but semantically
+	 * invalid. The decoder accepts the request so that
+	 * nfsacld_proc_setacl can return ACL2ERR_INVAL rather than RPC
+	 * GARBAGE_ARGS. See draft-ietf-nfsv4-nfs-acl Section 3.4.4.2.
+	 */
+	bool			invalid;
+};
+
+static_assert(offsetof(struct SETACL2args_wrapper, xdrgen) == 0);
+
 struct nfsd3_getaclargs {
 	struct svc_fh		fh;
 	__u32			mask;
@@ -163,6 +202,19 @@ static __be32 nfsacld_map_status(__be32 status)
 	return status;
 }
 
+/*
+ * A minimal (three-entry) ACL travels as four wire entries: the
+ * POSIX entries plus a synthesized NA_CLASS_OBJ mask. The wire
+ * element count is thus max(a_count, 4) when the ACL has at least
+ * three entries, and zero otherwise. An ACL with fewer than three
+ * entries has no minimal set to expand, so it travels as empty.
+ * See draft-ietf-nfsv4-nfs-acl Section 3.4.4.2.
+ */
+static u32 nfsacld_acl_entries(const struct posix_acl *acl)
+{
+	return (acl && acl->a_count >= 3) ? max_t(int, acl->a_count, 4) : 0;
+}
+
 /**
  * nfsacld_proc_null - NULL: Do nothing
  * @rqstp: RPC transaction context
@@ -348,6 +400,200 @@ static __be32 nfsacld_proc_access(struct svc_rqst *rqstp)
 	return rpc_success;
 }
 
+/*
+ * Aggregate codec hooks for the generated secattr codec.
+ *
+ * The generated codec owns the wire framing and drives these hooks
+ * once per element; the hooks hold all posix_acl application logic. The
+ * application context (@c->ctx) is the svc_rqst, bound to the stream by
+ * svcxdr_init_{decode,encode}(); each hook reaches the proc's arg or
+ * result wrapper through rq_{argp,resp}.
+ * The cursor's member_id selects the member: it is
+ * NFS_ACL2_SECATTR_ACLENT or NFS_ACL2_SECATTR_DFACLENT.
+ */
+
+/* GETACL reply: stream the wire entries out of the source posix_acl. */
+
+bool nfs_acl2_secattr_encode_begin(struct xdrgen_aggregate_cursor *c)
+{
+	struct svc_rqst *rqstp = c->ctx;
+	struct GETACL2res_wrapper *resp = rqstp->rq_resp;
+	bool dfacl = c->member_id == NFS_ACL2_SECATTR_DFACLENT;
+	struct posix_acl *acl = dfacl ? resp->acl_default : resp->acl_access;
+	int gate = dfacl ? (resp->mask & NA_DFACL) : (resp->mask & NA_ACL);
+
+	c->count = gate ? nfsacld_acl_entries(acl) : 0;
+	return true;
+}
+
+bool nfs_acl2_secattr_encode(struct xdrgen_aggregate_cursor *c,
+			     struct aclent *out)
+{
+	struct svc_rqst *rqstp = c->ctx;
+	struct GETACL2res_wrapper *resp = rqstp->rq_resp;
+	bool dfacl = c->member_id == NFS_ACL2_SECATTR_DFACLENT;
+	struct posix_acl *acl = dfacl ? resp->acl_default : resp->acl_access;
+	int typeflag = dfacl ? NA_ACL_DEFAULT : 0;
+	const struct posix_acl_entry *entry;
+	int tag;
+
+	/*
+	 * A three-entry ACL expands to four wire entries in ascending
+	 * type order (USER_OBJ, GROUP_OBJ, a NA_CLASS_OBJ mask cloned
+	 * from GROUP_OBJ, OTHER). Some receivers depend on this ordering.
+	 * See draft-ietf-nfsv4-nfs-acl Section 3.4.4.2.
+	 */
+	if (acl->a_count == 3) {
+		static const u8 map[4] = { 0, 1, 1, 2 };
+
+		entry = &acl->a_entries[map[c->index]];
+		tag = (c->index == 2) ? ACL_MASK : entry->e_tag;
+	} else {
+		entry = &acl->a_entries[c->index];
+		tag = entry->e_tag;
+	}
+
+	out->type = tag | typeflag;
+	switch (tag) {
+	case ACL_USER_OBJ:
+		out->id = from_kuid(&init_user_ns, resp->stat.uid);
+		break;
+	case ACL_GROUP_OBJ:
+		out->id = from_kgid(&init_user_ns, resp->stat.gid);
+		break;
+	case ACL_USER:
+		out->id = from_kuid(&init_user_ns, entry->e_uid);
+		break;
+	case ACL_GROUP:
+		out->id = from_kgid(&init_user_ns, entry->e_gid);
+		break;
+	default:
+		/*
+		 * The id field is undefined for these entry types;
+		 * emit zero per draft-ietf-nfsv4-nfs-acl Section 3.4.4.2.
+		 */
+		out->id = 0;
+		break;
+	}
+	out->perm = entry->e_perm & (ACL_READ | ACL_WRITE | ACL_EXECUTE);
+	return true;
+}
+
+bool nfs_acl2_secattr_encode_end(struct xdrgen_aggregate_cursor *c, bool ok)
+{
+	return true;
+}
+
+/* SETACL args: consume the decoded wire entries into the target posix_acl. */
+
+bool nfs_acl2_secattr_decode_begin(struct xdrgen_aggregate_cursor *c)
+{
+	struct svc_rqst *rqstp = c->ctx;
+	struct SETACL2args_wrapper *argp = rqstp->rq_argp;
+	bool dfacl = c->member_id == NFS_ACL2_SECATTR_DFACLENT;
+	struct posix_acl **pacl = dfacl ? &argp->acl_default : &argp->acl_access;
+	u32 mask = argp->xdrgen.acl.mask;
+	u32 declared = dfacl ? (u32)argp->xdrgen.acl.dfaclcnt :
+			       (u32)argp->xdrgen.acl.aclcnt;
+	int gate = dfacl ? (mask & NA_DFACL) : (mask & NA_ACL);
+
+	/* Already rejected: consume the list. */
+	if (argp->invalid)
+		return true;
+	/* The access list is decoded first, so the mask is checked once. */
+	if (!dfacl && (mask & ~NFS_ACL_MASK)) {
+		argp->invalid = true;
+		return true;
+	}
+	/* Too many ACEs is an invalid ACL, not a malformed request. */
+	if (declared > NFS_ACL_MAX_ENTRIES) {
+		argp->invalid = true;
+		return true;
+	}
+
+	if (gate) {
+		/* A published list's declared count must equal its length. */
+		if (c->count != declared)
+			return false;
+		if (!dfacl && !c->count) {
+			argp->invalid = true;
+			return true;
+		}
+		/* An empty default list publishes NULL: default ACL removal. */
+		if (c->count) {
+			*pacl = posix_acl_alloc(c->count, GFP_KERNEL);
+			if (!*pacl)
+				return false;
+		}
+	} else if (c->count > declared) {
+		return false;
+	}
+	return true;
+}
+
+bool nfs_acl2_secattr_decode(struct xdrgen_aggregate_cursor *c,
+			     const struct aclent *in)
+{
+	struct svc_rqst *rqstp = c->ctx;
+	struct SETACL2args_wrapper *argp = rqstp->rq_argp;
+	bool dfacl = c->member_id == NFS_ACL2_SECATTR_DFACLENT;
+	struct posix_acl *acl = dfacl ? argp->acl_default : argp->acl_access;
+	struct posix_acl_entry *entry;
+
+	/* Already rejected, or list gated out by mask: consume it. */
+	if (argp->invalid || !acl)
+		return true;
+
+	/* A perm bit outside rwx makes the ACL invalid. */
+	if (in->perm & ~(ACL_READ | ACL_WRITE | ACL_EXECUTE)) {
+		argp->invalid = true;
+		return true;
+	}
+
+	entry = &acl->a_entries[c->index];
+	switch (in->type & ~NA_ACL_DEFAULT) {
+	case ACL_USER:
+		entry->e_uid = make_kuid(&init_user_ns, in->id);
+		if (!uid_valid(entry->e_uid))
+			return false;
+		break;
+	case ACL_GROUP:
+		entry->e_gid = make_kgid(&init_user_ns, in->id);
+		if (!gid_valid(entry->e_gid))
+			return false;
+		break;
+	case ACL_USER_OBJ:
+	case ACL_GROUP_OBJ:
+	case ACL_OTHER:
+	case ACL_MASK:
+		break;
+	default:
+		/* An undefined entry type makes the ACL invalid. */
+		argp->invalid = true;
+		return true;
+	}
+	entry->e_tag = in->type & ~NA_ACL_DEFAULT;
+	entry->e_perm = in->perm;
+
+	return true;
+}
+
+bool nfs_acl2_secattr_decode_end(struct xdrgen_aggregate_cursor *c, bool ok)
+{
+	struct svc_rqst *rqstp = c->ctx;
+	struct SETACL2args_wrapper *argp = rqstp->rq_argp;
+	bool dfacl = c->member_id == NFS_ACL2_SECATTR_DFACLENT;
+	struct posix_acl *acl = dfacl ? argp->acl_default : argp->acl_access;
+
+	/*
+	 * On failure the published ACL stays reachable through the arg
+	 * wrapper and is freed by pc_release; nothing to do here.
+	 */
+	if (!ok || argp->invalid)
+		return true;
+	return posix_acl_from_nfsacl(acl) == 0;
+}
+
 /*
  * XDR decode functions
  */
diff --git a/fs/nfsd/nfs_acl2xdr_gen.c b/fs/nfsd/nfs_acl2xdr_gen.c
index 59765733bd49..f6e506970d73 100644
--- a/fs/nfsd/nfs_acl2xdr_gen.c
+++ b/fs/nfsd/nfs_acl2xdr_gen.c
@@ -38,22 +38,66 @@ xdrgen_decode_secattr(struct xdr_stream *xdr, struct secattr *ptr)
 		return false;
 	if (!xdrgen_decode_int(xdr, &ptr->aclcnt))
 		return false;
-	if (xdr_stream_decode_u32(xdr, &ptr->aclent.count) < 0)
-		return false;
-	if (ptr->aclent.count > NFS_ACL_MAX_ENTRIES)
-		return false;
-	for (u32 i = 0; i < ptr->aclent.count; i++)
-		if (!xdrgen_decode_aclent(xdr, &ptr->aclent.element[i]))
+	{
+		struct xdrgen_aggregate_cursor cursor = {
+			.xdr = xdr,
+			.member_id = NFS_ACL2_SECATTR_ACLENT,
+			.ctx = xdr->xdrgen_ctx,
+		};
+		bool ok = true;
+
+		if (xdr_stream_decode_u32(xdr, &cursor.count) < 0)
 			return false;
+		if (cursor.count > NFS_ACL_MAX_ENTRIES)
+			return false;
+		if (!nfs_acl2_secattr_decode_begin(&cursor))
+			return false;
+		for (cursor.index = 0; cursor.index < cursor.count; cursor.index++) {
+			struct aclent element = {};
+
+			if (!xdrgen_decode_aclent(xdr, &element)) {
+				ok = false;
+				break;
+			}
+			if (!nfs_acl2_secattr_decode(&cursor, &element)) {
+				ok = false;
+				break;
+			}
+		}
+		if (!nfs_acl2_secattr_decode_end(&cursor, ok) || !ok)
+			return false;
+	}
 	if (!xdrgen_decode_int(xdr, &ptr->dfaclcnt))
 		return false;
-	if (xdr_stream_decode_u32(xdr, &ptr->dfaclent.count) < 0)
-		return false;
-	if (ptr->dfaclent.count > NFS_ACL_MAX_ENTRIES)
-		return false;
-	for (u32 i = 0; i < ptr->dfaclent.count; i++)
-		if (!xdrgen_decode_aclent(xdr, &ptr->dfaclent.element[i]))
+	{
+		struct xdrgen_aggregate_cursor cursor = {
+			.xdr = xdr,
+			.member_id = NFS_ACL2_SECATTR_DFACLENT,
+			.ctx = xdr->xdrgen_ctx,
+		};
+		bool ok = true;
+
+		if (xdr_stream_decode_u32(xdr, &cursor.count) < 0)
 			return false;
+		if (cursor.count > NFS_ACL_MAX_ENTRIES)
+			return false;
+		if (!nfs_acl2_secattr_decode_begin(&cursor))
+			return false;
+		for (cursor.index = 0; cursor.index < cursor.count; cursor.index++) {
+			struct aclent element = {};
+
+			if (!xdrgen_decode_aclent(xdr, &element)) {
+				ok = false;
+				break;
+			}
+			if (!nfs_acl2_secattr_decode(&cursor, &element)) {
+				ok = false;
+				break;
+			}
+		}
+		if (!nfs_acl2_secattr_decode_end(&cursor, ok) || !ok)
+			return false;
+	}
 	return true;
 }
 
@@ -445,22 +489,66 @@ xdrgen_encode_secattr(struct xdr_stream *xdr, const struct secattr *value)
 		return false;
 	if (!xdrgen_encode_int(xdr, value->aclcnt))
 		return false;
-	if (value->aclent.count > NFS_ACL_MAX_ENTRIES)
-		return false;
-	if (xdr_stream_encode_u32(xdr, value->aclent.count) != XDR_UNIT)
-		return false;
-	for (u32 i = 0; i < value->aclent.count; i++)
-		if (!xdrgen_encode_aclent(xdr, &value->aclent.element[i]))
+	{
+		struct xdrgen_aggregate_cursor cursor = {
+			.xdr = xdr,
+			.member_id = NFS_ACL2_SECATTR_ACLENT,
+			.ctx = xdr->xdrgen_ctx,
+		};
+		bool ok = true;
+
+		if (!nfs_acl2_secattr_encode_begin(&cursor))
 			return false;
+		if (cursor.count > NFS_ACL_MAX_ENTRIES)
+			ok = false;
+		if (ok && xdr_stream_encode_u32(xdr, cursor.count) != XDR_UNIT)
+			ok = false;
+		for (cursor.index = 0; ok && cursor.index < cursor.count; cursor.index++) {
+			struct aclent element = {};
+
+			if (!nfs_acl2_secattr_encode(&cursor, &element)) {
+				ok = false;
+				break;
+			}
+			if (!xdrgen_encode_aclent(xdr, &element)) {
+				ok = false;
+				break;
+			}
+		}
+		if (!nfs_acl2_secattr_encode_end(&cursor, ok) || !ok)
+			return false;
+	}
 	if (!xdrgen_encode_int(xdr, value->dfaclcnt))
 		return false;
-	if (value->dfaclent.count > NFS_ACL_MAX_ENTRIES)
-		return false;
-	if (xdr_stream_encode_u32(xdr, value->dfaclent.count) != XDR_UNIT)
-		return false;
-	for (u32 i = 0; i < value->dfaclent.count; i++)
-		if (!xdrgen_encode_aclent(xdr, &value->dfaclent.element[i]))
+	{
+		struct xdrgen_aggregate_cursor cursor = {
+			.xdr = xdr,
+			.member_id = NFS_ACL2_SECATTR_DFACLENT,
+			.ctx = xdr->xdrgen_ctx,
+		};
+		bool ok = true;
+
+		if (!nfs_acl2_secattr_encode_begin(&cursor))
 			return false;
+		if (cursor.count > NFS_ACL_MAX_ENTRIES)
+			ok = false;
+		if (ok && xdr_stream_encode_u32(xdr, cursor.count) != XDR_UNIT)
+			ok = false;
+		for (cursor.index = 0; ok && cursor.index < cursor.count; cursor.index++) {
+			struct aclent element = {};
+
+			if (!nfs_acl2_secattr_encode(&cursor, &element)) {
+				ok = false;
+				break;
+			}
+			if (!xdrgen_encode_aclent(xdr, &element)) {
+				ok = false;
+				break;
+			}
+		}
+		if (!nfs_acl2_secattr_encode_end(&cursor, ok) || !ok)
+			return false;
+	}
 	return true;
 }
 
diff --git a/fs/nfsd/nfs_acl2xdr_gen.h b/fs/nfsd/nfs_acl2xdr_gen.h
index a650fb7a3c83..b7fc4f23ffc5 100644
--- a/fs/nfsd/nfs_acl2xdr_gen.h
+++ b/fs/nfsd/nfs_acl2xdr_gen.h
@@ -13,6 +13,18 @@
 #include <linux/sunrpc/xdrgen/_builtins.h>
 #include <linux/sunrpc/xdrgen/nfs_acl2.h>
 
+enum {
+	NFS_ACL2_SECATTR_ACLENT,
+	NFS_ACL2_SECATTR_DFACLENT,
+};
+
+bool nfs_acl2_secattr_encode_begin(struct xdrgen_aggregate_cursor *c);
+bool nfs_acl2_secattr_encode(struct xdrgen_aggregate_cursor *c, struct aclent *out);
+bool nfs_acl2_secattr_encode_end(struct xdrgen_aggregate_cursor *c, bool ok);
+bool nfs_acl2_secattr_decode_begin(struct xdrgen_aggregate_cursor *c);
+bool nfs_acl2_secattr_decode(struct xdrgen_aggregate_cursor *c, const struct aclent *in);
+bool nfs_acl2_secattr_decode_end(struct xdrgen_aggregate_cursor *c, bool ok);
+
 bool nfs_acl_svc_decode_GETACL2args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs_acl_svc_decode_SETACL2args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
 bool nfs_acl_svc_decode_GETATTR2args(struct svc_rqst *rqstp, struct xdr_stream *xdr);
-- 
2.56.0

