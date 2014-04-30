Return-Path: linux-nfs-owner@vger.kernel.org
Received: from [119.145.14.65] ([119.145.14.65]:30435 "EHLO
	szxga02-in.huawei.com" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1753565AbaD3CrR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2014 22:47:17 -0400
From: Weng Meiling <wengmeiling.weng@huawei.com>
To: <stable@vger.kernel.org>
CC: <bfields@fieldses.org>, <greg@kroah.com>, <lizefan@huawei.com>,
        <skinsbursky@parallels.com>, <h.huangqiang@huawei.com>,
        <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 3.4 3/9] nfsd: pass net to nfsd_create_serv()
Date: Wed, 30 Apr 2014 10:43:38 +0800
Message-ID: <1398825824-6360-4-git-send-email-wengmeiling.weng@huawei.com>
In-Reply-To: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
References: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Stanislav Kinsbursky <skinsbursky@parallels.com>

commit 6777436b0f072fb20a025a73e9b67a35ad8a5451 upstream.

Precursor patch. Hard-coded "init_net" will be replaced by proper one in
future.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
[wengmeiling: backport to 3.4: adjust context]
Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
---
 fs/nfsd/nfsctl.c | 4 ++--
 fs/nfsd/nfsd.h   | 2 +-
 fs/nfsd/nfssvc.c | 5 ++---
 3 files changed, 5 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index d014727..e18f0a5 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -657,7 +657,7 @@ static ssize_t __write_ports_addfd(char *buf)
 	if (err != 0 || fd < 0)
 		return -EINVAL;
 
-	err = nfsd_create_serv();
+	err = nfsd_create_serv(net);
 	if (err != 0)
 		return err;
 
@@ -708,7 +708,7 @@ static ssize_t __write_ports_addxprt(char *buf)
 	if (port < 1 || port > USHRT_MAX)
 		return -EINVAL;
 
-	err = nfsd_create_serv();
+	err = nfsd_create_serv(net);
 	if (err != 0)
 		return err;
 
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 1336a65..356da43 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -101,7 +101,7 @@ enum vers_op {NFSD_SET, NFSD_CLEAR, NFSD_TEST, NFSD_AVAIL };
 int nfsd_vers(int vers, enum vers_op change);
 int nfsd_minorversion(u32 minorversion, enum vers_op change);
 void nfsd_reset_versions(void);
-int nfsd_create_serv(void);
+int nfsd_create_serv(struct net *net);
 
 extern int nfsd_max_blksize;
 
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index f8dae75..632d11e 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -326,10 +326,9 @@ static int nfsd_get_default_max_blksize(void)
 	return ret;
 }
 
-int nfsd_create_serv(void)
+int nfsd_create_serv(struct net *net)
 {
 	int error;
-	struct net *net = &init_net;
 
 	WARN_ON(!mutex_is_locked(&nfsd_mutex));
 	if (nfsd_serv) {
@@ -451,7 +450,7 @@ nfsd_svc(unsigned short port, int nrservs)
 	if (nrservs == 0 && nfsd_serv == NULL)
 		goto out;
 
-	error = nfsd_create_serv();
+	error = nfsd_create_serv(net);
 	if (error)
 		goto out;
 
-- 
1.8.2.2


