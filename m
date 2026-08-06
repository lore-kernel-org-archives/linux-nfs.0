Received: from mail-wr1-f50.google.com (mail-wr1-f50.google.com [209.85.221.50])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1082C311C07
	for <linux-nfs@vger.kernel.org>; Thu,  6 Aug 2026 13:16:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=209.85.221.50
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786022190; cv=none; b=UofqDNxqRrQL7sGyMSA1v5W/rmFariDkvVQeagmnwSSZrvbeBI7Eahkyo3J8pdqGtyAi9yCPPqNW9SI+fY7P3X/gO2/3jpaDIT8yVze1JWfVyDyFttzqXwF41Zu6MKwV0VlY29qV5QWIyOl3lzLmgq70AGp3cklxs5rqIOaL8M4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786022190; c=relaxed/simple;
	bh=7kAomhb6e53r8rIny9kCGyKBlOW2ShEDjjR7DJ2ynH0=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version:Content-Type; b=h2kZmOQNzT2HqjcXAixv8xWyVMGOWwUSJz88xP4K92WSAkaKLCKBL9bfWTWFHmhtlVLXw6gBoN0VinebCaPXHnEl2sq1uM7hHubZ0RD6PpO/XkbeERKulXBDFaMQzKLpQMEoiNwYtGviPdPSNicDtgl+3r3zGhyH86n79h3o3CE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=vastdata.com; spf=pass smtp.mailfrom=vastdata.com; dkim=pass (2048-bit key) header.d=vastdata.com header.i=@vastdata.com header.b=W+s+hpb5; arc=none smtp.client-ip=209.85.221.50
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=quarantine dis=none) header.from=vastdata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=vastdata.com
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=vastdata.com header.i=@vastdata.com header.b="W+s+hpb5"
Received: by mail-wr1-f50.google.com with SMTP id ffacd0b85a97d-47f96c5b722so1358940f8f.0
        for <linux-nfs@vger.kernel.org>; Thu, 06 Aug 2026 06:16:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=vastdata.com; s=google; t=1786022183; x=1786626983; darn=vger.kernel.org;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :subject:cc:to:from:from:to:cc:subject:date:message-id:reply-to
         :content-type;
        bh=y/Zwkit5Beyg8TJohypXFFnY+jfrdIOt+JFwduNbirc=;
        b=W+s+hpb5RQILqrYn08L7tdX122wbpjJBoOs8iyQQ9RZV6/HOCN8K/GDbrxG3g0AY+E
         Q83E7a8j0N7JAHp0EP3pbQSd+8xfyLtJ9xftx6Sl/UXE9MCxlz2VkKpXXal+XaKhcAr8
         +dl+U00wE02fvU01tzr/unmWXpoLSAC6VjgbvOqBDUEwVlxWGds9M1MMQTTBCFWsUTLl
         mHT60DwULtU8iZGZe2OlEY4XZaauGdnQAZ0+aMHvJjRbc0eegnWSkR6rzZg1oKi2BqFA
         gbWItQx4OptXSK9YjCZgeu2K8XLDqUcgwOrp5F1uqAEBMzqiMhbkX+BwPvvg5+IZo+Cb
         U9ZQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20251104; t=1786022183; x=1786626983;
        h=content-transfer-encoding:content-type:mime-version:message-id:date
         :subject:cc:to:from:x-gm-gg:x-gm-message-state:from:to:cc:subject
         :date:message-id:reply-to:content-type;
        bh=y/Zwkit5Beyg8TJohypXFFnY+jfrdIOt+JFwduNbirc=;
        b=CMUqP4yT+mfhVyC2WDGes8EioYKQEHekEvHGpD3wk4ZqDrg2Ijweu64eV0MYopx7Ei
         Uh7S9A8UFNewLIY8JmRhT4FB29vqa1usmGQeWDQWe+EEd+72auxpW20iYfSGCg8vuS8J
         8vclhQnQh7DbzpcVGOVVPn9TM10dTuk455ou+YH6g8wm1JwxBfH+1Bojhde118Pn5w77
         iMy0XlQSx8+Xl173lJKpGM5qF4QMqM59MBKviOJEjEyKOQjzdorOrHiuKUtc1MrwzF6f
         mbn16d4Gf0bcjnMlPcOu5cpX1qkt2MOWgmW/TN138+09/uP9JW0VBX4bLTzN33GgRIMV
         /BHw==
X-Gm-Message-State: AOJu0YwAyVnhemNOTkovXSlqcJRm/PrxO0zNQQ4dhCaoFTsTn4RGr/sP
	4TBt843SZrkWMMgmxdvaMtfWOSNbPNzjk4giJY58DBSSZByNwfZRFextgYtuXG67tDIMM6fbXAe
	7vJU=
X-Gm-Gg: AR+sD12Mz6o3LHHzxiCIJ2HgiSXEKKh9DHvtSfYmacUeQEt82gWvbYwC7JkKfpTDzA1
	0LH6dePTvYsZ/EH49K8ayM++D2e6GLi3ZI9s7QX2AzXVBfy5CmpIRLWghWBvTNzm24GpujDKGr+
	qfpXBgH6dLcZiOI659483w3wZJd31ak+6Zj7iC8//8Ez1hQov20qEtYJhM7I0B53PfYMSnFEWIu
	OIcFyysIEn8aGCS5siy9tYA5ww3vXttedqE9KsvXihNtce1XFWIrbi8F2noeXHhtkGWDGo9Y5TK
	VLKHBu/sh7//nv80qsHFSQuZ6ttb7sgObCTOR1NF1TCBh1hJqvf+/RyMah92XOGAT/ib3wziu3v
	rys+GO3I3XMjNgcY9cM6I0roTM+LDk80BXE6rmx7LA1FIkEzDdzAyAuuVzycxhLO9xg/ByokZzC
	xFU6FkJuYUmKoU/nRpDIZNNNy/V+wRaqZP6XpFPgdGO7p3Fz9GOuEaeJ6quiwr6pR5wNjVToikw
	b/MbwVQ3s2I
X-Received: by 2002:a5d:5f46:0:b0:47f:fb57:8c7f with SMTP id ffacd0b85a97d-47ffb579060mr3710569f8f.29.1786022182810;
        Thu, 06 Aug 2026 06:16:22 -0700 (PDT)
Received: from l29.vastdata.com ([62.90.223.133])
        by smtp.gmail.com with ESMTPSA id ffacd0b85a97d-47ff79a7f07sm6654632f8f.8.2026.08.06.06.16.21
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 06 Aug 2026 06:16:22 -0700 (PDT)
From: Michael Nemanov <michael.nemanov@vastdata.com>
To: trondmy@kernel.org,
	anna@kernel.org,
	neil@brown.name
Cc: linux-nfs@vger.kernel.org,
	Michael Nemanov <michael.nemanov@vastdata.com>
Subject: [PATCH v2] nfs: fix ENXIO on O_CREAT open of existing symlink over NFSv3
Date: Thu,  6 Aug 2026 13:13:58 +0000
Message-ID: <20260806131358.398096-1-michael.nemanov@vastdata.com>
X-Mailer: git-send-email 2.43.7
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

When open(2) is called with O_CREAT on a path that already exists as a
symlink, over an NFSv3 mount with a cold dcache, the kernel returns
ENXIO instead of following the symlink to its target.

Reproducer script (MNT is an NFSv3 mount, kernel is 7.1-rc6):

MNT=/mnt/export
ln -sf /tmp/target $MNT/mylink
echo 3 | sudo tee /proc/sys/vm/drop_caches   # cold dcache

python3 - <<'EOF'
import os
fd = os.open('/mnt/export/mylink', os.O_WRONLY | os.O_CREAT | os.O_APPEND, 0o666)
os.close(fd)
EOF

Expected: success (follow symlink, open target)
Actual:   OSError: [Errno 6] No such device or address

The bug does not trigger when the dcache is warm (e.g. after a prior
stat(2)), because lookup_open() then finds a positive dentry and skips
atomic_open entirely, leaving symlink resolution to the VFS.

Root cause:
nfs_atomic_open_v23(), registered as inode->i_op->atomic_open for
NFSv3, handles O_CREAT by sending a CREATE UNCHECKED RPC. As
implemented in nfsd3_create_file() (fs/nfsd/nfs3proc.c) and as required
by RFC 1813 (3.3.8), when the name already exists as a non-regular file
the server returns NFS3_OK with the existing object's file handle rather
than NFS3ERR_EXIST causing nfs_do_create() to return 0 with the
dentry now pointing to a symlink.
The code then unconditionally calls finish_open(), which dispatches
through inode->i_fop->open(). Symlink inodes never have i_fop set — the
VFS initialises it to &no_open_fops because POSIX requires open(2) to
follow symlinks, never open them directly. no_open() returns -ENXIO.

Fix:
After nfs_do_create() succeeds, verify the returned inode is a regular
file before calling finish_open(). If the object is not regular, return
finish_no_open(file, NULL) so the VFS follows the symlink through the
normal open path. NULL is passed because nfs_do_create() instantiates
the inode on the dentry already owned by the caller; passing dentry back
would cause atomic_open() to dput() it a second time.
!S_ISREG() is used rather than S_ISLNK() to cover any other non-regular
types a server might return.

Changes in v2:
- Pass NULL to finish_no_open() per Trond's feedback.

Fixes: 7c6c5249f061 ("NFS: add atomic_open for NFSv3 to handle O_TRUNC correctly.")
Link: https://lore.kernel.org/linux-nfs/20260614122911.3485467-1-michael.nemanov@vastdata.com/ (v1)
Signed-off-by: Michael Nemanov <michael.nemanov@vastdata.com>
Tested-by: Michael Nemanov <michael.nemanov@vastdata.com>
---
 fs/nfs/dir.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index e9ce1883288c5..c3481d9c74334 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2317,6 +2317,13 @@ int nfs_atomic_open_v23(struct inode *dir, struct dentry *dentry,
 	if (open_flags & O_CREAT) {
 		error = nfs_do_create(dir, dentry, mode, open_flags);
 		if (!error) {
+			/* With UNCHECKED mode, a server may return NFS3_OK for
+			 * a pre-existing non-regular file (e.g. a symlink).
+			 * Let the VFS handle it; calling finish_open() would
+			 * hit no_open() and return -ENXIO.
+			 */
+			if (d_inode(dentry) && !S_ISREG(d_inode(dentry)->i_mode))
+				return finish_no_open(file, NULL);
 			file->f_mode |= FMODE_CREATED;
 			return finish_open(file, dentry, NULL);
 		} else if (error != -EEXIST || open_flags & O_EXCL)
-- 
2.43.7

