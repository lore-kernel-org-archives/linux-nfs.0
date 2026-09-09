Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id DE10B559CBE
	for <linux-nfs@vger.kernel.org>; Wed,  9 Sep 2026 12:56:53 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788958617; cv=none; b=Olr1G7aI3vQUi1oL5xWuLe81q7FzGSRfroxOc2tIe7/X1UtopktvjufcWVgOfLM7yo6A+Nwp/95CW+WT+JYuSV62CYiOZLMhmMtj7IeRKXHz2EdO6ZDOzoCv3XYqK7KijJbrbkyeoxKCA4O3lvfDi8h1mUiLnCkY2HIhMjFzOnc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788958617; c=relaxed/simple;
	bh=pmlwAJklv/spnUUSCmKxc+mq2V4A0moyX/3jnEtmbUk=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=NdaDtYlT/sTN/6/yi/rUVTydx8u0BcE4oTFcSog51RSi44O7xH6nv2CjYbazylL56c97TddsSEYH0bMWY/pbeNvEs/A8osqMw84wG9t4rQf8hh+i+DsaGospRceY0HuKM/ntNu/Bf4KHfwEW05kszQRIqY0SMIhuBKg5vCW3ilc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ho//J4WK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ho//J4WK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3F79F1F00A3F;
	Wed,  9 Sep 2026 12:56:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788958612;
	bh=fhLtHGApr4G3tVZe+R8Do+euDxcIdTp1QjY5L07qsQc=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Ho//J4WKNqlwaw5fgZvJg7vunV5WFtJEs8SVVMMLDZq+FucfdVUFBs9PER5tNsTE6
	 DPogawvAWC3q/bScZMGzJZ4QCfcTZ6NDHHPnSCYa0794GEGKhq+RhdSZH8HAm8Bp3O
	 b40QmnZccE2hFwQsf0+mMlfPBAdhDyuWx2cFBEIlIG0LrcohbelDeRiTpUNWJZlz5m
	 K3urTuo0u5J72bHINkM/aY65ImGbrxuNgxfNacnj+j7/Z1MSmAngMi03vD20EwyLca
	 P+czfKmw5QMFZfh0bABoi/3cxSOZXee7AAjns2wZjc7XQUkgxQtL5E5wMSBWV4fvWW
	 2N3VO4cimTVYQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Wed, 09 Sep 2026 08:56:47 -0400
Subject: [PATCH nfs-utils 4/5] mountd: don't leak the parent export's fsid
 onto crossmnt submounts
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260909-nl-crossmnt-v1-4-4064b5a3bd85@kernel.org>
References: <20260909-nl-crossmnt-v1-0-4064b5a3bd85@kernel.org>
In-Reply-To: <20260909-nl-crossmnt-v1-0-4064b5a3bd85@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=5978; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=pmlwAJklv/spnUUSCmKxc+mq2V4A0moyX/3jnEtmbUk=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqoVeRCWgaRB37noN5IIbtNTSvibul2OZ7uvmUc
 gmx2+82M4eJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqFXkQAKCRAADmhBGVaC
 Fex7D/9tbWZCQi/+dhqACqmBpuhGdBOzPhw3V/h8xrD0uITWSclFUmWcWhjkO550cWYG5DmnR2B
 QfXSR/Gkk24rxbDK2uR1D+ATlv86HYMYMcKtOjf9J9ZofxfnDIXGE0n4nEvvSuDja3DXlgxoiXM
 95be4uwPadlnEOkOqJvHdVz47re7Su6/35uy2JGXifdY3APtrIjpVE17Om5FQSKUUtFNKrjHTwo
 yiIYkhb54Emh6xx4uyaPf2rlOdtw0BjgY4hptmRmyW8A+ayXtzCvCjxlc9LwpaFsFcH8G8gf/Qm
 QtILLYORC3kyRUHUdjvJLxcs+/pbFtunLZZjxtm8GIsW2eeGIZe7wZ2cD/Z8KHFqKhIBDWmWedv
 MET5GpEAyZblGkgr+/ERIFknoyoC2YeFZiTnQx2W6GEKKgttG2nWzD09j+8j7HrHT/QPSCUE/SZ
 vrjq7BCamX0ggSdGkoQeLRA01HY+GaxtMjaQG2OYeXqch25BDd4xFMHOdxIH69eZArfxohEAlal
 ak4npoHZEbhYVPcp0KSrGT9Jh7VACzehVhj84vqmyoo5oNhNEU5TPseyt8rx4jWMN4IGLG6nLPN
 18hfLXiyLeHEBSPeIZ7uwpYTrIh3p9fMQyjbiVIMtqRqfnxSgsMcUpYrz4FZ0Sx3d8dN00hu/DX
 j6BtOszY6yhj/6A==
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
index d118834da29a..1f81a67e35cf 100644
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
@@ -1777,7 +1790,7 @@ static void nl_export_negative(char *dom, char *path)
 			       NFSD_CMD_SVC_EXPORT_SET_REQS, 0);
 	if (!msg)
 		return;
-	if (nfsd_nl_add_export(msg, dom, path, NULL, 0) == 0)
+	if (nfsd_nl_add_export(msg, dom, path, NULL, NULL, 0) == 0)
 		cache_nl_set_reqs(nfsd_nl_cmd_sock, msg, NULL);
 	nlmsg_free(msg);
 }

-- 
2.55.0

