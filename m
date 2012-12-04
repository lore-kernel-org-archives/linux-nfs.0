Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:36162 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753895Ab2LDNt5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 4 Dec 2012 08:49:57 -0500
Subject: [PATCH 5/6] nfsd: pass net to nfsd_set_nrthreads()
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Tue, 04 Dec 2012 16:50:27 +0300
Message-ID: <20121204135027.24504.79673.stgit@localhost.localdomain>
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
 fs/nfsd/nfsctl.c |    3 ++-
 fs/nfsd/nfsd.h   |    2 +-
 fs/nfsd/nfssvc.c |    3 +--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 68e229c..58f0ae4 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -447,6 +447,7 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 	int len;
 	int npools;
 	int *nthreads;
+	struct net *net = &init_net;
 
 	mutex_lock(&nfsd_mutex);
 	npools = nfsd_nrpools();
@@ -477,7 +478,7 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 			if (nthreads[i] < 0)
 				goto out_free;
 		}
-		rv = nfsd_set_nrthreads(i, nthreads);
+		rv = nfsd_set_nrthreads(i, nthreads, net);
 		if (rv)
 			goto out_free;
 	}
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 8226c1b..18f9996 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -71,7 +71,7 @@ int		nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp);
 int		nfsd_nrthreads(void);
 int		nfsd_nrpools(void);
 int		nfsd_get_nrthreads(int n, int *);
-int		nfsd_set_nrthreads(int n, int *);
+int		nfsd_set_nrthreads(int n, int *, struct net *);
 int		nfsd_pool_stats_open(struct inode *, struct file *);
 int		nfsd_pool_stats_release(struct inode *, struct file *);
 
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index f199b53..b144658 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -382,12 +382,11 @@ int nfsd_get_nrthreads(int n, int *nthreads)
 	return 0;
 }
 
-int nfsd_set_nrthreads(int n, int *nthreads)
+int nfsd_set_nrthreads(int n, int *nthreads, struct net *net)
 {
 	int i = 0;
 	int tot = 0;
 	int err = 0;
-	struct net *net = &init_net;
 
 	WARN_ON(!mutex_is_locked(&nfsd_mutex));
 

