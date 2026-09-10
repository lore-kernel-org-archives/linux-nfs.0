Received: from fhigh-b5-smtp.messagingengine.com (fhigh-b5-smtp.messagingengine.com [202.12.124.156])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E10104BFE68;
	Thu, 10 Sep 2026 00:30:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.156
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789000223; cv=none; b=KsOsXN6o+UAO+8JGpP66zBetQLQcOGF6kk/JZe8I3OMo6D93Yw++oetdTpelzi8W2qs7jPbo5z8xssMAi0ylwU4/T6mKh+Q+LQpKI/Lji4fFjfLc66qx2vMLLnT3BXEUDwAge8HCGLlDL4HbLLm/Ztc5zxHEpSvfSBn4e4t31yY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789000223; c=relaxed/simple;
	bh=21Z+BtgvmM2js1ilbibl4PlPrU6omL6y9z7UdXleonU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=Av3oOCYmnB70QnLdmUuODl/oI7dUczJu3njL2peBrWQghbJaEVSNpfGlN65fv4szA6diorcDOoli4ZxM3KfhmX2AvfqHrO93aKCFEjU5XNNvAJaPKU7iryih/y/Pwf/oIBa8Z6R1wkFs1ZneHS6VKvweHETBEbDDocaQ2F1qx+E=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=CPBRc/Ns; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=bb6x6KmY; arc=none smtp.client-ip=202.12.124.156
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="CPBRc/Ns";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="bb6x6KmY"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 25BF17A00CA;
	Wed,  9 Sep 2026 20:30:21 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-06.internal (MEProxy); Wed, 09 Sep 2026 20:30:21 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:date:date:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to; s=fm1; t=1789000221;
	 x=1789086621; bh=8rC0OudH+Ezb9QEpUCtbs53CfUN4IZz0qeW42tJajRM=; b=
	CPBRc/NsihkqCAOHfh4H8T5HllOFgQ+rrDsY9D1Ic4a4U4ayOhUYuhiO3fY1lnh+
	j2B6RlqcfD5pHNMxjIhRN6gXItkSGDnrYe40/jUlK7mWj4zJRx4IaVN5UyY3I4tw
	QKOdTWBmM9eD1APhEfBUrrWSr/RjgYDF94dG+smFzDQSDM20v9VCE15dJ1Bvyyqv
	55/zDIimxH7MBvwhxxQJeB9jJdWgzqR84UzXSTQnQ/OFM2m135lTJrSAhiRFIflj
	AaYkcRHGMQXFVRYsDBARssY0oMooRILaadHd0uYJSJ9TYNbreRobW+D/7RpiDrtv
	7swxcHsujzozqLeKSdbEdA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:date:date:feedback-id:feedback-id:from:from
	:in-reply-to:in-reply-to:message-id:mime-version:references
	:reply-to:reply-to:subject:subject:to:to:x-me-proxy:x-me-sender
	:x-me-sender:x-sasl-enc; s=fm1; t=1789000221; x=1789086621; bh=8
	rC0OudH+Ezb9QEpUCtbs53CfUN4IZz0qeW42tJajRM=; b=bb6x6KmYdVwpQEQ2R
	wOUHAUq7DiNKd8h8+kFGqFwZtg+2iYS/ralyNYnZSUzlv8SusT/B1tbBie1osNOe
	MetAqWHICItAibK+TnDbOUGzFdKW9lIQwxGDNxukYVenEcIl2awGFus/BDFcndPJ
	JTbgLYbI0gHYkXbJknMKxEFEb6DER224IYsbb66TsEj4vPRmmadcvQGDjp5O17OZ
	t5xb8ZiZhcwczQFQO4FRXeOGHsf1XIaPJH4HgpIFymRIM8civB8ZylSE1ydB9kKT
	rXFurdSb310bngtDIGng7MDHYOk35krT+8OiI+sKd/2srbKgqtHMienXADG+LZKG
	BsiCg==
X-ME-Sender: <xms:HPqhau1ahyWNKf3ONcP0LtBdZWJh6a2j6KGPsyfcHaCuX0kaRZrlGg>
    <xme:HPqhajWpnO3ozeEFwkUlpXK2MdBW08AvXZj-QD1-oHgZ9ioF8orTNyk1B7yghaxYB
    02hkUbLhYIg1G8lzwQ0R6nszXIIX-comrTFfJPPPn9bkJmBfx4>
X-ME-Received: <xmr:HPqhapKF2cn19tv_4nufPlarhWd2FvinzlJXCwYo8itneko6o4peqJJEAGtBd9VpqS0mKdbcXoE3zY7yyVaQpv9CBQ7RdIk>
X-ME-Proxy-Cause: dmFkZTG2ZuPEN34R+utP3ESxb9Vdcejdvq1qn0GN2MsSCwESAHSyvwppLG2Yu+T030L2Os
    C8wXU3PxCkVzFW4dp/42EieFv6R0T70CdXif1RWlK2b+xBeP4D18DTQhJEghKWlRjrKyUb
    GdlNnxTgZ+lDp+o1Kz2BsylhbrNhfAZgPcMxHnaH8xn6D8vPLCsNPSG5ApS8ATGgHc/HWj
    wRdbCBCalK8qL4He0aXC4Lyqu1cVz74DhCxPFDqYj/33GFHQ6XxHNgTamDOpUZSq1ebJcO
    0bZ7djSj1c7whFp8Heq+QUaxe+WPB/b+6uiBLPfuZqukj1/5KZnVgOb+3nKerXH+iKGBGh
    pakdv/HAU0wNRCjkfjvUX7oo8FmfDEESvgT3CdQGJtxHy4ywpd6UWJm8sMTbU/Q0ByI79x
    4UC1P6aMozNaNiA7SzXUC8DdlpixM/FRGMne+uYKZoj+anhb2PgmeL1zMRjGLCNbFfUbWB
    xGh+YKiIpSYyIB3rfKZo6w4Rd6C3qKnKNxZ8qF2s5l6/jhOV8WMi10h6Ob7FW1k46s7+Yv
    SuJWrs2oZDUklVAmeq6cQ9wPWArLBs5Z0j/eqOStKqd/3DVqPA0RbkpAZW4MohR+3lmb8n
    zfmiFpaYp69ajWAiSuiRMAlpuFyMPA3mKd+MJu/im14QqYmID2H6cvuFa+Ow
X-ME-Proxy: <xmx:HPqhal155qwvael5qBxmWjRuwmpvkqN53lImxfQof8J1-ZBp0GpXew>
    <xmx:HPqhav4OnH6j44LPdtu0ISclq9zPevpbULqwe-ZL0WynRkLdSEbieg>
    <xmx:HPqhau_1X4Yyc4gBz7ZFBP5nLKrQJG_uRL5y6FvxDwpKbi2_BmhIDQ>
    <xmx:HPqhamXM_tspTE04MNtuScS5Luij4am1g6jpm-AXRw7uOjMELf3JDw>
    <xmx:Hfqhaohr3_B4dF0NjsKdcC1lgskR5wUAIPuUDZf47w7O1YzuGIOLJ14C>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 9 Sep 2026 20:30:18 -0400 (EDT)
From: NeilBrown <neilb@ownmail.net>
To: Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>
Cc: linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Subject: [PATCH 6/7] nfsd: nfsd_check_obj_isreg() to use nfs error codes.
Date: Thu, 10 Sep 2026 10:20:52 +1000
Message-ID: <20260910002934.192979-7-neilb@ownmail.net>
X-Mailer: git-send-email 2.50.0.107.gf914562f5916.dirty
In-Reply-To: <20260910002934.192979-1-neilb@ownmail.net>
References: <20260910002934.192979-1-neilb@ownmail.net>
Reply-To: NeilBrown <neil@brown.name>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: NeilBrown <neil@brown.name>

There is no longer any value in having nfsd_check_obj_isreg() return
over-loaded error codes which are converted to nfs error codes.
So revert to directly returning the required nfs error code.

Also take the opportunity to avoid dereferencing the inode and determine
the type directly from the dentry.

We can now remove ELOOP from nfs_errtbl[] as it doesn't *really* mean
the same as nfserr_symlink.  We probably don't need EFTYPE either, but
there is a very good match of meaning, so let's leave it.

Signed-off-by: NeilBrown <neil@brown.name>
---
 fs/nfsd/nfs4proc.c | 36 ++++++++++++++++--------------------
 fs/nfsd/vfs.c      |  1 -
 2 files changed, 16 insertions(+), 21 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 0fd5a6411ed3..a6ba7618a307 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -223,20 +223,17 @@ do_open_permission(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfs
 	return fh_verify(rqstp, current_fh, S_IFREG, accmode);
 }
 
-static int nfsd_check_obj_isreg(struct dentry *child)
+static __be32 nfsd_check_obj_isreg(struct dentry *child)
 {
-	umode_t mode;
-
-	if (!child || !d_inode(child))
-		return -EFTYPE;
-	mode = d_inode(child)->i_mode;
-	if (S_ISREG(mode))
+	if (!child)
+		return nfserr_wrong_type;
+	if (d_is_reg(child))
 		return 0;
-	if (S_ISDIR(mode))
-		return -EISDIR;
-	if (S_ISLNK(mode))
-		return -ELOOP;
-	return -EFTYPE;
+	if (d_is_dir(child))
+		return nfserr_isdir;
+	if (d_is_symlink(child))
+		return nfserr_symlink;
+	return nfserr_wrong_type;
 }
 
 static void nfsd4_set_open_owner_reply_cache(struct nfsd4_compound_state *cstate, struct nfsd4_open *open, struct svc_fh *resfh)
@@ -388,18 +385,17 @@ nfsd4_create_file(struct svc_rqst *rqstp, struct svc_fh *fhp,
 					oflags,
 					open->op_iattr.ia_mode & S_IALLUGO);
 	if (IS_ERR(open->op_filp)) {
-		int hosterr = PTR_ERR(open->op_filp);
-
-		if (hosterr == -EFTYPE) {
+		status = nfserrno(PTR_ERR(open->op_filp));
+		if (status == nfserr_wrong_type) {
 			if (nfsd4_create_is_exclusive(open->op_createmode))
-				hosterr = -EEXIST;
+				status = nfserr_exist;
 			else
-				hosterr = nfsd_check_obj_isreg(parent.dentry);
+				status = nfsd_check_obj_isreg(parent.dentry);
 		}
-		status = nfserrno(hosterr);
-		open->op_filp = NULL;
 		if (status == nfserr_noent && create_status)
 			status = create_status;
+
+		open->op_filp = NULL;
 		dput(parent.dentry);
 		goto out;
 	}
@@ -558,7 +554,7 @@ do_open_lookup(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate, stru
 	}
 	if (status)
 		goto out;
-	status = nfserrno(nfsd_check_obj_isreg((*resfh)->fh_dentry));
+	status = nfsd_check_obj_isreg((*resfh)->fh_dentry);
 	if (status)
 		goto out;
 
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index f9131827d391..8def58e92a8e 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -106,7 +106,6 @@ nfserrno(int errno)
 		{ nfserr_perm, -ENOKEY },
 		{ nfserr_no_grace, -ENOGRACE},
 		{ nfserr_io, -EBADMSG },
-		{ nfserr_symlink, -ELOOP },
 		{ nfserr_wrong_type, -EFTYPE },
 	};
 	int	i;
-- 
2.50.0.107.gf914562f5916.dirty

