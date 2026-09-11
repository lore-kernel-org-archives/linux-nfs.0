Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 94CE849363D
	for <linux-nfs@vger.kernel.org>; Fri, 11 Sep 2026 16:25:42 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789143944; cv=none; b=nSOeiqN3yJGnGRwi4wHvOMJ3BU839cP5N69T5aWOQMl//KSo144/Zpj412IrEdxWJUkIOCGtVkXFNugGheNBcwlvgexd4JARd7wtPr/DjGzmaHzqrC/sATX70vhHNtboHVnZDgauAXAA3jxE1swJ1kamSCHH/JUm7Oi8ZrgKCj8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789143944; c=relaxed/simple;
	bh=7sWHMo9YYdq6W0NUOGrGKOxkLsgHfI0Rv7lOX1ejSuM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=gaTXX8W2YUSLlMb7UN/L/ILgSAphP4RmJTA5ruE88LrBjy+wc2i0/60KiSfDr9hZewCXy0pDGYw6fsf6jDm6R5np2MvPn1efFIWVw1erf63x3jcvGsn+2vMs+IlfYMbRlqLfcfpjmqcO+HGU/GWAO+oh5K3hlzS1iG9gZzsSSfI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=PUpCbiv/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="PUpCbiv/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E5AED1F00893;
	Fri, 11 Sep 2026 16:25:41 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789143942;
	bh=1pzwqoM1y5nDR7ivkZfZ98xdyoC+uPu7iZ4tS0IoDpw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=PUpCbiv/6NEIlTrU5ZYltfjUmd3qYThX2LuvFtgE5npTGCySsZAacULtO10zlSo0i
	 L6B8zanr0YJ2UFyWUXus76AARp22VPNvmBALPulOszdcp/wAopfe+rBHtncKj3dg/1
	 QrxqjxAp0lT6xHx8JWAc9eNdQZAcFnYG74jBgA0aXdlmhxpr+ObAyNbHISEk1ctdq4
	 wiTmMEFWYil4IIVQFMSBqi3T71S1xOMtBTRcwR098Vw0ojt3NlmGRxv2DiDdvP3W89
	 4t9nf/Lcb5qTMZcPWjTDN4PY2WQEeBJSKOlUNB8b5HbBu4lTMCOrg+2Bn2ULcwKfUO
	 O2VP5nirj3NVQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 11 Sep 2026 12:25:26 -0400
Subject: [PATCH nfs-utils v2 01/10] mountd: factor out the per-path export
 attribute computation
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260911-nl-crossmnt-v2-1-f4d869951c5e@kernel.org>
References: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
In-Reply-To: <20260911-nl-crossmnt-v2-0-f4d869951c5e@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5807; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=7sWHMo9YYdq6W0NUOGrGKOxkLsgHfI0Rv7lOX1ejSuM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqpCuCnnqmpmM5NrQ8qUEZmH8R/tTmw14JOy6Cg
 SDa+Ajwu3KJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqQrggAKCRAADmhBGVaC
 FaDDEACLAKLwOdvaCuJG0Rkr4vhTQvfq/5E6isHcRPj4XAFBnvQ07M8E4ahaAgTCGqFMDw34KDP
 msb5274PJ4VSZeky3JhU0sXyy6UjcHJl7R9RYZ26pBGz+a0rFY7Ogz58tSQfRgJbXH+BS9RSvwE
 35GE0NjmA5aIqVUVUU6c8+9KbmZ1R6d7oOOnBpnnTQM9YI+in2TjPSBeUrx8J+vko3sIcmfTwWl
 dIkWuoZxNpNkHTfnF353i8oieVG9exw3aIqtMAf0qtGeBgoYRIVGVmEt4CNg0AnhSMYASVOdbjA
 T49mon18p1tI/a4XhKcf4lbxibYvG4HQlURgO1GM/sdQQI0G3HoIjd2L6Dsln2uHp8Z+gP25jmN
 du06Y4cgadlXW1XJigzdtsW6A9seKQRMq7l8eASlm3BvKCP/UfouTTLqG7Q/dfuRvYbUfQY7S+1
 mCQtJnMgCFcXPGACw5imx/qgxVLgSXinS8SLbj6ojhAKkKXox7GBFHKJ7V3x8cysQ2yeH+T5WGG
 EsiBEk4kn50c/fdFwUR5aUivYOx9+GY27tnLzTg6XXeGCzrQMcT0MP9XupATuEY9GTI/DOZl77l
 EOp91CVsNIlKo0uT0RPknrK/zQKFQRDi6DQF5+Kw71BfhYnKhz90L3QBZ82JM0IdBBF0HBwqI/V
 ZqvLINQcae2e6JQ==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

dump_to_cache() adjusts the export flags, fsid and uuid before handing
them to the kernel, because the upcall path may be a crossmnt submount
rather than the exported path itself.  Pull that into
export_attrs_build() so the netlink downcall can use it too.

No functional change.

Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 support/export/cache.c | 143 ++++++++++++++++++++++++++++++-------------------
 1 file changed, 88 insertions(+), 55 deletions(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index 059f48a7069f..e8b13409ad7a 100644
--- a/support/export/cache.c
+++ b/support/export/cache.c
@@ -1072,6 +1072,86 @@ static void write_xprtsec(char **bp, int *blen, struct exportent *ep)
 		qword_addint(bp, blen, p->info->number);
 }
 
+static int can_reexport_via_fsidnum(struct exportent *exp, struct statfs *st)
+{
+	if (st->f_type != 0x6969 /* NFS_SUPER_MAGIC */)
+		return 0;
+
+	return exp->e_reexport == REEXP_PREDEFINED_FSIDNUM ||
+	       exp->e_reexport == REEXP_AUTO_FSIDNUM;
+}
+
+/* What to hand the kernel for one (path, export) pair */
+struct export_attrs {
+	int		flags;
+	uint32_t	fsidnum;
+	int		sec_mask;	/* mask for the per-flavor flags */
+	int		sec_extra;	/* extra per-flavor flags */
+	char		uuid[16];
+	bool		have_uuid;
+};
+
+/*
+ * An upcall path may be a submount below the exported one, when the export
+ * is marked crossmnt.  Such a submount is a filesystem in its own right, so
+ * it must not inherit the parent's fsid= or uuid= - if it does, both end up
+ * claiming the same filehandles and the client sees ESTALE.
+ *
+ * Returns 0, or -1 with errno set if @path cannot be exported at all.
+ */
+static int export_attrs_build(struct export_attrs *ea, char *path,
+			      struct exportent *exp)
+{
+	int different_fs = strcmp(path, exp->e_path) != 0;
+	int flag_mask = different_fs ? ~NFSEXP_FSID : ~0;
+	int do_fsidnum = 0;
+
+	memset(ea, 0, sizeof(*ea));
+	ea->fsidnum = exp->e_fsid;
+
+	if (different_fs) {
+		struct statfs st;
+
+		if (nfsd_path_statfs(path, &st)) {
+			xlog(L_WARNING, "unable to statfs %s", path);
+			errno = EINVAL;
+			return -1;
+		}
+
+		/* A re-exported submount gets an fsid= of its own instead */
+		if (can_reexport_via_fsidnum(exp, &st)) {
+			do_fsidnum = 1;
+			flag_mask = ~0;
+		}
+	}
+
+	if (do_fsidnum) {
+		uint32_t search_fsidnum = 0;
+
+		if (exp->e_reexport != REEXP_NONE &&
+		    reexpdb_fsidnum_by_path(path, &search_fsidnum,
+			    exp->e_reexport == REEXP_AUTO_FSIDNUM) == 0) {
+			errno = EINVAL;
+			return -1;
+		}
+		ea->fsidnum = search_fsidnum;
+		ea->flags = exp->e_flags | NFSEXP_FSID;
+		ea->sec_extra = NFSEXP_FSID;
+	} else {
+		ea->flags = exp->e_flags & flag_mask;
+	}
+	ea->sec_mask = flag_mask;
+
+	if (exp->e_uuid && !different_fs) {
+		get_uuid(exp->e_uuid, 16, ea->uuid);
+		ea->have_uuid = true;
+	} else if ((exp->e_flags & flag_mask & NFSEXP_FSID) == 0) {
+		ea->have_uuid = uuid_by_path(path, 0, 16, ea->uuid);
+	}
+
+	return 0;
+}
+
 /*
  * Netlink-based svc_export cache support.
  *
@@ -2501,15 +2581,6 @@ static void cache_sunrpc_nl_process(void)
 		cache_nl_process_unix_gid();
 }
 
-static int can_reexport_via_fsidnum(struct exportent *exp, struct statfs *st)
-{
-	if (st->f_type != 0x6969 /* NFS_SUPER_MAGIC */)
-		return 0;
-
-	return exp->e_reexport == REEXP_PREDEFINED_FSIDNUM ||
-	       exp->e_reexport == REEXP_AUTO_FSIDNUM;
-}
-
 static int dump_to_cache(int f, char *buf, int blen, char *domain,
 			 char *path, struct exportent *exp, int ttl)
 {
@@ -2524,60 +2595,22 @@ static int dump_to_cache(int f, char *buf, int blen, char *domain,
 	qword_add(&bp, &blen, domain);
 	qword_add(&bp, &blen, path);
 	if (exp) {
-		int different_fs = strcmp(path, exp->e_path) != 0;
-		int flag_mask = different_fs ? ~NFSEXP_FSID : ~0;
-		int rc, do_fsidnum = 0;
-		uint32_t fsidnum = exp->e_fsid;
-
-		if (different_fs) {
-			struct statfs st;
-
-			rc = nfsd_path_statfs(path, &st);
-			if (rc) {
-				xlog(L_WARNING, "unable to statfs %s", path);
-				errno = EINVAL;
-				return -1;
-			}
+		struct export_attrs ea;
 
-			if (can_reexport_via_fsidnum(exp, &st)) {
-				do_fsidnum = 1;
-				flag_mask = ~0;
-			}
-		}
+		if (export_attrs_build(&ea, path, exp) < 0)
+			return -1;
 
 		qword_adduint(&bp, &blen, now + exp->e_ttl);
-
-		if (do_fsidnum) {
-			uint32_t search_fsidnum = 0;
-			if (exp->e_reexport != REEXP_NONE && reexpdb_fsidnum_by_path(path, &search_fsidnum,
-			    exp->e_reexport == REEXP_AUTO_FSIDNUM) == 0) {
-				errno = EINVAL;
-				return -1;
-			}
-			fsidnum = search_fsidnum;
-			qword_addint(&bp, &blen, exp->e_flags | NFSEXP_FSID);
-		} else {
-			qword_addint(&bp, &blen, exp->e_flags & flag_mask);
-		}
-
+		qword_addint(&bp, &blen, ea.flags);
 		qword_addint(&bp, &blen, exp->e_anonuid);
 		qword_addint(&bp, &blen, exp->e_anongid);
-		qword_addint(&bp, &blen, fsidnum);
+		qword_addint(&bp, &blen, ea.fsidnum);
 
 		write_fsloc(&bp, &blen, exp);
-		write_secinfo(&bp, &blen, exp, flag_mask, do_fsidnum ? NFSEXP_FSID : 0);
-		if (exp->e_uuid == NULL || different_fs) {
-			char u[16];
-			if ((exp->e_flags & flag_mask & NFSEXP_FSID) == 0 &&
-			    uuid_by_path(path, 0, 16, u)) {
-				qword_add(&bp, &blen, "uuid");
-				qword_addhex(&bp, &blen, u, 16);
-			}
-		} else {
-			char u[16];
-			get_uuid(exp->e_uuid, 16, u);
+		write_secinfo(&bp, &blen, exp, ea.sec_mask, ea.sec_extra);
+		if (ea.have_uuid) {
 			qword_add(&bp, &blen, "uuid");
-			qword_addhex(&bp, &blen, u, 16);
+			qword_addhex(&bp, &blen, ea.uuid, 16);
 		}
 		write_xprtsec(&bp, &blen, exp);
 		xlog(D_AUTH, "granted access to %s for %s",

-- 
2.55.0

