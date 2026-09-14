Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4677046D55D
	for <linux-nfs@vger.kernel.org>; Mon, 14 Sep 2026 13:14:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789391674; cv=none; b=W89YiC2QQEa19sROnlPrgxXhJCMimdZDIS7Z408RQGjEIGFwVtaniEERM6nl72RNk0Mjke5wfO1/54sU08V5BBrE+lckn6V/WFJJ56vd15Gh4VLjHRMdIObVIO//vDnI0wWbRVtyGDh3aMLn9FTtksQ5uRhVFHliG8Wz14W0A4M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789391674; c=relaxed/simple;
	bh=4481iErc8Hl3MgUBEG/b2ltjVt6lrX4gOBIG3tBQRYg=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=sqzrMlKsKgDHNNpxQjDm8BnBcS/f20/pjFipfT0kdY3bRWg/F3QcZQKag8ZQF7nMnHhuessv3WVtikG+a4Bnf+9nBscsRgNX42bPBsgAeJ6dMmyuRINbCdqH5GqqHrT7r+GovQrEwXSvGOirQQ+W6Z7erYK4NFSTRTQj9FUm40o=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Ld9nwklB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Ld9nwklB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A42CF1F0089A;
	Mon, 14 Sep 2026 13:14:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789391672;
	bh=jtkTxHBIs5rtdZxhCCm4U+D4G6d8qGKJnyAQ0WDQXRU=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=Ld9nwklBK+HIna145HFtqapabgQM2oRra1JUiwVTtfn2iY5OvBFE9pFA97xJKpEXo
	 //rudrjzbrSomNURS+THiUBG+G5cZkPoYFImuHyHDt41Ke2ngibT27MZLRaKSQrJIY
	 BvMzxhVpuIJEE9dR92rUHCAUpNRNB952Ge6e8sT16QqKlIvnbqzfWfOwuYza+hX4Rz
	 8MPWjfr/D8ZkXrYP8GHOMtqdH1u+1F8G1Jx+dvl5bW8fVlrhrdYWUrThEfvpWp2NuJ
	 redWJsmDPqWYWHGEKDDfGpBrgOqN76oJsbRUdpe+49NpFGwORRKESItoLystesUrmn
	 XH6cUuNy7RQCQ==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 14 Sep 2026 09:14:13 -0400
Subject: [PATCH nfs-utils v3 04/11] mountd: don't leak the parent export's
 fsid onto crossmnt submounts
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Message-Id: <20260914-nl-crossmnt-v3-4-a984a6c94829@kernel.org>
References: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
In-Reply-To: <20260914-nl-crossmnt-v3-0-a984a6c94829@kernel.org>
To: Steve Dickson <steved@redhat.com>, 
 =?utf-8?q?Mantas_Mikul=C4=97nas?= <grawity@gmail.com>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=6496; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=4481iErc8Hl3MgUBEG/b2ltjVt6lrX4gOBIG3tBQRYg=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBqp/MzqdlRjcViCCxyoHUFxikPiNYDRL5L28+1J
 Qq9WKZfv7eJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCaqfzMwAKCRAADmhBGVaC
 FXIOD/9AB3iesgP1QKF3ozfNNw8G0c/DlJY2Xv/sAvLu3qrC4eT7E4531mD4XMnntxDQgzbG3zt
 5TK+io78f418XqHhzKdcbkM9LtRr0URLBNf/bRIGcqY3BLmjipOdkZGuu/3KM3eXQitaOk0mXrA
 pNywmTAbLAwl+pcm8K4vVGmusAhPjEKdDoJd8/rhxD5PPLjIUk86j+TW8YkJzd80sqCfBpram/U
 JBmJIRTTWAzrEHtF3GdRClhNb/DV6OSE2c1ybmQSdIAJs1PneIwxRf52k0J7vqyovXK9sIVYnlP
 krq4d9+nAd+QrhQaH8of4wQytI+vkT3P2jEV/hKRz7dfsAmvhEt6gD7qrZfBgrFHVI59MpH9qO+
 wAjscePt72vh6pTkCCRx/uBp1ebYypWrmmowUBc7w5sPI19BQat0hKOf4K+fqAt8C5Lvt4eSfwO
 UOJic/d39UoOkQGBVWqk12G7J04Iu8B/mDVP14gTqdffJlwtLOgKeClf+R7VZvEKNCTLo798cZI
 1YZY2t/QXrl9HeVuo1/D/a9M7bnl0v30PJeSwwtUAalLixMhcjPQxGBAV7L5mZUGD5Rrz6bYM6m
 AM5lNJsndgP4qhX/Hnw3l5RLTjaJrFJQIdsz0Mfi/yD5DLYem0qAjmA42fNNcnHuaRemb74UBrk
 nuajwr5/69beWHw==
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
failed batch, so this one depends on it.  Nobody asked to export that
submount, so it is only worth D_GENERAL - the warning stays for a path
exported in its own right.

Reported-by: Mantas Mikulėnas <grawity@gmail.com>
Assisted-by: LLM
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 support/export/cache.c | 58 ++++++++++++++++++++++++++++++++------------------
 1 file changed, 37 insertions(+), 21 deletions(-)

diff --git a/support/export/cache.c b/support/export/cache.c
index 5bdc00c5847f..b11ef5ec5da5 100644
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
@@ -1751,7 +1756,9 @@ static enum export_result nl_add_export_req(struct nl_msg *msg, char *dom,
 	nfs_export *found = NULL;
 	struct exportent *epp = NULL;
 	struct exportent *junction = NULL;
+	struct export_attrs ea = {};
 	enum export_result res;
+	bool explicit_export;
 	int ttl = 0;
 
 	if (is_ipaddr_client(dom)) {
@@ -1769,8 +1776,9 @@ static enum export_result nl_add_export_req(struct nl_msg *msg, char *dom,
 		}
 	}
 
+	explicit_export = export_is_explicit(found, path);
 	if (explicitp)
-		*explicitp = export_is_explicit(found, path);
+		*explicitp = explicit_export;
 
 	if (found) {
 		char *mp = found->m_export.e_mountpoint;
@@ -1800,7 +1808,15 @@ static enum export_result nl_add_export_req(struct nl_msg *msg, char *dom,
 		}
 	}
 
-	if (nfsd_nl_add_export(msg, dom, path, epp, ttl) < 0)
+	if (epp && export_attrs_build(&ea, path, epp) < 0) {
+		xlog(explicit_export ? L_WARNING : D_GENERAL,
+		     "Cannot export %s, possibly unsupported"
+		     " filesystem or fsid= required", path);
+		epp = NULL;
+		ttl = 0;
+	}
+
+	if (nfsd_nl_add_export(msg, dom, path, epp, &ea, ttl) < 0)
 		res = EXPORT_FULL;
 	else
 		res = epp ? EXPORT_ANSWERED : EXPORT_DENIED;
@@ -1827,7 +1843,7 @@ static enum export_result nl_export_negative(char *dom, char *path)
 	if (!msg)
 		return EXPORT_RETRY;
 
-	if (nfsd_nl_add_export(msg, dom, path, NULL, 0) < 0) {
+	if (nfsd_nl_add_export(msg, dom, path, NULL, NULL, 0) < 0) {
 		nlmsg_free(msg);
 		return EXPORT_RETRY;
 	}

-- 
2.55.0

