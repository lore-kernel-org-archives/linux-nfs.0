Received: from us-smtp-delivery-124.mimecast.com (us-smtp-delivery-124.mimecast.com [170.10.129.124])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 574B844236D
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 09:39:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=170.10.129.124
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788514755; cv=none; b=qDQMJZ2yOZRGGFKPK1CIt1G6Ep4akhGqsX8/ADPGDHw6vSFC0SYr9aY1vkW22z+14UZHbbWnyTRnq6WiU/laK5NgAdFiM62neWXkm4tn/TnJNrjCP/hsNfCV+N2IF0iAC0CIQ9RzR1Ey4ABPcGEe3kOVME8mUIu7078V3GGTo6Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788514755; c=relaxed/simple;
	bh=RaVO2KOzYl/PBi+H5cTRi0w28cXHH3IXoUlhcSsQbqo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=LoyZIUXRK4wrbjsHShgITu08JYg6DtKJx8+qOHD8bBMaekX126BD0a4JC3ErnU43ElWHkmMQYnIre2ffjLlBOE7DUTb2xF1PyboqzhfNaUQh1cN218mYKjkGp80k7DYzQycU8VVAVMvhs4389l/FJn1J+N4/RYJiFyRPftdM490=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com; spf=pass smtp.mailfrom=redhat.com; dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b=iO/wrC/b; arc=none smtp.client-ip=170.10.129.124
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=redhat.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=redhat.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (1024-bit key) header.d=redhat.com header.i=@redhat.com header.b="iO/wrC/b"
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=redhat.com;
	s=mimecast20190719; t=1788514753;
	h=from:from:reply-to:subject:subject:date:date:message-id:message-id:
	 to:to:cc:cc:mime-version:mime-version:
	 content-transfer-encoding:content-transfer-encoding:
	 in-reply-to:in-reply-to:references:references;
	bh=laiEWOsH10z9nZaPS3m0SQ0xZdqY5dP/BLbmVapUgNA=;
	b=iO/wrC/bedCByCfful80uPpf6DMMjMsL4E2+1kTQIQrosR/KhON9sMj4Syju+Pt8sJO3Oe
	m7n2Vu4JYgcJpMol4y0RtGCC0ckFllCdEKb3F1SJbZ8RkA1DNMEwzsVs25Aq4yjDDdb6hq
	DMwpTHPxFdICyeth/QwyMxiVXmAResk=
Received: from mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com
 (ec2-54-186-198-63.us-west-2.compute.amazonaws.com [54.186.198.63]) by
 relay.mimecast.com with ESMTP with STARTTLS (version=TLSv1.3,
 cipher=TLS_AES_256_GCM_SHA384) id us-mta-453-ZMkXScmhM3a5FY6PEbDIdA-1; Fri,
 04 Sep 2026 05:39:12 -0400
X-MC-Unique: ZMkXScmhM3a5FY6PEbDIdA-1
X-Mimecast-MFC-AGG-ID: ZMkXScmhM3a5FY6PEbDIdA_1788514751
Received: from mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com [10.30.177.17])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by mx-prod-mc-01.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTPS id 8F963195FDE6
	for <linux-nfs@vger.kernel.org>; Fri,  4 Sep 2026 09:39:11 +0000 (UTC)
Received: from fs-i40c-01.fast.eng.rdu2.dc.redhat.com (fs-i40c-01.fast.eng.rdu2.dc.redhat.com [10.6.54.119])
	by mx-prod-int-05.mail-002.prod.us-west-2.aws.redhat.com (Postfix) with ESMTP id 2F45D1955F70;
	Fri,  4 Sep 2026 09:39:11 +0000 (UTC)
From: Roberto Bergantinos Corpas <rbergant@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs4-acl-tools PATCH 1/3] nfs4_getfacl/nfs4_setfacl: escape newline+cr from filenames
Date: Fri,  4 Sep 2026 05:39:07 -0400
Message-ID: <20260904093909.2881028-2-rbergant@redhat.com>
In-Reply-To: <20260904093909.2881028-1-rbergant@redhat.com>
References: <20260904093909.2881028-1-rbergant@redhat.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Scanned-By: MIMEDefang 3.0 on 10.30.177.17

Filenames can be crafted to contain these special chars, as a result
they can be interpreted as ACE payload on the file that was not
explicitely set. Escape these chars from the path/filename.

Signed-off-by: Roberto Bergantinos Corpas <rbergant@redhat.com>
---
 include/libacl_nfs4.h       |  1 +
 libnfs4acl/nfs4_print_acl.c | 13 +++++++++++++
 nfs4_getfacl/nfs4_getfacl.c |  7 +++++--
 nfs4_setfacl/nfs4_setfacl.c |  6 ++++--
 4 files changed, 23 insertions(+), 4 deletions(-)

diff --git a/include/libacl_nfs4.h b/include/libacl_nfs4.h
index a486390..76c7e5e 100644
--- a/include/libacl_nfs4.h
+++ b/include/libacl_nfs4.h
@@ -217,6 +217,7 @@ extern int			nfs4_print_ace_verbose(struct nfs4_ace * ace, u32 isdir);
 extern char*			nfs4_get_ace_type(struct nfs4_ace*, char*, int);
 extern char*			nfs4_get_ace_flags(struct nfs4_ace*, char*);
 extern char*			nfs4_get_ace_access(struct nfs4_ace*, char*, int);
+extern void			nfs4_print_escaped_path(FILE *fp, const char *path);
 
 
 /** misc **/
diff --git a/libnfs4acl/nfs4_print_acl.c b/libnfs4acl/nfs4_print_acl.c
index 61f4d95..5afd682 100644
--- a/libnfs4acl/nfs4_print_acl.c
+++ b/libnfs4acl/nfs4_print_acl.c
@@ -83,3 +83,16 @@ unexp_failed:
 	fprintf(stderr, "An unexpected failure has occurred. \n");
 	return;
 }
+
+void nfs4_print_escaped_path(FILE *fp, const char *path)
+{
+	const char *s;
+	for (s = path; *s; s++) {
+		if (*s == '\n')
+			fputs("\\n", fp);
+		else if (*s == '\r')
+			fputs("\\r", fp);
+		else
+			fputc(*s, fp);
+	}
+}
diff --git a/nfs4_getfacl/nfs4_getfacl.c b/nfs4_getfacl/nfs4_getfacl.c
index ddb3005..be4652c 100644
--- a/nfs4_getfacl/nfs4_getfacl.c
+++ b/nfs4_getfacl/nfs4_getfacl.c
@@ -163,8 +163,11 @@ static void print_acl_from_path(const char *fpath, enum acl_type type)
 	}
 
 	if (acl != NULL) {
-		if (ignore_comment == 0)
-			printf("# file: %s\n", fpath);
+		if (ignore_comment == 0) {
+			fputs("# file: ", stdout);
+			nfs4_print_escaped_path(stdout, fpath);
+			fputc('\n', stdout);
+		}
 		nfs4_print_acl(stdout, acl);
 		printf("\n");
 		nfs4_free_acl(acl);
diff --git a/nfs4_setfacl/nfs4_setfacl.c b/nfs4_setfacl/nfs4_setfacl.c
index d10e073..ab4a3d8 100644
--- a/nfs4_setfacl/nfs4_setfacl.c
+++ b/nfs4_setfacl/nfs4_setfacl.c
@@ -545,9 +545,11 @@ static struct nfs4_acl* edit_ACL(struct nfs4_acl *acl, const char *path, const s
 	}
 
 	if (stat->st_mode & S_IFDIR)
-		fprintf(tmp_fp, "## Editing NFSv4 ACL for directory: %s\n", path);
+		fputs("## Editing NFSv4 ACL for directory: ", tmp_fp);
 	else
-		fprintf(tmp_fp, "## Editing NFSv4 ACL for file: %s\n", path);
+		fputs("## Editing NFSv4 ACL for file: ", tmp_fp);
+	nfs4_print_escaped_path(tmp_fp, path);
+	fputc('\n', tmp_fp);
 	nfs4_print_acl(tmp_fp, acl);
 	rewind(tmp_fp);
 
-- 
2.55.0

