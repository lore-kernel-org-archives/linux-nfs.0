Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BB6F92C0281
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2026 18:53:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769194386; cv=none; b=I8bx99CRdjf7e1LdV5rOuKqLNmzEuLt1HTUf2/MEkG4BbO+w3QJOt+6tbHtV8NVChKUf4o5IS4yFE4r9DuR4mHBddgYO6r+6t3eYqoIvhTduNAHE9kAq/+gBH2EoKy3+lg0uK75JXoYpMqjxGUBARkOnnT5NxXuX8Gf2CgW4SHU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769194386; c=relaxed/simple;
	bh=YWNg5Cp7aj0q2W89PgTgldnAN/YyMNvUrlLO9cs6myU=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version; b=eroieyHvS5/yulQQYbA9erSrR+Jx4S0uANx6ExDhuSnbMERVcYYItJaFAEjI+qycwcQaIEVlHIX8DPmJdqQlcDZJq25f/6Tr1/Xj/+v0Xk641heMsED+FmYiAW6G9BltCwmX0t4Zd712NxdXTqYlxcz/KWTmFVlTidaN8caCJJM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=A4yQJz6L; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="A4yQJz6L"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C36A7C116D0;
	Fri, 23 Jan 2026 18:53:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769194386;
	bh=YWNg5Cp7aj0q2W89PgTgldnAN/YyMNvUrlLO9cs6myU=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=A4yQJz6LpuZF9BBB3aSUCVgHWTG6bF0NYglCxGKdZlSg2B+whKJt5cJTsV1clOyPa
	 516zKoDZWM78cHCu3ABdOSp+dfhMyaFM9Bnj40HPrncF8pukftBjvhKGAHBnMIsjVd
	 xqnJL/oILlXPYQQdaWtIdCp8qvluKdhToERJquRm61d9JbcID+eyP6YNo3YDTtEQKz
	 nC7KHHUxBoe3DwQjrqpAUsdTg2y0aLgUgU0Lon+8vJm1+0d6wbnoa0Bq+eEAgW7tY3
	 ppqBM536qN0RqLz8mAPod6tlb1Qcf+l8Xapb69TDa2WHep57RhBFcfYm+aEE38zPKf
	 YURLYA1rZqCOQ==
From: Chuck Lever <cel@kernel.org>
To: NeilBrown <neilb@ownmail.net>,
	Jeff Layton <jlayton@kernel.org>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <dai.ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>
Cc: <linux-nfs@vger.kernel.org>,
	Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH v2 04/42] lockd: Relocate nlmsvc_unlock API declarations
Date: Fri, 23 Jan 2026 13:52:21 -0500
Message-ID: <20260123185259.1215767-5-cel@kernel.org>
X-Mailer: git-send-email 2.52.0
In-Reply-To: <20260123185259.1215767-1-cel@kernel.org>
References: <20260123185259.1215767-1-cel@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

The nlmsvc_unlock_all_by_sb() and nlmsvc_unlock_all_by_ip()
functions are part of lockd's external API, consumed by other
kernel subsystems. Their declarations currently reside in
linux/lockd/lockd.h alongside internal implementation details,
which blurs the boundary between lockd's public interface and
its private internals.

Moving these declarations to linux/lockd/bind.h groups them
with other external API functions and makes the separation
explicit. This clarifies which functions are intended for
external use and reduces the risk of internal implementation
details leaking into the public API surface.

Build-tested with allyesconfig; no functional changes.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/lockd.c             | 1 +
 fs/nfsd/nfsctl.c            | 2 +-
 include/linux/lockd/bind.h  | 7 +++++++
 include/linux/lockd/lockd.h | 6 ------
 4 files changed, 9 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/lockd.c b/fs/nfsd/lockd.c
index 6fe1325815e0..ca805b708a30 100644
--- a/fs/nfsd/lockd.c
+++ b/fs/nfsd/lockd.c
@@ -8,6 +8,7 @@
  */
 
 #include <linux/file.h>
+#include <linux/fs.h>
 #include <linux/lockd/bind.h>
 #include "nfsd.h"
 #include "vfs.h"
diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 30caefb2522f..ed0588f72133 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -11,7 +11,7 @@
 #include <linux/fs_context.h>
 
 #include <linux/sunrpc/svcsock.h>
-#include <linux/lockd/lockd.h>
+#include <linux/lockd/bind.h>
 #include <linux/sunrpc/addr.h>
 #include <linux/sunrpc/gss_api.h>
 #include <linux/sunrpc/rpc_pipe_fs.h>
diff --git a/include/linux/lockd/bind.h b/include/linux/lockd/bind.h
index 2f5dd9e943ee..82eca0a13ccc 100644
--- a/include/linux/lockd/bind.h
+++ b/include/linux/lockd/bind.h
@@ -21,6 +21,7 @@
 struct svc_rqst;
 struct rpc_task;
 struct rpc_clnt;
+struct super_block;
 
 /*
  * This is the set of functions for lockd->nfsd communication
@@ -80,4 +81,10 @@ extern int	nlmclnt_proc(struct nlm_host *host, int cmd, struct file_lock *fl, vo
 extern int	lockd_up(struct net *net, const struct cred *cred);
 extern void	lockd_down(struct net *net);
 
+/*
+ * Cluster failover support
+ */
+int nlmsvc_unlock_all_by_sb(struct super_block *sb);
+int nlmsvc_unlock_all_by_ip(struct sockaddr *server_addr);
+
 #endif /* LINUX_LOCKD_BIND_H */
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 7bf402e772b0..fe6a14fe959a 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -311,12 +311,6 @@ void		  nlmsvc_mark_resources(struct net *);
 void		  nlmsvc_free_host_resources(struct nlm_host *);
 void		  nlmsvc_invalidate_all(void);
 
-/*
- * Cluster failover support
- */
-int           nlmsvc_unlock_all_by_sb(struct super_block *sb);
-int           nlmsvc_unlock_all_by_ip(struct sockaddr *server_addr);
-
 static inline struct file *nlmsvc_file_file(const struct nlm_file *file)
 {
 	return file->f_file[O_RDONLY] ?
-- 
2.52.0

