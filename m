Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.221.48
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794765863;
	b=4+Wl1wqTlcNpLGcnNAq419476xBINze+D41IqMAD4dM6QEDvMeaoRnbehq12WXufXSzE
	 FVBOSxaCe3P83AhbDhQHAH6/9GbeG83ojh6HnA5V17CKv9kYDxh/gZcRlKt++KI8P3x7c
	 007VvU1Zc1IoPfBaFDPrunZRPyCv45jYF+snJB7+QhVDiz/vsWV0131n1Z6mcp1+abMHu
	 ZP7XqPQVX2Q642CtGeOwrRw3MurXVjKhJH5N7idHJ1Dbi/T/52GEn+YOvxk8byjM7hNBO
	 g3N8xi3Nj0OGDFM88mpgMeceEA4vrDOOBou+8N6K9xHoRAYa98+eHRT5UeL2ayiQ6tg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794765863;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 From:To:Cc:Subject:Date:Message-ID:X-Mailer:In-Reply-To:References:
	 MIME-Version:Content-Transfer-Encoding;
	bh=lxukKPljbLBMj2KQ1RVi2fh6LR+mPswpZnw+yWTHXAg=;
	b=qVg/+NPruEedaIEyNs3MsXCTB9LsN/LBl3DNRtrfigGRMdX8KmVVKBreyAfrcPzMe7Up
	 NZF3Kqw+dJBitrtfhjyWPwJfyVjTHdrNsPpC9vnCJa44wdFsE3GVccysZJlwV6839Wnlt
	 fzivH9vGe/29ArQ4sGDVrrz7lQoofBLZwmMqWzxEYnTVfIlQotHxR4192VYQf4G8lw8bq
	 EMlJKq+bJb+fHe5wjxl89wW8qmrR3OnFpjQf/1MdEA6kYhG6LcCeOY1qAhH7cVNlFJSmQ
	 HkmOYRSUxqoT1x40VRLNB21eMz2GM/kXb2BE2LaWkK74VqxVFKEZjxaP8/8tmj3Q8vw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=gmail.com;
	spf=pass smtp.mailfrom=gmail.com;
	dkim=pass header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=DOC6fRFx;
	arc=none smtp.remote-ip=209.85.221.48
Received: from mail-wr1-f48.google.com (mail-wr1-f48.google.com [209.85.221.48])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 10977606BAEE
	for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2026 18:04:23 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 10977606BAEE
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=gmail.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=gmail.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.a=rsa-sha256 header.s=20260707 header.b=DOC6fRFx
Received: by mail-wr1-f48.google.com with SMTP id ffacd0b85a97d-48b001cd92bso1769638f8f.2
        for <linux-nfs@vger.kernel.org>; Sun, 15 Nov 2026 10:04:22 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20260707; t=1794765861; x=1795370661; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=lxukKPljbLBMj2KQ1RVi2fh6LR+mPswpZnw+yWTHXAg=;
        b=DOC6fRFxtVO3+ChQZzvIui929ReJBuZRd50VNbS4+FpLPzHiYUk0WUdqprK6YJ0H9P
         stgxUdPJV/firlryJZiPgcjbYfkVubXUmYUllYeWbRbQj0/cU5mkXT5om3kdyMQmazN9
         rSzbjQkUbitjYgmgKsWufTocTnMfvmkDAI3Oxgjdc/MAagWI/qQz5Ra6UjVwmcaHZeVm
         RH2isjXoghK2pAMewo3C0p+jKCU0hHuAnA5pmR6eYCj9i2rADSzBqE9st7UzJZGd+ArT
         tNWRMhr+eF01OpI7T/wIq6nvVSPeZcy8RRet4KfN8DcM1geWKJD9t7OMvDUoWoupSPqc
         /XLg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1794765861; x=1795370661;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=lxukKPljbLBMj2KQ1RVi2fh6LR+mPswpZnw+yWTHXAg=;
        b=oPElfdy272yBznsQRWeVSGaMMGkxxL3q+bpuPLEJv5FLh+lnyVk5IVfFmoXElmkStD
         UcXvaid0BLMn9Y7RK4X0WO7Tb1pXGvkvz2Xt4B7UPQbKpPytn9/CRZ+r/XbK5w3oWhUk
         xfo96CBTOPk+6iDOLVXMTyXrRECuhddhHHRDsW78/s1LWZ541ZJeICE6RmSfY8xZymfN
         yYFxLXWqVKVFc6I62O1uvZQmQmkvtLfeUbo0ko9UFrElzWCicrkOLfO/Sx18t3DDTwgm
         eNEGqeG2YTa1pMiwoORlSE+H2Nto4okp3ziwINwAp3NRSypFPsrwzM4w0RGahxVtzn7q
         vAQw==
X-Forwarded-Encrypted: i=1; AL+hErGAjiAcIBa1/LtnDUAvQAFs3G2XeXN8iAOiUO96neJBZMvV/yLU9Sm3p6y2oUsPBLlFS63H7sKLMCw=@vger.kernel.org
X-Gm-Message-State: APuU4Z/rKnCspnYFRj/n9psMDaU+lDg7aRs+Bn1ZOMq2S5n2D3VlvP8K
	US394lShpQsE4WlhWtyZfNqVitaEp4BWX6m4gKw3VjH33Qb197x58IBD
X-Gm-Gg: AYBFou0KooxGHVt3IgdISPOSVY/EAtlCRW5lpLOBtc+llHDx9rGEFZl+GAnxtOd3mvG
	1uzvF/F3dCnhWGNjaKulXcFanDSdEm6IfSK8hQV8Gl4v/BCXe08Ou1GIsVMlB0JnbLVAo6tmbes
	lnTj9nwxIUcGUM9NNWqN64itYKR/1BLm3v39mDgf+0sEQDHgvQKbqFmZjQcpwkg1XuVKwtATLyU
	MISPqKvCWrHMMKrHdvfBiTgYHJrpU3aEJwsAKIqkgmEIhkUtuVHfoUb/iycK/jQqF0R1YfzAIHL
	B26w9kyZZriW8z1BiifxWmE7F3y0ES3VHHFkiQ1OnC+qdBiQkyZPOuuEeyykm88ne15PR64T9jC
	GJjtHN67ESN8knx0MjQ2J8T95Qc76kL98hpRJbNuVxZD198LOKEqSogU7UgwzwQ8oCVfLxSNjdR
	zFye46pxkCxWrivv9cxNuvEFl1bpGFBfqBhe0Vy7M4XNo6ksRcXFMRyloZHPTOMJ0fdv7q6OKOC
	P4WsKCTSQ6YdcQ8MBQI/fFZEUarnlnF4epn+zkLmhiIqjPSTafHMyIVpBvcnAnQwtDiBl409lLo
	xr7rcm7tcqOEnHX8wVQpNWrp6DC291vCVqVYIswv00M06Q==
X-Received: by 2002:a05:6000:461b:b0:48d:f7c0:97c0 with SMTP id ffacd0b85a97d-49c71b5c656mr18500790f8f.50.1794765861443;
        Sun, 15 Nov 2026 10:04:21 -0800 (PST)
Received: from infinity ([2001:b07:5d26:7a6a:365a:60ff:fe0d:cfc6])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-49c60f8c248sm17980448f8f.58.2026.11.15.10.04.18
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Sun, 15 Nov 2026 10:04:20 -0800 (PST)
From: koraynilay <koray.fra@gmail.com>
To: David Sterba <dsterba@suse.com>,
	Namjae Jeon <linkinjeon@kernel.org>,
	Sungjong Seo <sj1557.seo@samsung.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Christian Brauner <brauner@kernel.org>,
	Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Chuck Lever <cel@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	Konstantin Komarov <almaz.alexandrovich@paragon-software.com>,
	Paulo Alcantara <pc@manguebit.org>
Cc: Chris Mason <mason@kernel.org>,
	Yuezhang Mo <yuezhang.mo@sony.com>,
	Jan Kara <jack@suse.cz>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Ronnie Sahlberg <ronniesahlberg@gmail.com>,
	Shyam Prasad N <sprasad@microsoft.com>,
	Bharath SM <bharathsm@microsoft.com>,
	Sergey Senozhatsky <senozhatsky@chromium.org>,
	ChenXiaoSong <chenxiaosong@chenxiaosong.com>,
	"Darrick J . Wong" <djwong@kernel.org>,
	Sean Smith <defendthedisabled@gmail.com>,
	Andrey Albershteyn <aalbersh@kernel.org>,
	Pedro Falcato <pfalcato@suse.de>,
	Amir Goldstein <amir73il@gmail.com>,
	=?UTF-8?q?Pali=20Roh=C3=A1r?= <pali@kernel.org>,
	linux-btrfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	exfat@lists.linux.dev,
	ntfs3@lists.linux.dev,
	linux-cifs@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	linux-api@vger.kernel.org,
	koraynilay <koray.fra@gmail.com>
Subject: [RFC PATCH v4 10/10] cifs: add provenance time (ptime) and map it to SMB's CreationTime
Date: Sun, 15 Nov 2026 19:03:43 +0100
Message-ID: <20261115180343.576773-11-koray.fra@gmail.com>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261115180343.576773-1-koray.fra@gmail.com>
References: <20261115180343.576773-1-koray.fra@gmail.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

Implement provenance time (ptime) in cifs, as introduced in a
previous commit ("vfs: add provenance time (ptime)").

Map it to SMB's CreationTime, making it settable from userspace and
propagating it to the SMB server via FILE_BASIC_INFO.

Support reading ptime via statx(2) and fileattr_get() from the cached
CreationTime.

Update cifs_fileattr_set() to check xflags instead of only legacy flags
and add the cifs_set_file_crtime() helper to wrap the RPC call to the
SMB server.

Assisted-by: Gemini:3.8-flash-high antigravity-cli-1.5.7
Signed-off-by: koraynilay <koray.fra@gmail.com>
---
 fs/smb/client/cifsfs.c |   8 +++
 fs/smb/client/inode.c  |   7 ++-
 fs/smb/client/ioctl.c  | 109 ++++++++++++++++++++++++++++++-----------
 3 files changed, 94 insertions(+), 30 deletions(-)

diff --git a/fs/smb/client/cifsfs.c b/fs/smb/client/cifsfs.c
index 8cff7857b450..c2f557e406d3 100644
--- a/fs/smb/client/cifsfs.c
+++ b/fs/smb/client/cifsfs.c
@@ -1307,6 +1307,14 @@ int cifs_fileattr_get(struct dentry *dentry, struct file_kattr *fa)
 	if (READ_ONCE(CIFS_I(inode)->cifsAttrs) & ATTR_COMPRESSED)
 		fa->flags |= FS_COMPR_FL;
 
+	/* Report provenance time (ptime) to userspace */
+	if (CIFS_I(inode)->createtime) {
+		fa->fsx_xflags |= FS_XFLAG_PTIME;
+		fa->fsx_xflags_mask |= FS_XFLAG_PTIME;
+		fa->fsx_ptime =
+		      cifs_NTtimeToUnix(cpu_to_le64(CIFS_I(inode)->createtime));
+	}
+
 	/*
 	 * FS_CASEFOLD_FL is defined by UAPI as a folder attribute,
 	 * and userspace tools (e.g., lsattr) display it only on
diff --git a/fs/smb/client/inode.c b/fs/smb/client/inode.c
index 2647785ec1e4..f0b20a72b9c2 100644
--- a/fs/smb/client/inode.c
+++ b/fs/smb/client/inode.c
@@ -222,6 +222,7 @@ cifs_fattr_to_inode(struct inode *inode, struct cifs_fattr *fattr,
 
 	cifs_i->cifsAttrs = fattr->cf_cifsattrs;
 	cifs_i->reparse_tag = fattr->cf_cifstag;
+	cifs_i->createtime = fattr->cf_createtime;
 
 	if (fattr->cf_flags & CIFS_FATTR_NEED_REVAL)
 		cifs_i->time = 0;
@@ -2958,7 +2959,8 @@ int cifs_getattr(const struct mnt_idmap *idmap, const struct path *path,
 	 * We need to be sure that all dirty pages are written and the server
 	 * has actual ctime, mtime and file length.
 	 */
-	if ((request_mask & (STATX_CTIME | STATX_MTIME | STATX_SIZE | STATX_BLOCKS)) &&
+	if ((request_mask & (STATX_CTIME | STATX_MTIME | STATX_PTIME
+			     | STATX_SIZE | STATX_BLOCKS)) &&
 	    !CIFS_CACHE_READ(CIFS_I(inode)) &&
 	    inode->i_mapping && inode->i_mapping->nrpages != 0) {
 		rc = filemap_fdatawait(inode->i_mapping);
@@ -2992,6 +2994,9 @@ int cifs_getattr(const struct mnt_idmap *idmap, const struct path *path,
 		stat->result_mask |= STATX_BTIME;
 		stat->btime =
 		      cifs_NTtimeToUnix(cpu_to_le64(CIFS_I(inode)->createtime));
+		stat->result_mask |= STATX_PTIME;
+		stat->ptime =
+		      cifs_NTtimeToUnix(cpu_to_le64(CIFS_I(inode)->createtime));
 	}
 
 	stat->attributes_mask |= (STATX_ATTR_COMPRESSED | STATX_ATTR_ENCRYPTED);
diff --git a/fs/smb/client/ioctl.c b/fs/smb/client/ioctl.c
index bb8808289a46..19a9556d39b4 100644
--- a/fs/smb/client/ioctl.c
+++ b/fs/smb/client/ioctl.c
@@ -181,6 +181,41 @@ static int cifs_set_compression(unsigned int xid, struct dentry *dentry,
 					    compression_state);
 }
 
+static int cifs_set_file_crtime(unsigned int xid, struct dentry *dentry,
+				struct cifs_tcon *tcon, u64 crtime)
+{
+	struct inode *inode = d_inode(dentry);
+	struct TCP_Server_Info *server = tcon->ses->server;
+	FILE_BASIC_INFO	info_buf = {};
+	const char *full_path;
+	void *page;
+	int rc;
+
+	if (!server->ops->set_file_info)
+		return -EOPNOTSUPP;
+
+	info_buf.CreationTime = cpu_to_le64(crtime);
+
+	page = alloc_dentry_path();
+	full_path = build_path_from_dentry(dentry, page);
+	if (IS_ERR(full_path)) {
+		rc = PTR_ERR(full_path);
+		goto out;
+	}
+
+	rc = server->ops->set_file_info(inode, full_path, &info_buf, xid);
+	if (rc == 0) {
+		CIFS_I(inode)->createtime = crtime;
+		CIFS_I(inode)->time = 0;
+		inode_set_ctime_current(inode);
+	}
+
+out:
+	free_dentry_path(page);
+	return rc;
+}
+
+#define CIFS_SUPPORTED_XFLAGS (FS_XFLAG_PTIME)
 int cifs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
 		      struct file_kattr *fa)
 {
@@ -193,49 +228,65 @@ int cifs_fileattr_set(const struct mnt_idmap *idmap, struct dentry *dentry,
 	bool enable_compression;
 	struct cifs_tcon *tcon;
 	unsigned int xid;
-	int rc;
+	int rc = 0;
 
-	if (!fa->flags_valid)
+	if (fileattr_has_fsx_mask(fa, CIFS_SUPPORTED_XFLAGS))
 		return -EOPNOTSUPP;
 
-	/*
-	 * chattr writes back all flags returned by fileattr_get(). Accept
-	 * FS_CASEFOLD_FL only when it reflects the share's casefold state.
-	 */
-	if (fa->flags & FS_CASEFOLD_FL) {
-		rc = cifs_fileattr_get(dentry, &current_fa);
-		if (rc)
-			return rc;
-		if (current_fa.flags & FS_CASEFOLD_FL)
-			allowed |= FS_CASEFOLD_FL;
-	}
-	if (fa->flags & ~allowed)
+	if (fa->fsx_xflags_mask & ~CIFS_SUPPORTED_XFLAGS)
 		return -EOPNOTSUPP;
 
-	enable_compression = fa->flags & FS_COMPR_FL;
-	compression_state = enable_compression ? COMPRESSION_FORMAT_DEFAULT :
-						 COMPRESSION_FORMAT_NONE;
+	if (fa->flags_valid) {
+		/*
+		 * chattr writes back all flags returned by fileattr_get(). Accept
+		 * FS_CASEFOLD_FL only when it reflects the share's casefold state.
+		 */
+		if (fa->flags & FS_CASEFOLD_FL) {
+			rc = cifs_fileattr_get(dentry, &current_fa);
+			if (rc)
+				return rc;
+			if (current_fa.flags & FS_CASEFOLD_FL)
+				allowed |= FS_CASEFOLD_FL;
+		}
+		if (fa->flags & ~allowed)
+			return -EOPNOTSUPP;
+	}
 
 	tlink = cifs_sb_tlink(cifs_sb);
 	if (IS_ERR(tlink))
 		return PTR_ERR(tlink);
 	tcon = tlink_tcon(tlink);
-
 	xid = get_xid();
-	rc = cifs_set_compression(xid, dentry, tcon, NULL, compression_state);
-	free_xid(xid);
-	cifs_put_tlink(tlink);
 
-	if (!rc) {
-		spin_lock(&inode->i_lock);
-		if (enable_compression)
-			CIFS_I(inode)->cifsAttrs |= FILE_ATTRIBUTE_COMPRESSED;
-		else
-			CIFS_I(inode)->cifsAttrs &= ~FILE_ATTRIBUTE_COMPRESSED;
-		spin_unlock(&inode->i_lock);
+	/* modern xflags */
+	if (fa->fsx_valid) {
+		if (fa->fsx_xflags_mask & FS_XFLAG_PTIME) {
+			rc = cifs_set_file_crtime(xid, dentry, tcon,
+						  cifs_UnixTimeToNT(fa->fsx_ptime));
+			if (rc)
+				goto out;
+		}
+	} else if (fa->flags_valid) { /* legacy flags */
+		enable_compression = fa->flags & FS_COMPR_FL;
+		compression_state = enable_compression ? COMPRESSION_FORMAT_DEFAULT :
+							 COMPRESSION_FORMAT_NONE;
+
+		rc = cifs_set_compression(xid, dentry, tcon, NULL, compression_state);
+
+		if (!rc) {
+			spin_lock(&inode->i_lock);
+			if (enable_compression)
+				CIFS_I(inode)->cifsAttrs |= FILE_ATTRIBUTE_COMPRESSED;
+			else
+				CIFS_I(inode)->cifsAttrs &= ~FILE_ATTRIBUTE_COMPRESSED;
+			spin_unlock(&inode->i_lock);
+		}
+		cifs_dbg(FYI, "set compress flag rc %d\n", rc);
 	}
 
-	cifs_dbg(FYI, "set compress flag rc %d\n", rc);
+out:
+	free_xid(xid);
+	cifs_put_tlink(tlink);
 	return rc;
 }
 
-- 
2.56.0

