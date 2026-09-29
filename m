Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 17A2B3C8C71;
	Tue, 29 Sep 2026 02:27:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.151
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790648840; cv=none; b=b2evZMUqXHetCz9aBxBs3Hl51QpfvHO06sLu1aL2tEzRjZpGq9a3nILnA96Vsox9VKZliQCP1WRtt8LUyRZAfNr+J3UTD5OZ/ML2cCpe9JKQWQ5lfTPmNmtq1WjbGjr8nhJ6pV2rynKbmVQgfUTAfbhpCuBZOoDyfkF54jj2SAQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790648840; c=relaxed/simple;
	bh=QM259V0k6Iv9mXLetJTrj6WRU+lW9FuJjU4okchEOas=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=KahruD+f4sjP9SE22O13Bh2nxGFt2AB8arRgq/hob10YmrNtkWNb6EntzVPJwlnzir/ZpUBer82kMdk/hcHxu2cJqSkVQ6JRtJQkGOd/QoqRtIneX5kh5bNxeNhdNZUuQnNQ28foJKly1r1eYIATMc0AS/oCLuKLlgNBVaHJ2YM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=IRNMVBFb; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=pklCQRTz; arc=none smtp.client-ip=202.12.124.151
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="IRNMVBFb";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="pklCQRTz"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfout.stl.internal (Postfix) with ESMTP id 19BC51D00126;
	Mon, 28 Sep 2026 22:27:18 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-05.internal (MEProxy); Mon, 28 Sep 2026 22:27:18 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1790648837;
	 x=1790735237; bh=tlOTPlxeJg48uRf0lio6IimpGMjfoaRSeSTDpus1fBE=; b=
	IRNMVBFbzK/5Dy6MQJxl8LhpxAiX2HMTOYVqKWLOCXTGukNlanuUMhN0B+9Jty3A
	9xF4Pl1UPJmOUrOy/SbjaD2w+/DF9V91l7pDLTHdG1e60HBXQWaEIQxI9jLcM2p3
	bUvyixFL95fJwY5JaKJ7NsP2dzeNEOIpQghRsiFTox9r+yt6f8lNbUOcGiaSQp/S
	OKXhWt8ThXV8UAOI4qlkYJoLAuC9oIUX6Yp5VZ13qKlvfck+hbhrPRMpA9Tqb+Mw
	xujum+cw72Xy8LTWo5EWHdPrLhk4JHfJYkFz2KzUO+zTNorNHDSnP94DbE4VE83m
	JeTviJyuUaEaD/hK0uasWA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1790648837; x=1790735237; bh=t
	lOTPlxeJg48uRf0lio6IimpGMjfoaRSeSTDpus1fBE=; b=pklCQRTz6Y/gmFmIW
	I2K6S6Ab0fSvqdBhlBGJE3CwsOXecitym2zFi+u9oKx97hdfL7yaZtVJ0Y7kQ57s
	vqsNQAH1/YTJR5y7V5qL/fSrSLpqOtKyE/MebVfi7/D4U9/i2mE+9I/ZgnbgYMSl
	Gqj2m6anPyJUMZSnvx51/PoSuvHmzRbP29EjPxxav7w4Lt9YaUchc7Na4xSh+3yZ
	VqtDOHb/igBuX+dXzckTcg8VD9IULWRCFsn5qyY8FfTyJaBPlKEv91XSwiC+Vwhl
	qNE2h8eluPHI3OVYzLQlt0QhqNZqmce+GWIww3sZWHtrB8IUenomc5rKSWSGV9ck
	CIQMQ==
X-ME-Sender: <xms:BSK7auegtllkTAvZ2kJ6dz6ajTpBWkd9qsJQibSOzNbEMysLbOZypg>
    <xme:BSK7arQNux5Q4-WA9ZuPoZInY6_sgf4RFCa246SlPPzdl4HuoG_NZiuy1WjWI8Vaj
    FBx-yOgJiEzREEcODYTeO-5LoHctGRDTLD_XyQ1R9LRm72HQQ>
X-ME-Received: <xmr:BSK7aqJlAjoNrMVvJwBb0iCptyZBVasyiM2mknTRQYMnt4j2rJEV_TCUj-G2GE-EJEcjHqb1yaComPM_Rxt4SrKRzOkMdMI>
X-ME-Proxy-Cause: dmFkZTE+bsogD40d2GxBgpnYeHp/aup6WVRLzjdWBHHPlKBynVrzNWh8QEoADNOHP+FK+Z
    Vgqz5hC90Yp6jn9MDfo9aRFsYr2vMRz0xkNM8qRCjZwAXlP78t6WYYtP5SMZJn0d0uhQfe
    gFgWB4/7khWSm3cmBSPuGM0BFEi9gykQl8qvlo22NeQC6/uQwRqZOUFbgyYVOtcf7rUASX
    7Kaqhw7pe+zb3JDOIQ8+ig3BBnwuM5Xo+83Pt9mtsfvsMhL3F500p85F5BLBBgJRLOp1EP
    +Hcng1Jy3IJ4SZQiTS20OSaSrrdwyfitMh3HWtIXcSjsNttSH1A8upFBeYFTHElHPf89sX
    5oLGn0sJlmr2C5T4eviFDjjMl5BHPY19GMX9oHH+VfX5Cil5bLLyRok6azGMlFdhNP4n7Z
    PiD7LsNIky5Y7+hyQ4hzGFDLvrwkh9iPCqFc3aHNfsDm10pTU0klFznURDdS5LKYD1IObA
    a7JdmdOHoY3UNh59ThQQ/QCuOYkavq9KxxWLLkppC04a54GxyytDLzCg8NVg2wNgYuKRQ7
    v9z7k0JcyDHtlo3nysRMeQfM94bu5i5axYNoe9fyup88D1gvRbrT9eEZPCOjVQmWP+gNPa
    Y4jR3BG+1K3tzz2BHrppQFva73AwO/Xs0Pz8xtsWPGuc0IZ1H7fbITMdOFsg
X-ME-Proxy: <xmx:BSK7aoJJr-BOmx4cllYX-Pb0F3snVC2d3PTVQtmoCfypibCIIx3sAA>
    <xmx:BSK7aliBRTrI_nTZ2eCQwEayk0BN8VLkjjkJW8ZmzJ9bypkIB9Y1tw>
    <xmx:BSK7aiMzX5E82MVqUmDl-MyDMkeH8_q-Ypo_IaK9Onr4HnFtqXVb-Q>
    <xmx:BSK7agr6OHVOC-E-UirmBrhO75gaaqYSxlTimrTpsvnHQIBtX2uXiw>
    <xmx:BSK7aiGCgSDJQo_GCml0hueFzx4k93-bOXXfqNNNIkayCeVgkVdnnEjn>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 28 Sep 2026 22:27:15 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>
Cc: Jeff Layton <jlayton@kernel.org>,
	Jan Kara <jack@suse.cz>,
	linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH v2 9/9] nfs: use d_duplicate()
Date: Tue, 29 Sep 2026 12:21:19 +1000
Message-ID: <20260929022547.1428036-10-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260929022547.1428036-1-neilb@ownmail.net>
References: <20260929022547.1428036-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

As preparation for d_alloc_parallel() being allowed without the
directory locked, use d_duplicate() to duplicate a dentry for silly
rename.

This results in an in-lookup name, so d_lookup_done() must be called.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfs/dir.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e40ea471fa34..3adb8ce727f8 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2801,11 +2801,9 @@ int nfs_rename(struct mnt_idmap *idmap, struct inode *old_dir,
 			spin_unlock(&new_dentry->d_lock);
 
 			/* copy the target dentry's name */
-			dentry = d_alloc(new_dentry->d_parent,
-					 &new_dentry->d_name);
+			dentry = d_duplicate(new_dentry);
 			if (!dentry)
 				goto out;
-
 			/* silly-rename the existing target ... */
 			err = nfs_sillyrename(new_dir, new_dentry);
 			if (err)
@@ -2870,8 +2868,10 @@ int nfs_rename(struct mnt_idmap *idmap, struct inode *old_dir,
 		nfs_dentry_handle_enoent(old_dentry);
 
 	/* new dentry created? */
-	if (dentry)
+	if (dentry) {
+		d_lookup_done(dentry);
 		dput(dentry);
+	}
 	return error;
 }
 EXPORT_SYMBOL_GPL(nfs_rename);
-- 
2.50.0.107.gf914562f5916.dirty

