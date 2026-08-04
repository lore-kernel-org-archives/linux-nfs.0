Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D568441F353
	for <linux-nfs@vger.kernel.org>; Tue,  4 Aug 2026 20:59:58 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785877200; cv=none; b=AXqjNcMYewatLQqM+6wE+HxiMWcsBFWJK1ZPyJIzr1Zw/Ym+pQFUfSAjTHW4uFbeasGBj5+bKJh8O0FiXsfNieMKHOlA7fd0zR+ERrNHj59XKybazcA52G0c2bXyVP2hi5MzkmmxGFwuzqoWQoAki/qxqW2w9NsY0yry3uxExoA=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785877200; c=relaxed/simple;
	bh=q5TAuxmhcudipmt3xu7cV6ZMApKzctmMeRlNNdzPKrM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=K5mg2antxFhz5l1L3U5olESu6O2lu4E9IfIjzdZKy17yrRRdEtGaep2Se6tZHFIjNDhUnrkSfMYPVCHFScg8eNAW1LZjSYS4a8xIQmH+I00DD+Q/Qk4DYTjdFfYe2XFl+Xzwc/z7z6rRuvOahZJcvGzytxJUo/yKARwm86j0O58=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=iKrZ2IFX; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="iKrZ2IFX"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 735A11F000E9;
	Tue,  4 Aug 2026 20:59:58 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785877198;
	bh=OI8Wj4M9Gw4waeI9aFtKLJkFu7OptY1CzOirYBG8p8U=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=iKrZ2IFX/YHmVzkmhQsw28Vyyib6wUHWzMxoVEN5ygXyozvqFHiCq7iEsbFikTMUN
	 bkRdgAFwGuG9jyqdljyO2TQYAH8jxHzFgVh2YBp/CnppL8d7H6YNPu7R/WSncrHXdA
	 j9N/mP9FTOgey5Go0wR1w6TTBvqsZWJteAnY+ksfxWDHHCnvb7thzM+tzvragd+xqD
	 3ldCvF8FRd+d0vUAUDLKEDGt0R7SlE7jVT87hgQkRaJDbMliKSvaZe3QoXJ8dYQbG5
	 66BpdpH1qbN3BYnIN6Q0bBYCtklCo2sqGk/IzttzV6YM58urXRwfiHF4WtOz0QX4LV
	 T+DU3digtJrFQ==
From: Anna Schumaker <anna@kernel.org>
To: linux-nfs@vger.kernel.org,
	trond.myklebust@hammerspace.com
Cc: anna@kernel.org
Subject: [PATCH 4/4] NFS: Add support for CB_NOTIFY4_RENAME_ENTRY
Date: Tue,  4 Aug 2026 16:59:55 -0400
Message-ID: <20260804205955.625772-5-anna@kernel.org>
X-Mailer: git-send-email 2.55.0
In-Reply-To: <20260804205955.625772-1-anna@kernel.org>
References: <20260804205955.625772-1-anna@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Anna Schumaker <anna.schumaker@oracle.com>

Renaming an entry essentially combines a remove with an add, allowing us
to reuse most of the code from the previous patches to do the work for
us.

Signed-off-by: Anna Schumaker <anna.schumaker@oracle.com>
Signed-off-by: Anna Schumaker <anna.schumaker@hammerspace.com>
---
 fs/nfs/callback.h      |  6 ++++++
 fs/nfs/callback_proc.c | 16 ++++++++++++++++
 fs/nfs/callback_xdr.c  | 14 ++++++++++++++
 fs/nfs/nfs4xdr.c       |  1 +
 include/linux/nfs4.h   |  1 +
 5 files changed, 38 insertions(+)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index d3cc3e5df776..019ee9eed9fe 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -170,11 +170,17 @@ struct cb_notify_add {
 	bool			na_last_entry;
 };
 
+struct cb_notify_rename {
+	struct cb_notify_remove	nrn_old_entry;
+	struct cb_notify_add	nrn_new_entry;
+};
+
 struct cb_notify_changes {
 	u32	notify_mask;
 	union {
 		struct cb_notify_remove notify_remove;
 		struct cb_notify_add	notify_add;
+		struct cb_notify_rename	notify_rename;
 	};
 };
 
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 9fd0f93e6e5a..5dff65ac0377 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -440,6 +440,18 @@ static __be32 nfs4_cb_notify_add(struct cb_process_state *cps,
 	return 0;
 }
 
+static __be32 nfs4_cb_notify_rename(struct cb_process_state *cps,
+				    struct dentry *parent,
+				    struct cb_notify_rename *cb_rename)
+{
+	__be32 status;
+
+	status = nfs4_cb_notify_remove(cps, parent, &cb_rename->nrn_old_entry);
+	if (status != 0)
+		return status;
+	return nfs4_cb_notify_add(cps, parent, &cb_rename->nrn_new_entry);
+}
+
 __be32 nfs4_callback_notify(void *argp, void *resp,
 			    struct cb_process_state *cps)
 {
@@ -477,6 +489,10 @@ __be32 nfs4_callback_notify(void *argp, void *resp,
 			res = nfs4_cb_notify_add(cps, parent,
 						 &change->notify_add);
 			break;
+		case CB_NOTIFY4_RENAME_ENTRY:
+			res = nfs4_cb_notify_rename(cps, parent,
+						    &change->notify_rename);
+			break;
 		default:
 			res = htonl(NFS4ERR_NOTSUPP);
 			goto out_dput;
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 2885c25d0742..271476e9472d 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -338,6 +338,17 @@ static __be32 decode_notify_add(struct xdr_stream *xdr,
 	return 0;
 }
 
+static __be32 decode_notify_rename(struct xdr_stream *xdr,
+				   struct cb_notify_rename *args)
+{
+	__be32 status;
+
+	status = decode_notify_remove(xdr, &args->nrn_old_entry);
+	if (unlikely(status != 0))
+		return status;
+	return decode_notify_add(xdr, &args->nrn_new_entry);
+}
+
 static
 __be32 decode_notify_args(struct svc_rqst *rqstp,
 			  struct xdr_stream *xdr,
@@ -390,6 +401,9 @@ __be32 decode_notify_args(struct svc_rqst *rqstp,
 		case CB_NOTIFY4_ADD_ENTRY:
 			status = decode_notify_add(xdr, &change->notify_add);
 			break;
+		case CB_NOTIFY4_RENAME_ENTRY:
+			status = decode_notify_rename(xdr, &change->notify_rename);
+			break;
 		default:
 			goto err;
 		}
diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2d28c3ae37ad..ef9c6a24729b 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -2013,6 +2013,7 @@ encode_get_dir_delegation(struct xdr_stream *xdr, struct compound_hdr *hdr)
 	struct timespec64 ts = { 0, 0 };
 	u32 notifications[1] = { CB_NOTIFY4_REMOVE_ENTRY |
 				 CB_NOTIFY4_ADD_ENTRY |
+				 CB_NOTIFY4_RENAME_ENTRY |
 				 CB_NOTIFY4_GFLAG_EXTEND };
 	u32 child_attrs[1] = { FATTR4_WORD0_FSID | FATTR4_WORD0_FILEID |
 			       FATTR4_WORD0_TYPE | FATTR4_WORD0_FILEHANDLE };
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 9435ec5674d0..d3ecdaf01084 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -485,6 +485,7 @@ enum {
 /* Directory Delegation / CB_NOTIFY bits */
 #define CB_NOTIFY4_REMOVE_ENTRY		(1UL << 2)
 #define CB_NOTIFY4_ADD_ENTRY		(1UL << 3)
+#define CB_NOTIFY4_RENAME_ENTRY		(1UL << 4)
 #define CB_NOTIFY4_GFLAG_EXTEND		(1UL << 6)
 
 #define NFSPROC4_NULL 0
-- 
2.55.0

