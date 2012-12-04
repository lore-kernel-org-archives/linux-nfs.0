Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:6688 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752036Ab2LDNtq (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2012 08:49:46 -0500
Subject: [PATCH 3/6] nfsd: pass net to nfsd_create_serv()
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 04 Dec 2012 16:50:16 +0300
Message-ID: <20121204135016.24504.74168.stgit@localhost.localdomain>
In-Reply-To: <20121204134920.24504.95261.stgit@localhost.localdomain>
References: <20121204134920.24504.95261.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Precursor patch. Hard-coded "init_net" will be replaced by proper one in
future.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfsctl.c |    4 ++--
 fs/nfsd/nfsd.h   |    2 +-
 fs/nfsd/nfssvc.c |    5 ++---
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index e13cbdd..ae1d143 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -664,7 +664,7 @@ static ssize_t __write_ports_addfd(char *buf)
 	if (err != 0 || fd < 0)
 		return -EINVAL;
 
-	err = nfsd_create_serv();
+	err = nfsd_create_serv(net);
 	if (err != 0)
 		return err;
 
@@ -696,7 +696,7 @@ static ssize_t __write_ports_addxprt(char *buf)
 	if (port < 1 || port > USHRT_MAX)
 		return -EINVAL;
 
-	err = nfsd_create_serv();
+	err = nfsd_create_serv(net);
 	if (err != 0)
 		return err;
 
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 5eea0f5..acddf71 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -103,7 +103,7 @@ enum vers_op {NFSD_SET, NFSD_CLEAR, NFSD_TEST, NFSD_AVAIL };
 int nfsd_vers(int vers, enum vers_op change);
 int nfsd_minorversion(u32 minorversion, enum vers_op change);
 void nfsd_reset_versions(void);
-int nfsd_create_serv(void);
+int nfsd_create_serv(struct net *net);
 
 extern int nfsd_max_blksize;
 
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 21cba3d..6448391 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -334,10 +334,9 @@ static int nfsd_get_default_max_blksize(void)
 	return ret;
 }
 
-int nfsd_create_serv(void)
+int nfsd_create_serv(struct net *net)
 {
 	int error;
-	struct net *net = &init_net;
 
 	WARN_ON(!mutex_is_locked(&nfsd_mutex));
 	if (nfsd_serv) {
@@ -459,7 +458,7 @@ nfsd_svc(int nrservs)
 	if (nrservs == 0 && nfsd_serv == NULL)
 		goto out;
 
-	error = nfsd_create_serv();
+	error = nfsd_create_serv(net);
 	if (error)
 		goto out;
 

