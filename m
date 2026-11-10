Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794302384;
	b=Q1HX1rX2nv/SRS1hrRZ8ePxHXR7iCcUNg6j4irydAM1zop4O7bkz18dyUrGbRT/oGPWq
	 w9kwzfHYFaQ2UBBtaIo7bpOQA6CzH9cq89BTMYrTX5818kx+Kl/WlVJo2cNE8fE0BPn1u
	 Mawm+Zl4ZHKpaLGnIIS51VlGogmKGHbQjfrekqxYNUE+ofixthvRPFeiAzIAAzYTSpbx3
	 6Rox1CMcF8A9YmITkzL5OIniVrLHKbCGQWtXLYoolgEF3hOKiJ5t+yoMtHNXXRt1xQl8s
	 9V+dES8yupV6N1tJgjp11CoKfyB35GSM2wCs/rhJQHWeFVeWGZFBCiAc7ekwRizR2yg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794302384;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=XL0wpOwuozhlRhYNz0JipJ6kxKX4QenBWX0X6ItK/K0=;
	b=G4lz9Z/g06jFQOA6o4jPhTZKKphi1279MzBfsL3xSdzuU03Fmex9PwQNFch6R/e+B9xa
	 W3JgHtvxsNBL0r29uc0sXcdOkHSOQMsIi6iYjBLMO+stw+unjgzHHhVWe5EdZvyKphmJV
	 kYJP2ov+akaeBI5isL9nVF60sJPJK8VOogqVPpX4q49oQN2yDOLPZAfmzBl3NBTJhv+3E
	 4iLXolmI2Jts7H8Rj/4OQ3gXgmhKEY4bzJjc9edAp/QGTsYE7vqar51qwdqH57BYX6X1A
	 NdeQEOrbokYlEKXTy6H5NS9HKf+6f/kF+altIwePEWlXNm+es/A/dG9W31ZRdLrNEGA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CT+iOXhf;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AE21F6079C26;
	Tue, 10 Nov 2026 09:19:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=CT+iOXhf
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E32A91F008A4;
	Tue, 10 Nov 2026 09:19:36 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794302383;
	bh=XL0wpOwuozhlRhYNz0JipJ6kxKX4QenBWX0X6ItK/K0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=CT+iOXhfdXS9EjWhCPxyMwbc6qpk2mfT/FYG65nH7AnMeSTgDu4gtnvPph9s+gyJQ
	 ZvCsMu20agRk/DN1s3jOLTDIaiE9C33mbBH7UBmpmq1UA5VoUIzICSYA9Tg4ndMgTH
	 NUHn4RW/Rt1Efr1DcrgvT2Czb0YSTQrx0YgABhREHnhLrge2ohMdRAEXc8ARjQ95GB
	 N91PcDylNuNGgoO+A1oWCOdoVMTmydTR6bkBvDN7xjUC6o/rf57lsPcqiLH9lVYbog
	 fqTRi61Xug5bUX+nw+zLWjcrBruwnR9lQKJTUUtPpS/C/b7PBRlfrij5xhG51EYia0
	 M4TkDbL2tSeqg==
From: Christian Brauner <brauner@kernel.org>
Date: Tue, 10 Nov 2026 10:14:49 +0100
Subject: [PATCH RFC 33/41] fs: add file_is_pseudo()
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Message-Id: <20261110-work-loop-pseudo-v1-33-4c998976c6c7@kernel.org>
References: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
In-Reply-To: <20261110-work-loop-pseudo-v1-0-4c998976c6c7@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: Jann Horn <jannh@google.com>, Chris Mason <mason@kernel.org>, 
 Josef Bacik <josef@toxicpanda.com>, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-kernel@vger.kernel.org, 
 linux-nvme@lists.infradead.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Jan Kara <jack@suse.cz>, linux-scsi@vger.kernel.org, 
 target-devel@vger.kernel.org, driver-core@lists.linux.dev, 
 linux-mm@kvack.org, bpf@vger.kernel.org, 
 linux-security-module@vger.kernel.org, selinux@vger.kernel.org, 
 apparmor@lists.ubuntu.com, linux-nfs@vger.kernel.org, 
 netdev@vger.kernel.org, fuse-devel@lists.linux.dev, 
 linux-efi@vger.kernel.org, xen-devel@lists.xenproject.org, 
 ocfs2-devel@lists.linux.dev, linux-s390@vger.kernel.org, 
 linuxppc-dev@lists.ozlabs.org, linux-usb@vger.kernel.org, 
 Amir Goldstein <amir73il@gmail.com>, linux-erofs@lists.ozlabs.org, 
 linux-kselftest@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1523; i=brauner@kernel.org;
 h=from:subject:message-id; bh=fWtwbOqSVGrzkIOODqoKjdbZebK5p812wmLNWmDsq10=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWR9erDr3MIVGoy6T1c42Fn1zN66UCnoG5vsrbwj8gcLt
 77hOtpb11HKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRhFRGhmevWgXzbBfJf9i+
 0PPiiVlFPwKL+Fc/UFjp/vmC/tGfMw8y/FNqqr0U8TxATPOxjuYj+fU+8bu+/uDa1s7jnDCrjX2
 /FhMA
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

Add a helper to check whether a file is a regular file on a pseudo
filesystem. Only regular files count. Device nodes on pseudo filesystems
such as devpts, binderfs or the block devices on bdevfs are what they
are.

Look at the inode that actually provides the data via d_real_inode().
overlayfs accepts sysfs, cgroup2, debugfs, tracefs, configfs and
securityfs as lower layers and reads of such an overlayfs file are
served by the file on the pseudo filesystem. Checking the overlayfs
inode would miss that.

No functional changes.

Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 include/linux/fs.h | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 99caef43ff3c..407ffb6342ec 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -2553,6 +2553,18 @@ static inline const struct inode *file_user_inode(const struct file *f)
 	return file_inode(f);
 }
 
+/*
+ * Regular files on pseudo filesystems are kernel interfaces and must not be
+ * used as storage. Look through stacking filesystems at the inode that
+ * provides the data.
+ */
+static inline bool file_is_pseudo(const struct file *file)
+{
+	const struct inode *inode = d_real_inode(file->f_path.dentry);
+
+	return S_ISREG(inode->i_mode) && (inode->i_sb->s_iflags & SB_I_PSEUDO);
+}
+
 static inline struct file *file_clone_open(struct file *file)
 {
 	return dentry_open(&file->f_path, file->f_flags, file->f_cred);

-- 
2.53.0

