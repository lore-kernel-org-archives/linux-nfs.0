Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 599AA46D08B
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 14:16:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792160186; cv=none; b=KXqaMfPwgEE1lFuHTMjsmi6lTFMMwcSwfLFGm23y2aW6xzyRXikuSlFXghPga36lqn0Q5uOD6rhFzKK+PZRebjjvOWHpL3Y9sN6Azi2EcZc7GQNwj5v04yaqJPWCB2CCRuL+YrFwzqjeAR2lmC3miLaP7p/VC9gFwVoHpZ0Ug8Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792160186; c=relaxed/simple;
	bh=29h862PyJAaqQaYRnPNhSpVOVfzWdmxJnAXAix82MG0=;
	h=From:Date:Subject:MIME-Version:Content-Type:Message-Id:References:
	 In-Reply-To:To:Cc; b=qVpOEZMW/A+GNvaGqlyW1cYzw6DC9Euw6Q1JnI6oqr3ojid+lKh5B9kzWS7qKM0OpZv5Mv2pdK5MpiMOclNP3igU3DTd5BTeYSS/0CmQQDHYd5xE+jQ8BoiQVnVYsWeSIM3N5H+p6c5EKPNT7FaME4c0Ojt1I3zgMhu9ALFikAY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=HPgB1G+J; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="HPgB1G+J"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5520E1F000C5;
	Fri, 16 Oct 2026 14:16:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792160180;
	bh=pB7GEw6vxeiajJjOvFsiRJBTQoS/uXd7B6A6JOK34GY=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=HPgB1G+JIOqavNrjbDUw4qwKb+pLCVJ5SFrZuQakGnHMABoLJ34KvzNiw1Bwves7v
	 1Q8p+VB0SopvFuUGzZMD565Velq7bv+2Ha/1KuCaeTGL4mA+x5KJyYaweTLw7UCM8M
	 N6T5T2sqZT56iNfgBmDBLn0F86ioy2s837vqZK1esmLPodGltR7sVucnsYa74VWueU
	 NNFmiRKDdlB3VoEQzW9O5ZqTCapK4KwKN5MuqvaFyk/9bLhG6ISnSKc6y5WNEEi0n5
	 +lrNtFuooeXCX6e9wASK+uDGVv1s55WBxIMGH6G/m/NFMIwHZCACzrABpgtajiQvx4
	 DVGUy0MyKZKig==
From: Jeff Layton <jlayton@kernel.org>
Date: Fri, 16 Oct 2026 10:15:39 -0400
Subject: [PATCH nfs-utils 3/7] exports: describe the kernel's export
 features with struct nfsd_export_policy
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261016-netlink-noproc-v1-3-42791f4b6eb5@kernel.org>
References: <20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org>
In-Reply-To: <20261016-netlink-noproc-v1-0-42791f4b6eb5@kernel.org>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org, Jeff Layton <jlayton@kernel.org>
X-Mailer: b4 0.14.3
X-Developer-Signature: v=1; a=openpgp-sha256; l=4393; i=jlayton@kernel.org;
 h=from:subject:message-id; bh=29h862PyJAaqQaYRnPNhSpVOVfzWdmxJnAXAix82MG0=;
 b=owEBbQKS/ZANAwAKAQAOaEEZVoIVAcsmYgBq0jGxyox+mzgbe0aCxWyX8MxWwGScWcu5tP10D
 IWHjqb6BEGJAjMEAAEKAB0WIQRLwNeyRHGyoYTq9dMADmhBGVaCFQUCatIxsQAKCRAADmhBGVaC
 FWxwD/9e58ezBCXevn8mg/x5NbgdP5HTYtGgu1oM7Rg7gbh2J0ZxCaxnF0z4yi3Fc6VGsae70M8
 p8HN/nKHDYNkEMGC7tP6gl0prAMY/dcq3CYt8czihDQRAEj88EPIx1d2D8zYHF8AOmRx4ym7f+7
 F9l/tD2+33MAx8dGeWb9sFP76yYT3kgoGhiagDj0sKD/3kGo8A6oAvYd1SeDSnxSHVzYi2kVu0W
 te/FuHJDs54FE9QnyMU8mv09Ems1mcCbtZMTrpBEj7Kd3VUetjJ1glwXAXnMNJAn7QF1oWKKZyj
 DzdeIQ71+mRgUcRWl4H7U7FJeXvnlf3y7lyxT/NtXDxVfPA+XO00r+Ahz3XcKwxPyTHMMbwUxQv
 /plJYBhIX8jupPiNFVSiMd7EFw8Ei1BkVHwUZ3LP2zeXCVprDdLyQ0cHur16GMIhAAOQns6hAxq
 zA44h17BLBKyHIPm0+X1jIslAhWNDabeTAUDQX3eBHXW3rZ67sihjglMS44UVXKPL4qez+wD8SA
 lYQz0vyRpN6qsfu7Zl3hTaUuFWZB9KR4cwnWZRMcb1tLQsgibjGJUsvPUKuZa0k/020Pqusm+zj
 eP9pdqbilpQaq1qq9wcZxJOlrHfYkHCR3qIg6gOXjSO7zYtus+hLtFAQ+jDlX/gpnS3af3YelNF
 0f8QArxApnkLrng==
X-Developer-Key: i=jlayton@kernel.org; a=openpgp;
 fpr=4BC0D7B24471B2A184EAF5D3000E684119568215

Rename struct export_features, filled from /proc/fs/nfsd/export_features,
to struct nfsd_export_policy, ahead of filling it from the nfsd netlink
policy as well. No functional change.

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

