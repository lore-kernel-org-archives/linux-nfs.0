Return-Path: linux-nfs-owner@vger.kernel.org
Received: from oproxy10-pub.bluehost.com ([67.222.39.61]:34502 "HELO
	oproxy10-pub.bluehost.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1752279Ab2G0Suc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 27 Jul 2012 14:50:32 -0400
Message-ID: <5012E2B6.5010009@xenotime.net>
Date: Fri, 27 Jul 2012 11:49:26 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
MIME-Version: 1.0
To: Stephen Rothwell <sfr@canb.auug.org.au>
CC: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
        linux-nfs@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH -next] nfs: fix stub return type warnings
References: <20120727142126.15a52335cda4c39d5c120c49@canb.auug.org.au>
In-Reply-To: <20120727142126.15a52335cda4c39d5c120c49@canb.auug.org.au>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Randy Dunlap <rdunlap@xenotime.net>

Fix numerous repeated warnings by making the stub function
void instead of non-void:

fs/nfs/nfs4_fs.h: In function 'nfs4_unregister_sysctl':
fs/nfs/nfs4_fs.h:385:1: warning: no return statement in function returning non-void

Signed-off-by: Randy Dunlap <rdunlap@xenotime.net>
Cc:	Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/nfs4_fs.h |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- linux-next-20120727.orig/fs/nfs/nfs4_fs.h
+++ linux-next-20120727/fs/nfs/nfs4_fs.h
@@ -380,7 +380,7 @@ static inline int nfs4_register_sysctl(v
 	return 0;
 }
 
-static inline int nfs4_unregister_sysctl(void)
+static inline void nfs4_unregister_sysctl(void)
 {
 }
 #endif
