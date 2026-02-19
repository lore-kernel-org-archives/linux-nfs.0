Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A0E9E2D7D47
	for <linux-nfs@vger.kernel.org>; Thu, 19 Feb 2026 22:13:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1771539235; cv=none; b=UdpUX1miM2dMWZ1XllXpk/4SqdRKpHXZpTuZalAhJEPIX4zbCEeEzTEjtsmjSwmAMPb2Hs5lEt3TkvShIEpGQDesaFzmyEkhGkEzKmvuUVj9Fs/y+hZYuJ1NZZaqD6yaoNwTDKu3lfad5N/doXOsU7AxwNuGgntHSnqqpp9ugcI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1771539235; c=relaxed/simple;
	bh=0rxfzvXvLBOxaxDYj8qLocE4MaO3/5xZnquDZJNvePA=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=BjSB9P4mB+K3LnhpIwO18q4MLedwDV67qf/vShq/zAJXRRbGC3F4jgXl2I+hImZw44z1pumzsqK0ovAbE7bxcLjU5Z9PDO3oyglSh1Wti5Csxx9kie6/hsF+wyvjWYqtU9kTd/UKpyAwU/73/L/aBYsjP1j2uuWNT+o0OVI+c1s=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SZ9mvrO3; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SZ9mvrO3"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 384A6C116C6;
	Thu, 19 Feb 2026 22:13:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1771539235;
	bh=0rxfzvXvLBOxaxDYj8qLocE4MaO3/5xZnquDZJNvePA=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=SZ9mvrO3MsF0ATjV4vOuVsOY/E8LJWALgryYYAkAHONJhAFMgto+3AQ3P5cl7bgDa
	 wKJQ4QZDlX+j7yo1OvuPa2NM12sPWV7JsyTTpzXwe1fNse3V3dIDHyXgecocPAdVU9
	 ZneVgSp2ob+IRoCdBv4IUuO/L8Dt4LkuePyVKU0iKXWv8u4CqD2lxgGFwD220JEkde
	 8fJPBpB6mJRTCCQwZaf9e6E0RGiMoSx8sIfoE5b7Tcyhlg5xQtoXEh5F0gHb9hO3tw
	 XAAReQFTfpzvJoeEDq3TRtMNB/yh0RLguXCjrEwCYyDLUYbMvs/mWDHrzWUdTOYWRF
	 wMlxDVjD65jpw==
From: Mike Snitzer <snitzer@kernel.org>
To: Chuck Lever <chuck.lever@oracle.com>,
	Jeff Layton <jlayton@kernel.org>,
	Trond Myklebust <trond.myklebust@hammerspace.com>,
	Anna Schumaker <anna.schumaker@oracle.com>
Cc: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 01/11] exportfs: add ability to advertise NFSv4 ACL passthru support
Date: Thu, 19 Feb 2026 17:13:42 -0500
Message-ID: <20260219221352.40554-2-snitzer@kernel.org>
X-Mailer: git-send-email 2.44.0
In-Reply-To: <20260219221352.40554-1-snitzer@kernel.org>
References: <20260219221352.40554-1-snitzer@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Mike Snitzer <snitzer@hammerspace.com>

Add EXPORT_OP_NFSV4_ACL_PASSTHRU flag that an export should set if
relevant new methods are added to export_operations (e.g. .setacl and
.getacl which will be added in future commits).

NFSD will use exportfs_may_passthru_nfs4acl() to check for this flag
before passing nfs4_acl thru to exported FS (using new methods in
export_operations).

Signed-off-by: Mike Snitzer <snitzer@hammerspace.com>
---
 include/linux/exportfs.h | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
index 9369a607224c..0262c9258b34 100644
--- a/include/linux/exportfs.h
+++ b/include/linux/exportfs.h
@@ -247,6 +247,7 @@ struct export_operations {
 						*/
 #define EXPORT_OP_FLUSH_ON_CLOSE	(0x20) /* fs flushes file data on close */
 #define EXPORT_OP_NOLOCKS		(0x40) /* no file locking support */
+#define EXPORT_OP_NFSV4_ACL_PASSTHRU	(0x80) /* fs MAY handle NFSv4 ACL passthru */
 	unsigned long	flags;
 };
 
@@ -262,6 +263,18 @@ exportfs_cannot_lock(const struct export_operations *export_ops)
 	return export_ops->flags & EXPORT_OP_NOLOCKS;
 }
 
+/**
+ * exportfs_may_passthru_nfs4acl() - check if export MAY passthru NFSv4 ACLs
+ * @export_ops:	the nfs export operations to check
+ *
+ * Returns true if the export MAY support NFSv4 ACL passthru.
+ */
+static inline bool
+exportfs_may_passthru_nfs4acl(const struct export_operations *export_ops)
+{
+	return export_ops->flags & EXPORT_OP_NFSV4_ACL_PASSTHRU;
+}
+
 extern int exportfs_encode_inode_fh(struct inode *inode, struct fid *fid,
 				    int *max_len, struct inode *parent,
 				    int flags);
-- 
2.44.0

