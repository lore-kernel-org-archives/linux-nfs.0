Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794827461;
	b=vhyS6nVwCAImSeJmzmP2aXbNYo58P0CfyhNVUE9ARBuRB1FjvlTbIrLRuEYWCQLYDBu5
	 cSWq8CQY6iQTpaJSFBZGvoWUbIdZ2PKUwL9jqXcpdh4glvEVesrN/xeOKSOEXgneJ4pC5
	 Sid6QL/F15RatYpU66z8SZxURjmVj8w4WFv6NY6UuFGire+PUXTOKPK5oVAeQroZ0Wo1U
	 f0n2ds8+0S3z30w318pEq4OxkUd0NKSrS7UDbcMS68PBr8VbWF2ZDphJzFkwJ1dNSPKTY
	 iCJ4J9Fyty30FL3FUguzAvqAYQFAcBlJn7p81NRyd5MoVL8cBdMhY9XsldkELWzYJdg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794827461;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=+1Ha5ASlzziEtpwFumlx1jHdeafb0Uk6ledTOHN/+BQ=;
	b=CzApHuPSJkqa9v+NqMJvKErrMleFF7uQ+OBa+9yzO881CoEhzCc/ZqCEag81Rk4vszgm
	 QPAkv9hitUeZ5hFANpGDQ++aNfLdysTt4W0HD2cMitS4m88ce06cVNZDso7E/ORmhY5Ib
	 YvX0dAKv6784KhY/27jVYiWKyS7UmfYJqgYOcN/NOEEP+MxyLK0/GvqEHhGFqTRtd/o2V
	 ZcZbC/FfSk96KbUaJBFdqx5z+06zGOBBcYGd6OIHekg41mrf8ky1ZhImQVIfvLTY1mhnl
	 1sxKhGNCdt1e14QD9ijZddz3VouysaSUy+cO8JGLvQoY8blVvJx56kjpLV6B0rVLRag==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=N0jLVzlU;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 95B516071B10;
	Mon, 16 Nov 2026 11:11:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=N0jLVzlU
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B256B1F000C4;
	Mon, 16 Nov 2026 11:10:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794827461;
	bh=+1Ha5ASlzziEtpwFumlx1jHdeafb0Uk6ledTOHN/+BQ=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=N0jLVzlUI4/sjWNYOt0rXQTtyrgdKf5Y0kTKuip2dZyDj+4g/Ze7OYrLUiUsPPEye
	 CjUN4xKWTGOixjV4KcD/jZgCYY6N/+4Z8JHcT7hLcQcrx8q02xe7tYXpY71+xQEHQi
	 DyFRbLRY7DB9BBOX6LHXYX8dkO5Z1aVdfUmhEIvTLaHSBWeb+l8zD8roBzYXX4rqBT
	 yE74qV89FpLs5TJU9EwHKj4pCX4TE4X3Kq2ekdC7rThFYLz4eNiPgoOfUI1au18Vyn
	 pkNLVmlzaNlj37i5uxQXej7cjjXciz8n3fqCszEa5y6nV+Axoq1qL8ATP7YBXt6Xvi
	 rOa1KxM4tYdvg==
From: Christian Brauner <brauner@kernel.org>
Date: Mon, 16 Nov 2026 12:05:13 +0100
Subject: [PATCH RFC v3 40/44] fuse: refuse files on pseudo filesystems as
 passthrough backing files
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
Message-Id: <20261116-work-loop-pseudo-v3-40-8cbbea1cf34f@kernel.org>
References: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
In-Reply-To: <20261116-work-loop-pseudo-v3-0-8cbbea1cf34f@kernel.org>
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
X-Developer-Signature: v=1; a=openpgp-sha256; l=3093; i=brauner@kernel.org;
 h=from:subject:message-id; bh=Qkr0BYXyDd+I7xUdfK34CTesF8mQyxzVRm4u7QW4pjc=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9etz7YYleq5CAw4X4sGW+b2Uz1jbJrH8r5vBSK3KaB
 H95VsCxjlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgImcncTI8K+t9HbCCqNJecsr
 BR3atl39NOkGq5CQkcDVYiVj2Y+rnRkZWv6WG+e4sr/I3r2+LPNhivaEm6fb0rycv4m/V7qxpnQ
 JFwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

The fuse server can register any regular file as a backing file. procfs
and binfmt_misc files are already refused by the stacking depth check as
both set s_stack_depth to FILESYSTEM_MAX_STACK_DEPTH. sysfs and the
other pseudo filesystems aren't. Reads and writes of the fuse file would
then be done on the pseudo file with the fuse server's credentials.
Refuse files on pseudo filesystems just like loop does.

Note that the backing file is only registered here and opened again for
every fuse file that uses it. Only its path is used and O_PATH file
descriptors are allowed since commit efad7153bf93 ("fuse: allow O_PATH
fd for FUSE_DEV_IOC_BACKING_OPEN"). So pass FMODE_PATH to
file_check_backing() to keep them working.

The file that reads and writes are actually done on is opened in
fuse_passthrough_open() with the flags of the fuse file. So check that
file as well and pass the mode the fuse file was opened with. It has
the same path as the registered file so files on pseudo filesystems are
already refused. But this also makes sure that the backing file
implements ->read_iter() if the fuse file is opened for reading and
->write_iter() if it is opened for writing. Like the other failures to
set up passthrough this fails the open with EIO.

Reviewed-by: Amir Goldstein <amir73il@gmail.com>
Suggested-by: Amir Goldstein <amir73il@gmail.com>
Link: https://lore.kernel.org/all/CAOQ4uxhGxpBtMZ5kfuzR1tQAewiecoX7UjXQRo91QjJHH9T_Yw@mail.gmail.com
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/fuse/backing.c     | 4 ++++
 fs/fuse/passthrough.c | 7 +++++++
 2 files changed, 11 insertions(+)

diff --git a/fs/fuse/backing.c b/fs/fuse/backing.c
index 8c21a8a74efb9..7527f3ecb90dc 100644
--- a/fs/fuse/backing.c
+++ b/fs/fuse/backing.c
@@ -147,6 +147,10 @@ static int fuse_backing_open_file(struct fuse_conn *fc, struct fuse_backing *fb,
 		if (inode->i_sb->s_stack_depth >= fc->max_stack_depth)
 			return -ELOOP;
 
+		err = file_check_backing(file, FMODE_PATH, 0);
+		if (err)
+			return err;
+
 		fb->type = FUSE_BACKING_PATH;
 		fb->path = file->f_path;
 		path_get(&fb->path);
diff --git a/fs/fuse/passthrough.c b/fs/fuse/passthrough.c
index 0ed964c479d96..fc8979ac96a21 100644
--- a/fs/fuse/passthrough.c
+++ b/fs/fuse/passthrough.c
@@ -183,6 +183,7 @@ int fuse_passthrough_open(struct file *file, struct fuse_backing *fb)
 {
 	struct fuse_file *ff = file->private_data;
 	struct file *backing_file;
+	int err;
 
 	if (fb->type == FUSE_BACKING_EXTMAP) {
 		if (fuse_backing_is_dax(fb) != !!IS_DAX(file_inode(file)))
@@ -201,6 +202,12 @@ int fuse_passthrough_open(struct file *file, struct fuse_backing *fb)
 	if (IS_ERR(backing_file))
 		return fuse_EIO("failed to open backing file (%ld)", PTR_ERR(backing_file));
 
+	err = file_check_backing(backing_file, file->f_mode & (FMODE_READ | FMODE_WRITE), 0);
+	if (err) {
+		fput(backing_file);
+		return fuse_EIO("invalid backing file (%d)", err);
+	}
+
 	ff->passthrough = backing_file;
 	ff->cred = get_cred(fb->cred);
 

-- 
2.53.0

