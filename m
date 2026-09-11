Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 43F874A3D4C
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 16:25:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789143945; cv=none; b=Dftv/XTg+Ft/PzfoY42DRxPCpyHWi4TCvy+bfE+yNsDaHJ9YEcB9Ktv+ZPCGkLv0kgAp8LdVUX721tvxjbXm5ebFJx/4zOdQtTOEgtGQZOLWTQP822gaI7rv+lTc3GUtTaThiWbgM00Vld1xRFZECPjYqFvfbNsozidC937VIN8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789143945; c=relaxed/simple;
	bh=9i4Bx+gK+N5222rrMVi3DYBTRUojqXUmJ41JQaD2WZA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=NQmiPHj38lM4jMMFAEFCm1vo1GWRTc4MPO1aJv8SsIeGubGz3F/qQhIBlosy6pvpgz4AAWgU7LwW5+zvXlQtXNy31VtIOE8mE6rDFEMwyRvvTQf+QZSbDh3rKa9n1VTi068s6dhp3ati+IkEf3pwSj2EoClw4/NUlvhPnXwWSUM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Kf2ysepG; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Kf2ysepG"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BF6C21F0089B;
	Fri, 11 Sep 2026 16:25:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789143944;
	bh=32lah35eIJr6G1+1lDSbbuGf/dV7Y5+x0suuoDSqqyg=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Kf2ysepGPjAUEja1C6L0sbab0cWBnnogzz3o2Rv2gyHDE13Df9rsrxrS9BHmUey1B
	 JaQGnru4NeZOqEoRPeD4CK//a2LhCnZ3EHuNCMWFoNQcfR8xslLczcL7HXHNkNoi8Q
	 GGn++N9m+cjWJq/i+PqQj3lqpX+Dbog7m4HLp3vLElVVHrA05RiCTs+vTt9Fb/o7E2
	 0KGeWZkDQL1hpdqv0dy/UeD45Jv0YAYaqm8hFPMcpxH5w459x9HBb6Y51zrG/S8bnB
	 Q9v5Y3aeg2LetgHUIseDwWgMbIPuGK89aIhxDgG4Ld7F2u5Xz1/wzs4tWPXLZEGXjZ
	 Ulj/SpViOoxQQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 11 Sep 2026 12:25:29 -0400
Subject: [PATCH nfs-utils v2 04/10] mountd: don't leak the parent export's
 fsid onto crossmnt submounts
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260911-nl-crossmnt-v2-4-f4d869951c5e@kernel.org>
References: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
In-Reply-To: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5939; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=9i4Bx+gK+N5222rrMVi3DYBTRUojqXUmJ41JQaD2WZA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqpCuDyVFQkRwt4P5Sabv92zAYn8T99RiEGIgnx
 PgJR+IEiXiJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqQrgwAKCRAADmhBGVaC
 FcbmEACDQfF2L8M6AbsWhpOWf843/PFw0vOhn1JApWk/wb39qJcBhHGN1D8GTzBhh4yaau1Wbko
 upI3NbU/IfcjhY5BjVbHEh8XdO5KQghSUUdFW3zB3LphQcZzIwYp7Yj3QILDLxXtpULJR11KAA9
 OU2g7ajrnzHeJvbkOSPtSHxNwAPfQfFIiFPAja2QPmZurpowiTvoCRnds/4HDlBF45N5HWUQB5O
 SeRNqrnqsCXdyvoGlYyWDaGTD7xCVw9v7HKbEw8lvwUSzQvXLT4LYGMZUc2h4fbFc1kMnUD1CIk
 1hqMRsVvZ7jW4Mlp8pfruUChidiYg6B2uMZEvOwNQLmcXgrc9NXXUu/7xgmossa7+PRmB/O0Ag6
 87tNHVNSxGDG4pBd00exeiKOLGMA3qw2p7XN7serdrStuOLwRMQwEqzla9q88YJxvJMKyuRvLHx
 9eqVH03afZSMn08Hkf+CJUa1FF9Fu+xaiKs5fZaem8GkeeirXlNiVGT6s3FbyPFvIORp7KqR/pY
 d9akXlE5qO+CQOln1esF68pnznWDpJ5zE3z45s2FqiKwyTm4I8xMxLedy9c673FgdJ6gJMT8o3m
 dNXtCbQLa11IziF1tKFzL9k2DGKMKtf4bavB4cbv3YnRsLeeR00rpvg/S/qrZS3q6Y7P7JaDMJA
 dg5X0+/rm615Ewg==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

nfsd_nl_add_export() sent e_flags and e_fsid straight from the parent
exportent, unlike dump_to_cache() which strips NFSEXP_FSID (and picks a
path-derived uuid) when the upcall path is a submount below the exported
one.

v4root forces "/" to fsid=0, so exporting "/" with crossmnt handed every
submount fsid=0 as well.  Both exports then encode the same fsid, the
submount's filehandles decode back to "/", and the client sees

  NFS: server X error: fileid changed
  fsid 0:150: expected fileid 0x2, got 0x100

followed by ESTALE.  Re-export via fsidnum was missing for the same
reason, so a re-exported submount got the parent's fsid too.

Use export_attrs_build() for the flags, fsid and uuid, mask the per-
flavor secinfo flags to match (the kernel rejects the entry otherwise),
and fall back to a negative entry when the export cannot be resolved.
While here, honour the export's own e_ttl on positive entries.

Two consequences worth noting.  A crossmnt submount under an fsid=
parent now gets its own filehandles, so clients holding the old
(aliased) ones see ESTALE once - that aliasing was the bug.  And a
crossmnt submount on a filesystem with no blkid uuid and no statfs fsid
(tmpfs, say) now has neither fsid= nor uuid, so check_export() refuses
it; the preceding patch turns that into a negative entry instead of a
failed batch, so this one depends on it.

Reported-by: Mantas Mikulėnas <grawity@gmail.com>
Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 support/export/cache.c | 53 +++++++++++++++++++++++++++++++-------------------
 1 file changed, 33 insertions(+), 20 deletions(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index 9be6659cc3f2..952adf25eb72 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -1500,7 +1500,8 @@ static int nfsd_nl_add_fsloc(struct nl_msg *msg, struct exportent *ep)
 	return 0;
 }
 
-static int nfsd_nl_add_secinfo(struct nl_msg *msg, struct exportent *ep)
+static int nfsd_nl_add_secinfo(struct nl_msg *msg, struct exportent *ep,
+			       struct export_attrs *ea)
 {
 	struct sec_entry *p;
 
@@ -1520,7 +1521,7 @@ static int nfsd_nl_add_secinfo(struct nl_msg *msg, struct exportent *ep)
 		if (nla_put_u32(msg, NFSD_A_AUTH_FLAVOR_PSEUDOFLAVOR,
 				p->flav->fnum) < 0 ||
 		    nla_put_u32(msg, NFSD_A_AUTH_FLAVOR_FLAGS,
-				p->flags) < 0)
+				(p->flags | ea->sec_extra) & ea->sec_mask) < 0)
 			return -1;
 		nla_nest_end(msg, sec);
 	}
@@ -1545,15 +1546,26 @@ static int nfsd_nl_add_xprtsec(struct nl_msg *msg, struct exportent *ep)
 	return 0;
 }
 
+/*
+ * Add one svc_export response.  @ea must be the attributes computed by
+ * export_attrs_build() for (@path, @exp), and is ignored when @exp is NULL.
+ * The only failure mode is a full message, so the caller can retry with a
+ * fresh one.
+ */
 static int nfsd_nl_add_export(struct nl_msg *msg, char *domain, char *path,
-			 struct exportent *exp, int ttl)
+			 struct exportent *exp, struct export_attrs *ea,
+			 int ttl)
 {
 	struct nlattr *nest;
 	time_t now = time(0);
-	char u[16];
+	uint64_t expiry;
 
+	/* A positive entry carries the export's own ttl */
+	if (exp)
+		ttl = (int)exp->e_ttl;
 	if (ttl <= 1)
 		ttl = default_ttl;
+	expiry = now + ttl;
 
 	nest = nla_nest_start(msg, NFSD_A_SVC_EXPORT_REQS_REQUESTS);
 	if (!nest)
@@ -1561,7 +1573,7 @@ static int nfsd_nl_add_export(struct nl_msg *msg, char *domain, char *path,
 
 	if (nla_put_string(msg, NFSD_A_SVC_EXPORT_CLIENT, domain) < 0 ||
 	    nla_put_string(msg, NFSD_A_SVC_EXPORT_PATH, path) < 0 ||
-	    nla_put_u64(msg, NFSD_A_SVC_EXPORT_EXPIRY, now + ttl) < 0)
+	    nla_put_u64(msg, NFSD_A_SVC_EXPORT_EXPIRY, expiry) < 0)
 		goto nla_failure;
 
 	if (!exp) {
@@ -1573,26 +1585,19 @@ static int nfsd_nl_add_export(struct nl_msg *msg, char *domain, char *path,
 		    nla_put_u32(msg, NFSD_A_SVC_EXPORT_ANON_GID,
 				exp->e_anongid) < 0 ||
 		    nla_put_u32(msg, NFSD_A_SVC_EXPORT_FLAGS,
-				exp->e_flags) < 0 ||
+				ea->flags) < 0 ||
 		    nla_put_s32(msg, NFSD_A_SVC_EXPORT_FSID,
-				exp->e_fsid) < 0)
+				ea->fsidnum) < 0)
 			goto nla_failure;
 
 		if (nfsd_nl_add_fsloc(msg, exp))
 			goto nla_failure;
 
-		if (exp->e_uuid) {
-			get_uuid(exp->e_uuid, 16, u);
-			if (nla_put(msg, NFSD_A_SVC_EXPORT_UUID,
-				    16, u) < 0)
-				goto nla_failure;
-		} else if (uuid_by_path(path, 0, 16, u)) {
-			if (nla_put(msg, NFSD_A_SVC_EXPORT_UUID,
-				    16, u) < 0)
-				goto nla_failure;
-		}
+		if (ea->have_uuid &&
+		    nla_put(msg, NFSD_A_SVC_EXPORT_UUID, 16, ea->uuid) < 0)
+			goto nla_failure;
 
-		if (nfsd_nl_add_secinfo(msg, exp))
+		if (nfsd_nl_add_secinfo(msg, exp, ea))
 			goto nla_failure;
 
 		if (nfsd_nl_add_xprtsec(msg, exp))
@@ -1713,6 +1718,7 @@ static enum export_result nl_add_export_req(struct nl_msg *msg, char *dom,
 	nfs_export *found = NULL;
 	struct exportent *epp = NULL;
 	struct exportent *junction = NULL;
+	struct export_attrs ea = {};
 	enum export_result res;
 	int ttl = 0;
 
@@ -1759,7 +1765,14 @@ static enum export_result nl_add_export_req(struct nl_msg *msg, char *dom,
 		}
 	}
 
-	if (nfsd_nl_add_export(msg, dom, path, epp, ttl) < 0)
+	if (epp && export_attrs_build(&ea, path, epp) < 0) {
+		xlog(L_WARNING, "Cannot export %s, possibly unsupported"
+		     " filesystem or fsid= required", path);
+		epp = NULL;
+		ttl = 0;
+	}
+
+	if (nfsd_nl_add_export(msg, dom, path, epp, &ea, ttl) < 0)
 		res = EXPORT_FULL;
 	else
 		res = epp ? EXPORT_ANSWERED : EXPORT_DENIED;
@@ -1786,7 +1799,7 @@ static enum export_result nl_export_negative(char *dom, char *path)
 	if (!msg)
 		return EXPORT_RETRY;
 
-	if (nfsd_nl_add_export(msg, dom, path, NULL, 0) < 0) {
+	if (nfsd_nl_add_export(msg, dom, path, NULL, NULL, 0) < 0) {
 		nlmsg_free(msg);
 		return EXPORT_RETRY;
 	}

-- 
2.55.0

