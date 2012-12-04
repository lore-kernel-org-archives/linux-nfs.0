Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:7881 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752036Ab2LDNtv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2012 08:49:51 -0500
Subject: [PATCH 4/6] nfsd: pass net to nfsd_svc()
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 04 Dec 2012 16:50:22 +0300
Message-ID: <20121204135022.24504.70799.stgit@localhost.localdomain>
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
 fs/nfsd/nfsctl.c |    4 +++-
 fs/nfsd/nfsd.h   |    2 +-
 fs/nfsd/nfssvc.c |    3 +--
 3 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index ae1d143..68e229c 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -396,6 +396,8 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
 {
 	char *mesg = buf;
 	int rv;
+	struct net *net = &init_net;
+
 	if (size > 0) {
 		int newthreads;
 		rv = get_int(&mesg, &newthreads);
@@ -403,7 +405,7 @@ static ssize_t write_threads(struct file *file, char *buf, size_t size)
 			return rv;
 		if (newthreads < 0)
 			return -EINVAL;
-		rv = nfsd_svc(newthreads);
+		rv = nfsd_svc(newthreads, net);
 		if (rv < 0)
 			return rv;
 	} else
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index acddf71..8226c1b 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -65,7 +65,7 @@ extern const struct seq_operations nfs_exports_op;
 /*
  * Function prototypes.
  */
-int		nfsd_svc(int nrservs);
+int		nfsd_svc(int nrservs, struct net *net);
 int		nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp);
 
 int		nfsd_nrthreads(void);
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 6448391..f199b53 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -442,11 +442,10 @@ int nfsd_set_nrthreads(int n, int *nthreads)
  * this is the first time nrservs is nonzero.
  */
 int
-nfsd_svc(int nrservs)
+nfsd_svc(int nrservs, struct net *net)
 {
 	int	error;
 	bool	nfsd_up_before;
-	struct net *net = &init_net;
 
 	mutex_lock(&nfsd_mutex);
 	dprintk("nfsd: creating service\n");

