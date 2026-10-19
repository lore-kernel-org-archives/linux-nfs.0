Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CFF994E50DE
	for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 11:46:40 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792410403; cv=none; b=nm0y9dPuUmGb0kKfHVrYwvd2IWaY8W9ZVm0dU0jNfrcsFqSDYBBsvJ1zU1MurWGh0OoGIo5N4x3AgHfXigSqj7bXcVZLSIn0WcXB35LZkHdhqhNPv2Q79PS+tKx/3BllOPwm1Pyv5PE9ddLOy92rSDTgBXorYq3PeITmrqgg2kk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792410403; c=relaxed/simple;
	bh=gzFG5M6mij1J04LSwAY96jUZ8EjGoB5wuhUWlnamwnA=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=Iv3hv7NSa4Ir1NrueiPZYanDcAvPSab/PHwgIUNGEg5eKmo9Xr5ByVtq9yqQE2PP/NUe0ruGwN89S5SmcsK4nO5TtYFNhng/OBFuK8aEckxYt/PjNq/3l2WcyJ+xY3qZnIDAFD+lwMi7NqWbpVVIm+9pY4SbwvSObHxz39XWla8=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=E/XXbpN0; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="E/XXbpN0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 2F5581F000C5;
	Mon, 19 Oct 2026 11:46:40 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792410400;
	bh=rVHRzbDtZ8A6O28QTEPqVu7k14Uu0gvFYZr4OJ8Amy0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=E/XXbpN03UW8GQK41HL0Xaot/SAzUds8xMmkwR8309vgdRXG5w0L6bm9AWvzYqeqd
	 fIX1pkJG2hs4zN7ikgF4iUPfeNxRE5F7fErC9MdtZ7DXhOyNa/6t1eyfcz8w6CMshf
	 uhuFelRdfqa2hqsYru4dmL/TiGFot8CD73wa7cqPg5osrENp7SZehN/Q4Ufd6W66xf
	 EN4hP4OSGiT5Fsuj2ZUT0nytNS7i8JjXpUIwSGuVwrAcAzfkjh1F7PZuwHxTFMDHvr
	 HN6cnNAuonP8WU89uMix7Txdfj+6KiLJI1Y0HXoyskxCf9uIN0QLMXQnJPYJbOZp6b
	 /Gjam/JYiEs3g==
From: Jeff Layton <jlayton@kernel.org>
Date: Mon, 19 Oct 2026 07:46:23 -0400
Subject: [PATCH nfs-utils v2 3/7] exports: describe the kernel's export
 features with struct nfsd_export_policy
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261019-netlink-noproc-v2-3-7d09a49b574b@kernel.org>
References: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
In-Reply-To: <20261019-netlink-noproc-v2-0-7d09a49b574b@kernel.org>
To: Steve Dickson <steved@redhat.com>
Cc: Ben Coddington <bcodding@hammerspace.com>, linux-nfs@vger.kernel.org, 
 Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4454; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=gzFG5M6mij1J04LSwAY96jUZ8EjGoB5wuhUWlnamwnA=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq1gMdQhsCk63H2kgO7neg5+e0LzlWGasUiPszT
 7eJHClLCriJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCatYDHQAKCRAADmhBGVaC
 FbV2EACEGd/9mJQXRFpdtsso9IswrFUy25eH7gvOnYgxO479RXsXc9u2lfymiL42B1ZjBy241CE
 ePBvxXevW5lkiV7+zqCjuZttRIpsZ6NiFYNtSq30tDx/h3Id6nbJrC9QZZOWH9jgxlNWnrVLa3v
 oe+SY0PMDAw2dI9mld/PoYEZwvdG4i/nGacvVEppPyNZ/M4ssfBU7YTjeVE+ew9EbhwlUlqfl89
 CYKlR4dNlWxRqByiM84+a34OmA8XYLw9UASW+7XxqKFAM+XA0QhpdbP/d+ze2gKo8cIq5k+hWLF
 MM1U1AWnD9vcmVPeVKxd4nEaXzn2t2tyo3NzvnmLHm64KDWxazRhqZYLEPmNuKvpg4WtrjFQ+iA
 plpcYc2wvbzXN1b8Mjgaisb/wgBu34jYsXUV04edGX21VI0DRzTGrYYcc0NV0j1LDWWR2JVZFy1
 vyRJBqSTEXcMRyNGRGmYs47Lk2Ff/W5QHBq8CeI5mAFRYneNmUPVEwYcub+WBHw21aS1xDyexxp
 zOKM3xHjjipBCEeK9rLcuzcz+5+sBxEm0lYy2RWHgtx+5Azf01Y0TKUqHZ/hNoacSIFz+V9HF2j
 7EQVdtwChGQSiIqpB6AE5C51lk3h4tENn8kdffyjDze1mEmq0M6nxcI6B/u2ZEenvTWtrpomQKt
 Esn7yvkwrHArGWw==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Rename struct export_features, filled from /proc/fs/nfsd/export_features,
to struct nfsd_export_policy, ahead of filling it from the nfsd netlink
policy as well. No functional change.

Reviewed-by: Benjamin Coddington <bcodding@hammerspace.com>
Signed-off-by: Jeff Layton <jlayton@kernel.org>
---
 support/export/v4root.c    |  6 +++---
 support/include/exportfs.h |  9 +++++----
 support/nfs/exports.c      | 28 ++++++++++++++--------------
 3 files changed, 22 insertions(+), 21 deletions(-)

diff --git a/support/export/v4root.c b/support/export/v4root.c
index c3b17a55e483..ff1d6e1c0bde 100644
--- a/support/export/v4root.c
+++ b/support/export/v4root.c
@@ -127,12 +127,12 @@ v4root_create(char *path, nfs_export *export)
 static int
 v4root_support(void)
 {
-	struct export_features *ef;
+	struct nfsd_export_policy *pol;
 	static int warned = 0;
 
-	ef = get_export_features();
+	pol = get_export_features();
 
-	if (ef->flags & NFSEXP_V4ROOT)
+	if (pol->flags & NFSEXP_V4ROOT)
 		return 1;
 	if (!warned) {
 		xlog(L_WARNING, "Kernel does not have pseudo root support.");
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 9edf0d04732f..97d62ff4b157 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -166,12 +166,13 @@ struct addrinfo *		host_numeric_addrinfo(const struct sockaddr *sap);
 
 struct nfskey *			key_lookup(char *hname);
 
-struct export_features {
-	unsigned int flags;
-	unsigned int secinfo_flags;
+/* What the kernel's export interface accepts */
+struct nfsd_export_policy {
+	unsigned int	flags;		/* export flags it knows */
+	unsigned int	secinfo_flags;	/* flags that may vary per flavor */
 };
 
-struct export_features *get_export_features(void);
+struct nfsd_export_policy *get_export_features(void);
 void fix_pseudoflavor_flags(struct exportent *ep);
 char *exportent_realpath(struct exportent *eep);
 int export_test(struct exportent *eep, int with_fsid);
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 6b4ca87ee957..2266d5073d4c 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -235,10 +235,10 @@ static void secinfo_flags_show(FILE *fp, unsigned int flags, unsigned int mask)
 
 void secinfo_show(FILE *fp, struct exportent *ep)
 {
-	const struct export_features *ef;
+	const struct nfsd_export_policy *pol;
 	struct sec_entry *p1, *p2;
 
-	ef = get_export_features();
+	pol = get_export_features();
 
 	if (ep->e_secinfo[0].flav == NULL)
 		secinfo_addflavor(find_flavor("sys"), ep);
@@ -248,7 +248,7 @@ void secinfo_show(FILE *fp, struct exportent *ep)
 								p2++) {
 			fprintf(fp, ":%s", p2->flav->flavour);
 		}
-		secinfo_flags_show(fp, p1->flags, ef->secinfo_flags);
+		secinfo_flags_show(fp, p1->flags, pol->secinfo_flags);
 	}
 }
 
@@ -623,12 +623,12 @@ static void clearflags(int mask, unsigned int active, struct exportent *ep)
  */
 void fix_pseudoflavor_flags(struct exportent *ep)
 {
-	struct export_features *ef;
+	struct nfsd_export_policy *pol;
 	struct sec_entry *p;
 
-	ef = get_export_features();
+	pol = get_export_features();
 	for (p = ep->e_secinfo; p->flav; p++)
-		p->flags |= ep->e_flags & ~ef->secinfo_flags;
+		p->flags |= ep->e_flags & ~pol->secinfo_flags;
 }
 
 /*
@@ -962,20 +962,20 @@ syntaxerr(char *msg)
 	xlog(L_ERROR, "%s:%d: syntax error: %s",
 			efname, efp?efp->x_line:0, msg);
 }
-struct export_features *get_export_features(void)
+struct nfsd_export_policy *get_export_features(void)
 {
 	static char *path = "/proc/fs/nfsd/export_features";
-	static struct export_features ef;
+	static struct nfsd_export_policy pol;
 	static int cached = 0;
 	char buf[50];
 	int c;
 	int fd;
 
 	if (cached)
-		return &ef;
+		return &pol;
 
-	ef.flags = NFSEXP_OLDFLAGS;
-	ef.secinfo_flags = NFSEXP_OLD_SECINFO_FLAGS;
+	pol.flags = NFSEXP_OLDFLAGS;
+	pol.secinfo_flags = NFSEXP_OLD_SECINFO_FLAGS;
 
 	fd = open(path, O_RDONLY);
 	if (fd == -1)
@@ -985,13 +985,13 @@ struct export_features *get_export_features(void)
 	if (c == -1)
 		goto err;
 	buf[c] = 0;
-	c = sscanf(buf, "%x %x", &ef.flags, &ef.secinfo_flags);
+	c = sscanf(buf, "%x %x", &pol.flags, &pol.secinfo_flags);
 	if (c != 2)
 		goto err;
 good:
 	cached = 1;
-	return &ef;
+	return &pol;
 err:
 	xlog(L_WARNING, "unexpected error reading %s", path);
-	return &ef;
+	return &pol;
 }

-- 
2.56.0

