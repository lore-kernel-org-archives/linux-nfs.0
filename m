Return-Path: linux-nfs-owner@vger.kernel.org
Received: from [119.145.14.65] ([119.145.14.65]:30411 "EHLO
	szxga02-in.huawei.com" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752215AbaD3CrQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2014 22:47:16 -0400
From: Weng Meiling <wengmeiling.weng@huawei.com>
To: <stable@vger.kernel.org>
CC: <bfields@fieldses.org>, <greg@kroah.com>, <lizefan@huawei.com>,
        <skinsbursky@parallels.com>, <h.huangqiang@huawei.com>,
        <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 3.4 4/9] nfsd: pass net to nfsd_svc()
Date: Wed, 30 Apr 2014 10:43:39 +0800
Message-ID: <1398825824-6360-5-git-send-email-wengmeiling.weng@huawei.com>
In-Reply-To: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
References: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Stanislav Kinsbursky <skinsbursky@parallels.com>

commit d41a9417cd89a69f58a26935034b4264a2d882d6 upstream.

Precursor patch. Hard-coded "init_net" will be replaced by proper one in
future.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
[wengmeiling: backport to 3.4:
 - adjust context
 - one more parameter(int port) for nfsd_svc()]
Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
---
 fs/nfsd/nfsctl.c | 4 +++-
 fs/nfsd/nfsd.h   | 2 +-
 fs/nfsd/nfssvc.c | 3 +--
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index e18f0a5..9463bc0 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -389,6 +389,8 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
 	int rv;
+	struct net *net = &init_net;
+
 	if (size > 0) {
 		int newthreads;
 		rv = get_int(&mesg, &newthreads);
@@ -396,7 +398,7 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
 			return rv;
 		if (newthreads < 0)
 			return -EINVAL;
-		rv = nfsd_svc(NFS_PORT, newthreads);
+		rv = nfsd_svc(NFS_PORT, newthreads, net);
 		if (rv < 0)
 			return rv;
 	} else
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 356da43..5007654 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -65,7 +65,7 @@ extern const struct seq_operations nfs_exports_op;
 /*
  * Function prototypes.
  */
-int		nfsd_svc(unsigned short port, int nrservs);
+int		nfsd_svc(unsigned short port, int nrservs, struct net *net);
 int		nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp);
 
 int		nfsd_nrthreads(void);
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 632d11e..b8aea64 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -434,11 +434,10 @@ int nfsd_set_nrthreads(int n, int *nthreads)
  * this is the first time nrservs is nonzero.
  */
 int
-nfsd_svc(unsigned short port, int nrservs)
+nfsd_svc(unsigned short port, int nrservs, struct net *net)
 {
 	int	error;
 	bool	nfsd_up_before;
-	struct net *net = &init_net;
 
 	mutex_lock(&nfsd_mutex);
 	dprintk("nfsd: creating service\n");
-- 
1.8.2.2


