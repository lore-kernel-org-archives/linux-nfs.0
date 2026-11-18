Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795007807;
	b=gZd0tSF/g7XJqulfe9aTW0GCbGairf1GJ/OT+sTg5ybZU82Mr5D6QRRd8VteTka9xba7
	 o95FfE7/69VLmUe/YH8pC9pZLbPAVuhxSqiSfygCJj8xx9rKq6lHyeYaKXGenAMxa5D4Q
	 GGJN5mknJPMCrJbCusTyAXPWnX14av31W/mhMCgkIbD1UcR7bYHSXtHq9fgBSOY/Btr6b
	 dZ/6KgPovCOKRvS5emY2hCZ8eDJL00JyYfO0B/QCI694b/Mn8E5/37VPDsSRL/w7kMGG8
	 Zcc+gr4OGN7pWzRPKL1SoWxnwjf5UJ+EtK53yZn3vRrriVzY7x4bztNGwrfHRJA6PHA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795007807;
	h=Received:DKIM-Signature:From:Date:Subject:MIME-Version:Content-Type:
	 Content-Transfer-Encoding:Message-Id:References:In-Reply-To:To:Cc:
	 X-Mailer:X-Developer-Signature:X-Developer-Key;
	bh=CR+E1bRGy+jkpAi4tD+qyGoEqwHX5pXB8QpxemAdSZo=;
	b=tmsVtlXr+p9fgejFH3Dr987d91O7jTu3je9P2deNaQ6k2ROLBftxPdLn67Jim0W/uu6h
	 owpMP/M2/Ggsxk3L+eDSNwbbN0n730goPg1U5ibnGq1qPFStR708qC0EmkOipCzpCzZys
	 NwrrQAyplpDJIKkgb2S7njhsQei4RhNCdKRnt+tHJoDGlgJu0WcnCqK8a2t6vaVP643Tv
	 6k+Za5e69UZgiHKl5Kki/uDGzouPvNiyjTz80KiLAcHwa2pn3NlhQDYKW2xB2qqnnizzF
	 gKySJHNiw5OBAupdtJByxQROvmgrbFXigueLyqPsKCWkkFeff8VskOTfGjFai0SaqBQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R05bb917;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C9B01606A331;
	Wed, 18 Nov 2026 13:16:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=R05bb917
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 592A71F000C4;
	Wed, 18 Nov 2026 13:16:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795007807;
	bh=CR+E1bRGy+jkpAi4tD+qyGoEqwHX5pXB8QpxemAdSZo=;
	h=From:Date:Subject:References:In-Reply-To:To:Cc;
	b=R05bb917AdmhBwWHZVe6VaYbHwPrMNPSXjjry2qEiHt+C1OyqFQ06OiZE2auKry4m
	 GR0NR4BGdSP0gLnK4sUQbYxtxx323yCVehWSLcX6llKhEbyH5rJ5IEBNuWAWgG7iPl
	 rhlj7WxqGKYH7M1JL/E0ZrcWOn9r2gCJl1nPhVDVVlpaepHL5HTtewhkH1miCh+ume
	 9qmmxrII/WfZXnSXVfA4np7FkD+4+jt9ccX3wRHw7GbKkkO94BhMYTH0RUJChQAI+1
	 3eU6OXnVY5iP/ojQxFjDRdNMOUUYN92ETrIHMWBgo3FBcznJVWyGJinYhW3kSJ9orT
	 92558h14t/CpA==
From: Christian Brauner <brauner@kernel.org>
Date: Wed, 18 Nov 2026 14:16:18 +0100
Subject: [PATCH 2/2] fhandle: don't warn about multi-root filesystems
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
Message-Id: <20261118-work-nfs-multiroot-v1-2-66e4458b7d32@kernel.org>
References: <20261118-work-nfs-multiroot-v1-0-66e4458b7d32@kernel.org>
In-Reply-To: <20261118-work-nfs-multiroot-v1-0-66e4458b7d32@kernel.org>
To: linux-fsdevel@vger.kernel.org
Cc: linux-nfs@vger.kernel.org, Alexander Viro <viro@zeniv.linux.org.uk>, 
 Jan Kara <jack@suse.cz>, Chuck Lever <cel@kernel.org>, 
 Jeff Layton <jlayton@kernel.org>, Amir Goldstein <amir73il@gmail.com>, 
 "Christian Brauner (Amutable)" <brauner@kernel.org>, stable@vger.kernel.org
X-Mailer: b4 0.17-dev-04696
X-Developer-Signature: v=1; a=openpgp-sha256; l=2405; i=brauner@kernel.org;
 h=from:subject:message-id; bh=NoD43R4Ikusm+jKrw678i5OjqLPNWC4Kyx7Fj2FDdIU=;
 b=owGbwMvMwCU28Zj0gdSKO4sYT6slMWT9XWry3Cru0vQtz0+0d4stfRe45eFZrb82SgKpU9/rf
 FfObGC62lHKwiDGxSArpsji0G4SLrecp2KzUaYGzBxWJpAhDFycAjCRBYcYGbof9itw9bevY0+b
 ZVGXMaGtLVenIEir9dXmnxNLVWJ63zIyXLokydaeXm/51sGq2uzSjUuhLZG3W7fMeV6feputsU2
 OHwA=
X-Developer-Key: i=brauner@kernel.org; a=openpgp;
 fpr=4880B8C9BD0E5106FC070F4F7B3C391EFEA93624

When I relaxed the permission checks for open_by_handle_at() in
commit 620c266f3949 ("fhandle: relax open_by_handle_at() permission
checks") I added a warning for when walking up from a decoded directory
ends neither at the root of the mount fd nor at the root of the
superblock. But a superblock can have more than one root. nfs shares a
superblock between mounts of disjoint subtrees of the same server
filesystem and each of them has its own root dentry. If the decoded
directory lives below one of the other roots the walk ends there and we
warn.

Mount two subdirectories of the same export with vers=3, encode a
directory below the second mount with name_to_handle_at() and decode it
from a new user and mount namespace with open_by_handle_at() and the
first mount as the mount fd:

  WARNING: fs/fhandle.c:260 at vfs_dentry_acceptable+0x2e3/0x4b0
  Call Trace:
   <TASK>
   exportfs_decode_fh_raw+0x1de/0x840
   do_handle_open+0x46e/0xb20
   do_syscall_64+0x110/0x600
   entry_SYSCALL_64_after_hwframe+0x77/0x7f
   </TASK>

The handle is still refused because the directory isn't reachable from
the mount fd. But an unprivileged user can trigger the warning if the
directories involved belong to them, e.g. if their home directory is
one of the mounts.

Don't warn for superblocks with multiple roots. This depends on the
previous patch reintroducing SB_I_MULTIROOT.

Fixes: 620c266f3949 ("fhandle: relax open_by_handle_at() permission checks")
Cc: stable@vger.kernel.org
Signed-off-by: Christian Brauner (Amutable) <brauner@kernel.org>
---
 fs/fhandle.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/fhandle.c b/fs/fhandle.c
index 32fcff14f88fd..8e6110215469d 100644
--- a/fs/fhandle.c
+++ b/fs/fhandle.c
@@ -254,9 +254,11 @@ static int vfs_dentry_acceptable(void *context, struct dentry *dentry)
 	/*
 	 * exportfs_decode_fh_raw() does not call acceptable() callback with
 	 * a disconnected directory dentry, so we should have reached either
-	 * mount fd directory or sb root.
+	 * mount fd directory or sb root. Multi-root filesystems have more
+	 * than one root.
 	 */
-	if (ctx->fh_flags & EXPORT_FH_DIR_ONLY)
+	if ((ctx->fh_flags & EXPORT_FH_DIR_ONLY) &&
+	    !(root->d_sb->s_iflags & SB_I_MULTIROOT))
 		WARN_ON_ONCE(d != root && d != root->d_sb->s_root);
 	dput(d);
 	return retval;

-- 
2.53.0

