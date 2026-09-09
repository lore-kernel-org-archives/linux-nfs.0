Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id EDD92559CAF
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 12:56:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788958613; cv=none; b=FFYx3BAhVHQYbB39RNjKkRvH18C2fUs2RCUBDHznj6W14upXP7ApsEJNH68nlNgV1O16EOfiJSObElJeXd8L0oHdZ8kZoyV6FGENeyJbuudngiJLB3gh/YnmRBCUMiX8DdGL335sgLHEkPcNVDt4Fyyhuvlh5E3lDVbvpcaVs+g=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788958613; c=relaxed/simple;
	bh=7sWHMo9YYdq6W0NUOGrGKOxkLsgHfI0Rv7lOX1ejSuM=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=JwJQI/vrRplwpY3lvnlwGr5dxlRDYkL4v2pPP7IRVIct2PbzRcZUmMMfODKR9GTBiSUcAvRtdBPsA95/qjlCoTiGkaErzCmp534tt1PYeEj7kilQ+0JBkkfUbFqWs8mlwTQDqVdMabcrusLbTcdpMMWqB7MG3XUBMxBjwjVfE74=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=d8YXhvcp; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="d8YXhvcp"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 65B951F00A3D;
	Wed,  9 Sep 2026 12:56:50 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788958610;
	bh=1pzwqoM1y5nDR7ivkZfZ98xdyoC+uPu7iZ4tS0IoDpw=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=d8YXhvcp6Lc10PVDqR2LJjafLw7n39oVNROcIzfY/rO/CGn8WdrIf2ZAlax3oZS17
	 fGB5f2xZQsQDit4Q970fHHsr8QEAh4eg4wYL+f6ZILFnEnQ97+2PryvX0ufROAfMzg
	 fEUgzDyYFjab2ExPL9cDHmp/MfJ9EnI2mh2vwRQ/OYFYvPelSRiEZmOGuX3WdMd+jL
	 5hAtxM5FdfMNjiBLWwvuphqQ+IiKBdVTz5bpU9GidYJcb1OFD3iWaT9JMcHbK33t9x
	 X4TSwWNkrGPCoqh5bFU3HvfiYYJHOLoyRVPn6G9LPvjNZahfikeGgtK8kdqsc9SQSA
	 xasaihnQvvAgA==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 09 Sep 2026 08:56:44 -0400
Subject: [PATCH nfs-utils 1/5] mountd: factor out the per-path export
 attribute computation
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20260909-nl-crossmnt-v1-1-4064b5a3bd85@kernel.org>
References: <20260909-nl-crossmnt-v1-0-4064b5a3bd85@kernel.org>
In-Reply-To: <20260909-nl-crossmnt-v1-0-4064b5a3bd85@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5807; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=7sWHMo9YYdq6W0NUOGrGKOxkLsgHfI0Rv7lOX1ejSuM=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqoVeQEDUo5OzEpWM3uPa3gydWYuOOuQmy63uLd
 BPJ45FS3TKJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqFXkAAKCRAADmhBGVaC
 Fd7ID/94Wso1Qpled99HyOvKC6+Hr1HUaD9iBwtYKXBx/mwLj1mlg465rqDBGcJp8aXCHdzxhqN
 KfmdyJwUOEbjUXjSLhpMzN3Ag8RAOO1mBG4y7hVdLwVWe/wtxJ6rdVXJdqWBVYMegMrpB4vByQc
 68CTdVE+Ro2un2syBE089xv/S1eNmbdbiRNjrEteStPeuIg9hqFFddp+MvQhBFOikY1L3dzuXES
 HNHYPkLk3u0srHXlte2mpi4vTNlaPzHGAAMNvSqqeVWFujYYhQp05omvOIkq6YWHD4WSYUlyZFT
 gE9uWADUK2lmgQ/EpWNNRHlA1a1zFEL1cEmzqoDCZs8i9R4fzxSei0twM9p0whJ3Fa9jkCXM+oG
 0uE5oamXYO45a+FANBS7nhJNFNEi8upY0UuXu+amMu3vwbxRXC8/E4xAuKDxun9Di2ns4f/KWa5
 4ou8tt5YbjubdktxaKru+jrE7fTS7pwE8pBKFuWj4ZQzzm29pmoqHWq17OlhMkvGDCxxWpvSYqh
 mepWfbBV80baxYq8kV99N7cW0FFF/uK+NZEqEvpR3eri5bNXX90qkA3Xr9Sh1f2lRQt9s03gU9l
 SlQ54Tk1yExBPzlfFizA9Gof0YSaqL8pR6ZTS0VFcIQ0z+QeF9wdT/NyInj04AkAZqTo4gYQvXN
 VPbC21+IlJ4hVog==
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

