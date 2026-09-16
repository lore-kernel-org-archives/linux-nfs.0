Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 73B3A4BF940
	for <linux-nfs@vger.kernel.org>; Wed, 16 Sep 2026 20:43:38 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789591435; cv=none; b=MEoS2QSgepzruDVu07MyrK4wn6XYp4pv6JSPNy13ihoQ8OCgcFoSrpig9KP/xHX4ABd7cpwqifGa9ciPgVVG+gdvL6VEEDWHC3XcmwFkRHwIFcx78ZqXCZmoJJKl4j0cyMGVDTQ61lbOXHLYRhVVjKMu+76Y0zkZ5uDApsdqgZ0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789591435; c=relaxed/simple;
	bh=ohVRhTe1m7dwmTYpwijcEjmydJXDpHrmxxZFCo1CDYY=;
	h=From:To:Cc:Subject:Date:Message-ID:MIME-Version; b=QhYv+EMHeXuM9wu4KFPLD6aTbG99gUmXCAC50AVz7/n6y7lEL15ErFSEWSN8WMd9DtVYtD34kxJRl4n4aZnTh1LWCpTIp2PR0JdfvJMM7mU9/q7UeZAAXkMCDjnhJJSjCr4yxkXE5++qA/g15Mpk/pRFAC/+idiADn/Wp4v5QtQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=T6KnggcW; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="T6KnggcW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 19E561F000FF;
	Wed, 16 Sep 2026 20:43:37 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789591417;
	bh=ZwYciFDCfK/0BnffaxpAe3y46E1qmez40qWtdGfs9Cc=;
	h=From:To:Cc:Subject:Date;
	b=T6KnggcWDk1NzwEtfkz6lxTRiFrphVijfX1TmDggHwLy/MJHb8BL+tccBBE5qSkRU
	 Y9Puj3CzfpqIxWvdkf/f5hleZcPfPr/bXh6O7NcPe9eH3cAoH2BGKkKilmzfEO/fo7
	 C2tQjgGmq4zrUNkFeajq0Q0UlUox2/jAoj49I6IX0Ina4nBKqvzMGix/yl+Z2XN/5A
	 +B0a29xxFPZYoXaeUegF3jf8ni7FOZA877+yDIEVSSTMiuryLrTZsGz2WLVaArux24
	 Py9lVh1OcmpJT142T/Xywrx9Dqwe7/Y4GWUML9MCPT+GUzIahGDpbPT1625pa/vczQ
	 NaLmh56wjVjMA==
From: Chuck Lever <cel@kernel.org>
To: Anna Schumaker <anna@kernel.org>,
	Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: [PATCH v1] NFS: use TCP for MOUNT when xprtsec= selects TLS
Date: Wed, 16 Sep 2026 16:43:36 -0400
Message-ID: <20260916204336.14436-1-cel@kernel.org>
X-Mailer: git-send-email 2.55.0
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

An NFSv2 or NFSv3 text mount that specifies xprtsec= but no
mountproto= crashes in nfs_init_timeout_values():

  RIP: 0010:nfs_init_timeout_values+0x10a/0x110 [nfs]
  Call Trace:
   nfs_mount+0x1c3/0x330 [nfs]
   nfs_try_get_tree+0x1e5/0x460 [nfs]
   nfs_get_tree+0x64d/0x6d0 [nfs]
   vfs_get_tree+0x2b/0xe0
   vfs_cmd_create+0x5f/0xd0
   vfs_fsconfig_locked+0x50/0x130
   __se_sys_fsconfig+0x2f9/0x3a0

nfs_validate_transport_protocol() sets nfs_server.protocol to
XPRT_TRANSPORT_TCP_TLS when xprtsec= is present, but the switch in
nfs_set_mount_transport_protocol() has no case for that value.
mount_server.protocol stays zero, and nfs_init_timeout_values()
calls BUG() on a transport it does not recognize.

mount.nfs always appends mountproto= after probing the server's
rpcbind, so only a caller that bypasses it, such as "mount -i" or a
program that drives fsconfig() directly, reaches the crash.

Select TCP for MOUNT when the NFS transport is XPRT_TRANSPORT_TCP_TLS.
nfs_mount() requests no transport security, so MOUNT already runs
over plain TCP whenever mount.nfs supplies mountproto=tcp.

Fixes: c8407f2e560c ("NFS: Add an "xprtsec=" NFS mount option")
Signed-off-by: Chuck Lever <cel@kernel.org>
---
 fs/nfs/fs_context.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/fs_context.c b/fs/nfs/fs_context.c
index 1967de7d1dff..a7393ff05494 100644
--- a/fs/nfs/fs_context.c
+++ b/fs/nfs/fs_context.c
@@ -402,6 +402,7 @@ static void nfs_set_mount_transport_protocol(struct nfs_fs_context *ctx)
 		ctx->mount_server.protocol = XPRT_TRANSPORT_UDP;
 		break;
 	case XPRT_TRANSPORT_TCP:
+	case XPRT_TRANSPORT_TCP_TLS:
 	case XPRT_TRANSPORT_RDMA:
 		ctx->mount_server.protocol = XPRT_TRANSPORT_TCP;
 	}
-- 
2.55.0

