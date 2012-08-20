Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:32883 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756713Ab2HTWvE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Aug 2012 18:51:04 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/3] nfsd4: declare nfs4_recoverydir properly
Date: Mon, 20 Aug 2012 18:50:59 -0400
Message-Id: <1345503060-8892-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1345503060-8892-1-git-send-email-bfields@redhat.com>
References: <1345503060-8892-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfsctl.c |    2 --
 fs/nfsd/nfsd.h   |    2 ++
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index fa49cff..009632a 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -1008,8 +1008,6 @@ static ssize_t write_gracetime(struct file *file, char *buf, size_t size)
 	return nfsd4_write_time(file, buf, size, &nfsd4_grace);
 }
 
-extern char *nfs4_recoverydir(void);
-
 static ssize_t __write_recoverydir(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 2244222..36243a3 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -124,6 +124,7 @@ int nfs4_state_start(void);
 void nfs4_state_shutdown(void);
 void nfs4_reset_lease(time_t leasetime);
 int nfs4_reset_recoverydir(char *recdir);
+char * nfs4_recoverydir(void);
 #else
 static inline void nfs4_state_init(void) { }
 static inline int nfsd4_init_slabs(void) { return 0; }
@@ -132,6 +133,7 @@ static inline int nfs4_state_start(void) { return 0; }
 static inline void nfs4_state_shutdown(void) { }
 static inline void nfs4_reset_lease(time_t leasetime) { }
 static inline int nfs4_reset_recoverydir(char *recdir) { return 0; }
+static inline char * nfs4_recoverydir(void) {return NULL; }
 #endif
 
 /*
-- 
1.7.9.5

