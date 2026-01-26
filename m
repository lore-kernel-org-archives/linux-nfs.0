Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 435922D6E6C
	for <linux-nfs@vger.kernel.org>; Mon, 26 Jan 2026 20:39:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769459984; cv=none; b=XZgGsasAyUOMKNxccof47Led4YC9j2qwuepwZvhMh2z8MFnhV6IexlhMxL81af+/xwszdtK79LUcXQnvvoBPNSi5rYo9edZ2zoW2x74Nq0M1avpbdzsfIIQ1dhFGARYJjPgxrsi8y63ZAYiX8LN+JW+JFPVk1fQxL7w2oIKREbo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769459984; c=relaxed/simple;
	bh=Cy6tuBuwmgjpajbDIIkl0YDt4XGGKowgEHBIQ7zHIIk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Z9pt4qixULAB/PfMB/SKYfdyHurhWrOXL3MNw8bp02yscxsnUX0cswWsIExuPODenz8Mwe2/HueP8iN5Pnu/jTrPnmkX7CqRPYFKoUfTNpMsWN6RJfZYH2FS4RF/f0FJWJDEkLwzayJLhgweABV1mSdgYuvHAfM5sQEB7I2XUok=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=q9/WXTCH; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="q9/WXTCH"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id D153BC19425;
	Mon, 26 Jan 2026 20:39:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769459984;
	bh=Cy6tuBuwmgjpajbDIIkl0YDt4XGGKowgEHBIQ7zHIIk=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=q9/WXTCHKtfu7gudgRYcVll9iAmrO++d6cBti5AGF1odGGPh7+/Or79yJD5+Q/X1A
	 f1NdJW11OLEdgZ3fSfIrr3Tyer/grCjfHo4XfG4yKgNPnIWFY3yZSgXUDETgk0K7vL
	 sM4j5CW+GfprPqYv/ELwuRfTDS1uauPNV5JqYm8dT7bNMM6geRJ3I0NqusvmHauAd0
	 INBjzh7hRSuE/FzSZeh+Zn6/xPMnSFURQGj4Z2sY08IwLJ5TXgZOK5SXwRnSWWN3wR
	 LJHKz6e+TBxTQkro7yRFFleBzqkbn/aAt1160RxGl/SaaCgVx9bmFUpDK5pKmWhD9f
	 dQttdel/2M4SA==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH v2 09/14] NFS: Move nfs40_init_client into nfs40client.c
Date: Mon, 26 Jan 2026 15:39:33 -0500
Message-ID: <20260126203938.450304-10-anna@kernel.org>
X-Mailer: git-send-email 2.52.0
In-Reply-To: <20260126203938.450304-1-anna@kernel.org>
References: <20260126203938.450304-1-anna@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Anna Schumaker <anna.schumaker@oracle.com>

Signed-off-by: Anna Schumaker <anna.schumaker@oracle.com>
---
 fs/nfs/nfs40.h       |  1 +
 fs/nfs/nfs40client.c | 27 +++++++++++++++++++++++++++
 fs/nfs/nfs4_fs.h     |  1 -
 fs/nfs/nfs4client.c  | 27 ---------------------------
 4 files changed, 28 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/nfs40.h b/fs/nfs/nfs40.h
index 9369bb08825a..5a9c5d367b12 100644
--- a/fs/nfs/nfs40.h
+++ b/fs/nfs/nfs40.h
@@ -5,6 +5,7 @@
 
 /* nfs40client.c */
 void nfs40_shutdown_client(struct nfs_client *);
+int nfs40_init_client(struct nfs_client *);
 
 /* nfs40proc.c */
 extern const struct nfs4_minor_version_ops nfs_v4_0_minor_ops;
diff --git a/fs/nfs/nfs40client.c b/fs/nfs/nfs40client.c
index 8397d75a2f46..b0719403495d 100644
--- a/fs/nfs/nfs40client.c
+++ b/fs/nfs/nfs40client.c
@@ -53,6 +53,33 @@ void nfs40_shutdown_client(struct nfs_client *clp)
 	}
 }
 
+/**
+ * nfs40_init_client - nfs_client initialization tasks for NFSv4.0
+ * @clp: nfs_client to initialize
+ *
+ * Returns zero on success, or a negative errno if some error occurred.
+ */
+int nfs40_init_client(struct nfs_client *clp)
+{
+	struct nfs4_slot_table *tbl;
+	int ret;
+
+	tbl = kzalloc(sizeof(*tbl), GFP_NOFS);
+	if (tbl == NULL)
+		return -ENOMEM;
+
+	ret = nfs4_setup_slot_table(tbl, NFS4_MAX_SLOT_TABLE,
+					"NFSv4.0 transport Slot table");
+	if (ret) {
+		nfs4_shutdown_slot_table(tbl);
+		kfree(tbl);
+		return ret;
+	}
+
+	clp->cl_slot_tbl = tbl;
+	return 0;
+}
+
 /**
  * nfs40_walk_client_list - Find server that recognizes a client ID
  *
diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index bfc0afb796ff..702c63add4a1 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -483,7 +483,6 @@ extern const u32 nfs4_fsinfo_bitmap[3];
 extern const u32 nfs4_fs_locations_bitmap[3];
 
 void nfs41_shutdown_client(struct nfs_client *);
-int nfs40_init_client(struct nfs_client *);
 int nfs41_init_client(struct nfs_client *);
 void nfs4_free_client(struct nfs_client *);
 
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index d83a8a2a3c70..c376b2420b6c 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -331,33 +331,6 @@ static int nfs4_init_callback(struct nfs_client *clp)
 	return 0;
 }
 
-/**
- * nfs40_init_client - nfs_client initialization tasks for NFSv4.0
- * @clp: nfs_client to initialize
- *
- * Returns zero on success, or a negative errno if some error occurred.
- */
-int nfs40_init_client(struct nfs_client *clp)
-{
-	struct nfs4_slot_table *tbl;
-	int ret;
-
-	tbl = kzalloc(sizeof(*tbl), GFP_NOFS);
-	if (tbl == NULL)
-		return -ENOMEM;
-
-	ret = nfs4_setup_slot_table(tbl, NFS4_MAX_SLOT_TABLE,
-					"NFSv4.0 transport Slot table");
-	if (ret) {
-		nfs4_shutdown_slot_table(tbl);
-		kfree(tbl);
-		return ret;
-	}
-
-	clp->cl_slot_tbl = tbl;
-	return 0;
-}
-
 #if defined(CONFIG_NFS_V4_1)
 
 /**
-- 
2.52.0

