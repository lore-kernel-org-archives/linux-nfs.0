Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794653294;
	b=RSEF3tFsffKEiI5K7dllH3RR3/nuysQkcxopg32AOv5pO+zRFNbkDd+N1VNWcj7Y+KH+
	 coOr+hExHGaziIsxEpRBInZOBy4+NVy/Ll4ZCMnBuu/E4Z7p6r2h/QWrm99CWv/hYOGYO
	 XQG6YK8gccIs8Ih8EfpivSn23E1q7H+wvn0infKM5uljymzWUufYIDOl44HudariPMl99
	 IdD8f6fPA5xvHScaZLMi3TnGf5y39YdDX6N12A+5oXkxqidvYcQsqEz4EpsOEXU/cqz+c
	 qUClVbdYbyiizPqjngeo5xTtZvz7gQwAjhsDnIjC9FDLd4AlALVAaV9/pdKbfCwdiFg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794653294;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=vGWTylgMIW6bDfGEy5XmpsW+u1ufCFyjkH/RKGIHXn0=;
	b=XnVJbzLrvNEk1wh4iX5ftvZGt1FhRJC+P8mB4KckS1I3v3NrDed6f+yNWr2xN97rypqL
	 tf7/d8z50pXnFN1qR39UevVa3GC5WCg+tofOXTJLCDjZzCUVXyq5y380ngzTMiGBahCLW
	 i15ky8lvzvxFQ561YTbcUto9aeD3jHHpYFfFoXGLlBUimXHJmlL6ButRzQ84Kt1c6406a
	 uTzJhEl93Skwy/lDBsuV2B0kxbjFJX0xO9yrUKYX/rx67gzpaWUd0MlfCjrk3C4bG1wW1
	 wWQmuKmy25UGSyD46EAyIDxSewaeVw2RYeVzsq/DV5tUJVEjsgtExQ+IBsg4cg+hbPw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EyWY3Wu5;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E8776606B944;
	Sat, 14 Nov 2026 10:48:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=EyWY3Wu5
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1B0311F000CB;
	Sat, 14 Nov 2026 10:48:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794653293;
	bh=vGWTylgMIW6bDfGEy5XmpsW+u1ufCFyjkH/RKGIHXn0=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=EyWY3Wu58zEoCxtb5WbL0z2Ayd+gjjHzDO7txKKPA1YhQJvnHL1PTS8lEZxElEB0g
	 AhNsQMCINjMgGRsbDsWmSqnGqoU/BivjjrWur8rJfE9RC4KdzGZtIXxbcAwRaYQy1Z
	 Ojr8jNew/2BX+SigNFB8Jeg4o9PAtHdyK7p+TjixfUSFc8gsOuehKilR/75pulg5Ku
	 8A1LDVvLYgkkZKd3CxnN5hvaO6JYrweaibUqtn9/amldVV+Sdg2RYsAWxawhGHPlAw
	 0aepGUp1SGgD1kRxgaGvcjRFI9MycXpizgBshWt7J8Qp+E3m0o82x/SposJHqbrp40
	 lBOq5d/aB3H+w==
From: Christian Brauner <brauner@kernel.org>
Date: Sat, 14 Nov 2026 11:47:14 +0100
Subject: [PATCH 07/12] zloop: take freeze protection when recording write
 pointers
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
Message-Id: <20261114-work-fs-frozen_writes-v1-7-f5ae61c898b1@kernel.org>
References: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
In-Reply-To: <20261114-work-fs-frozen_writes-v1-0-f5ae61c898b1@kernel.org>
To: Jan Kara <jack@suse.cz>
Cc: Shakeel Butt <shakeel.butt@linux.dev>, 
 Alexander Viro <viro@zeniv.linux.org.uk>, Jens Axboe <axboe@kernel.dk>, 
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, 
 io-uring@vger.kernel.org, Christoph Hellwig <hch@lst.de>, 
 linux-block@vger.kernel.org, linux-nvme@lists.infradead.org, 
 linux-scsi@vger.kernel.org, target-devel@vger.kernel.org, 
 linux-unionfs@vger.kernel.org, bpf@vger.kernel.org, 
 linux-nfs@vger.kernel.org, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev-ce4c1
X-Developer-Signature: v=1; a=openpgp-sha256; l=1947; i=brauner@kernel.org;
 h=from:subject:message-id; bh=5Gd0N7r8AM/cUjKKWUZKwiYPW9YLwh3Lgt9pJFTrtzc=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9sHF1eLQz/MXHTs/t3M65XyeGd3v96FVe7iit8r9Ub
 l/uOTf+jlIWBjEuBlkxRRaHdpNwueU8FZuNMjVg5rAygQxh4OIUgIkUKzAyHGZ1ffnKoGL5DoGg
 3bX70xL95N/3PQtdq6f24lDi7B2Guxj+5+1u2GDgI7Jp+ewOJo1iNSNvmV2hZxYom/cdrtryavU
 PTgA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

With discard_write_cache a flush records the write pointer of each
active zone in an xattr of its zone file. zloop_record_safe_wps() uses
vfs_setxattr() for that which leaves freeze protection to the caller.
So a flush rewrites the xattrs on a filesystem that is frozen. With the
zone files on ext4:

  WARNING: fs/ext4/ext4_jbd2.c:90 at ext4_journal_check_start+0x1f6/0x2d0, CPU#0: kworker/u16:2/46
  Workqueue: zloop0 zloop_cmd_workfn
  Call Trace:
   <TASK>
   __ext4_journal_start_sb+0x7a/0x470
   ext4_xattr_set+0x20d/0x380
   __vfs_setxattr+0x10f/0x170
   __vfs_setxattr_noperm+0xf4/0x5e0
   vfs_setxattr+0x14d/0x3d0
   zloop_cmd_workfn+0x384/0x1ff0
   process_one_work+0x946/0x1820
   worker_thread+0x4f1/0xd60
   kthread+0x364/0x460
   ret_from_fork+0x525/0x770
   ret_from_fork_asm+0x1a/0x30
   </TASK>

Take freeze protection around vfs_setxattr() with mnt_want_write_file()
like fsetxattr() does.

Fixes: 829def1e35ca ("zloop: forget write cache on force removal")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 drivers/block/zloop.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/block/zloop.c b/drivers/block/zloop.c
index 34ed925e86f1a..a695aa8405d22 100644
--- a/drivers/block/zloop.c
+++ b/drivers/block/zloop.c
@@ -730,8 +730,13 @@ static int zloop_record_safe_wps(struct zloop_device *zlo)
 
 		if (!zloop_zone_is_active(zone))
 			continue;
-		ret = vfs_setxattr(file_mnt_idmap(file), file_dentry(file),
-				"user.zloop.wp", &zone->wp, sizeof(zone->wp), 0);
+		ret = mnt_want_write_file(file);
+		if (!ret) {
+			ret = vfs_setxattr(file_mnt_idmap(file),
+					file_dentry(file), "user.zloop.wp",
+					&zone->wp, sizeof(zone->wp), 0);
+			mnt_drop_write_file(file);
+		}
 		if (ret) {
 			pr_err("%pg: failed to record write pointer (%d)\n",
 				zlo->disk->part0, ret);

-- 
2.53.0

