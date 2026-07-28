Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC6B2392C56
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2026 16:59:14 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785257956; cv=none; b=DTCZmE+j5TfJUIqJoJhHwsmoGXhWTv5xbX3SheM0UmVcBHJmCoWyXoxkCN4Nq7TFmR3IfTXJSRJZiyD1ELdV+RbBvbamOQepYnweImm4U3+ThOzrszo7DHA4kw6VKqzjNbm5ztrRdjr1h1zGA8+zQMcC0hHZyv893ORotSldM/U=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785257956; c=relaxed/simple;
	bh=0OMXLGr75rV2gj/2dQ5U5tVfpzd/Xd/cL9L0F7eOkO8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=D2lwzrUxrfgN/Ene0GrMdPAk6InPcPhhdKXuLOlNHGCpPse4vKyz/jjT+E/jGqnLEYktZy/VuD6hla+Vw9Za/5TxLdZMeYo3up+MUAHRfigAqGpN8ncqtF751Im25fEdGUEcpOmsgsaIPnWB6j7SHGqRPdlsJXKORhdrmT1Oo28=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EWkoVMV/; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EWkoVMV/"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 95B5E1F00A3A;
	Tue, 28 Jul 2026 16:59:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785257954;
	bh=GxB5w0WEG/CalsLk7Dd6qPYCUrbXo7h9U4mjrd7c+tQ=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=EWkoVMV/pCLAkY4ChX5SbuN9bjXzX4iJLF8juh5+t6hu1PPqyJIvTvK4b+hytFIji
	 +Q0j4QAkkpHdtq7BUs5TQjwNRLUYylXIud2/Hc6mEACiE1bm7X8Iyp+PwcUaSa+oTe
	 CkDzt5mURmjkAwITybbdUKbzJlKFFbg1+kp/kDmSr8hrIuU4EYngzuCviwcJX7Jiwk
	 8fuzZSv5cXquCLb1nJGB17s1a+fZByCfopxRMXDAUukkiSW5qKeGgbLm3kib/nhkv3
	 zGYqR/wWeTC/Afl/yaB1XTkGkWX45Pj+xWQZNTpYHThkcJ78CMSfEaKqc2UtaiZzq6
	 sN7s6uF3PkXaw==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neil@brown.name>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 1/5] NFSD: Move the RPC program definition for LOCALIO
Date: Tue, 28 Jul 2026 12:59:07 -0400
Message-ID: <20260728165911.462534-2-cel@kernel.org>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260728165911.462534-1-cel@kernel.org>
References: <20260728165911.462534-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Clean up: The definitions for the LOCALIO program are not needed by
most files that include linux/nfs.h. Following the convention used
by most other in-kernel RPC program implementations, relocate the
LOCALIO program definitions to a localio-specific header.

Signed-off-by: Chuck Lever <cel@kernel.org>
---
 include/linux/nfs.h        | 7 -------
 include/linux/nfslocalio.h | 8 ++++++++
 2 files changed, 8 insertions(+), 7 deletions(-)

diff --git a/include/linux/nfs.h b/include/linux/nfs.h
index 0e2b210c103b..8c2818db43c5 100644
--- a/include/linux/nfs.h
+++ b/include/linux/nfs.h
@@ -15,11 +15,4 @@
 
 #include <uapi/linux/nfs.h>
 
-/* The LOCALIO program is entirely private to Linux and is
- * NOT part of the uapi.
- */
-#define NFS_LOCALIO_PROGRAM		400122
-#define LOCALIOPROC_NULL		0
-#define LOCALIOPROC_UUID_IS_LOCAL	1
-
 #endif /* _LINUX_NFS_H */
diff --git a/include/linux/nfslocalio.h b/include/linux/nfslocalio.h
index 3d91043254e6..d2b39e6e6c6a 100644
--- a/include/linux/nfslocalio.h
+++ b/include/linux/nfslocalio.h
@@ -16,6 +16,14 @@
 #include <linux/nfs.h>
 #include <net/net_namespace.h>
 
+/*
+ * The LOCALIO program is entirely private to Linux and is NOT part of
+ * the uapi.
+ */
+#define NFS_LOCALIO_PROGRAM		400122
+#define LOCALIOPROC_NULL		0
+#define LOCALIOPROC_UUID_IS_LOCAL	1
+
 struct nfs_client;
 struct nfs_file_localio;
 
-- 
2.54.0

