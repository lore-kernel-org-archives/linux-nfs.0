Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 03533288C81
	for <linux-nfs@vger.kernel.org>; Mon, 26 Jan 2026 19:55:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769457348; cv=none; b=tWOL/Bd+a4+xKqEn969TZGnALO5T1nrbpF+NanViRzqqwZeMMOv6PXijA2F9HFEh7Q6aBvbemlIde35f2pofBGNgkBSaTQBtwOrNccn4KqpiO8YZATfSkSCDiWuBHe02564atbkfAgAhkUyvnZ9wD18J/UW839EFave+jhnzozY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769457348; c=relaxed/simple;
	bh=2/2Xksq7Ur/hcMGl3/PVSCaqMPqbmRA7zkoleQQp0vM=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=KAWnfkKCDI8e3NVbgK8zirTAkrnB7gFKZ3tb32uKNYLrGZrppnISU2HgJgwwlke2WcxaFOtmEzkhKa1oLTdtyc44xZR3a4TQtWlRXsjtBCj+bMM+487nWsnoMtRNoYl5STXjc/tIh4Y/U53m357up3XoZzzFOtC8KehdpuVfZFg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=JmBFUyBr; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="JmBFUyBr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 55CA7C2BC86;
	Mon, 26 Jan 2026 19:55:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769457347;
	bh=2/2Xksq7Ur/hcMGl3/PVSCaqMPqbmRA7zkoleQQp0vM=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=JmBFUyBrgZ+gvWch56cbCVjpi1R9UhPWMgm+eSR6oZvf4wryA0A8B9fv8dzSxEkry
	 C1OvlBEMwNIGJ4vR+Ji/PHyrlyVhisT9fbWDffaO0dFU9eIXXssFMPnYETJznrTdW5
	 Zv51/IFqLEHbRLPctnTZrVOlbBQN6J6B/H/J2I+5OAYWbsBoiSfeFuc0SjSzr0LVRT
	 MYWCLD5J1KRAFd8r6YtR4IFGm//3nc1wY4WdNcMGKW0Ss7EGqXtRWGgYGPGZPyRU7m
	 6MoKanFIX2kSYJySftcD6nSAJQFVKHTOxbusH7MuiQBlS6Ah39MHIPuqVfTwzMea1j
	 9YvlZpVpyom5g==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v3 12/14] lockd: Make linux/lockd/nlm.h an internal header
Date: Mon, 26 Jan 2026 14:55:33 -0500
Message-ID: <20260126195535.154697-13-cel@kernel.org>
X-Mailer: git-send-email 2.52.0
In-Reply-To: <20260126195535.154697-1-cel@kernel.org>
References: <20260126195535.154697-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

The NLM protocol constants and status codes in nlm.h are needed
only by lockd's internal implementation. NFS client code and
NFSD interact with lockd through the stable API in bind.h and
have no direct use for protocol-level definitions.

Exposing these definitions globally via bind.h creates unnecessary
coupling between lockd internals and its consumers. Moving nlm.h
from include/linux/lockd/ to fs/lockd/ clarifies the API boundary:
bind.h provides the lockd service interface, while nlm.h remains
available only to code within fs/lockd/ that implements the
protocol.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/lockd/lockd.h                  | 1 +
 {include/linux => fs}/lockd/nlm.h | 8 +++-----
 fs/lockd/svclock.c                | 1 -
 include/linux/lockd/bind.h        | 2 --
 4 files changed, 4 insertions(+), 8 deletions(-)
 rename {include/linux => fs}/lockd/nlm.h (91%)

diff --git a/fs/lockd/lockd.h b/fs/lockd/lockd.h
index 6f83b9a7257f..e73c6b348154 100644
--- a/fs/lockd/lockd.h
+++ b/fs/lockd/lockd.h
@@ -14,6 +14,7 @@
 #include <linux/kref.h>
 #include <linux/refcount.h>
 #include <linux/utsname.h>
+#include "nlm.h"
 #include <linux/lockd/bind.h>
 #include "xdr.h"
 #include <linux/sunrpc/debug.h>
diff --git a/include/linux/lockd/nlm.h b/fs/lockd/nlm.h
similarity index 91%
rename from include/linux/lockd/nlm.h
rename to fs/lockd/nlm.h
index 6e343ef760dc..47be65d0111f 100644
--- a/include/linux/lockd/nlm.h
+++ b/fs/lockd/nlm.h
@@ -1,14 +1,12 @@
 /* SPDX-License-Identifier: GPL-2.0 */
 /*
- * linux/include/linux/lockd/nlm.h
- *
  * Declarations for the Network Lock Manager protocol.
  *
  * Copyright (C) 1996, Olaf Kirch <okir@monad.swb.de>
  */
 
-#ifndef LINUX_LOCKD_NLM_H
-#define LINUX_LOCKD_NLM_H
+#ifndef _LOCKD_NLM_H
+#define _LOCKD_NLM_H
 
 
 /* Maximum file offset in file_lock.fl_end */
@@ -55,4 +53,4 @@ enum {
 #define NLMPROC_NM_LOCK		22
 #define NLMPROC_FREE_ALL	23
 
-#endif /* LINUX_LOCKD_NLM_H */
+#endif /* _LOCKD_NLM_H */
diff --git a/fs/lockd/svclock.c b/fs/lockd/svclock.c
index 10e3937ad69f..572446113d35 100644
--- a/fs/lockd/svclock.c
+++ b/fs/lockd/svclock.c
@@ -28,7 +28,6 @@
 #include <linux/sched.h>
 #include <linux/sunrpc/clnt.h>
 #include <linux/sunrpc/svc_xprt.h>
-#include <linux/lockd/nlm.h>
 
 #include "lockd.h"
 
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index 38d69fe8dfd5..4572e8958a81 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -10,8 +10,6 @@
 #ifndef LINUX_LOCKD_BIND_H
 #define LINUX_LOCKD_BIND_H
 
-#include <linux/lockd/nlm.h>
-
 struct nfs_fh;
 struct svc_rqst;
 struct rpc_task;
-- 
2.52.0

