Return-Path: linux-nfs-owner@vger.kernel.org
Received: from szxga03-in.huawei.com ([119.145.14.66]:45467 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751983AbaD3Cqq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Apr 2014 22:46:46 -0400
From: Weng Meiling <wengmeiling.weng@huawei.com>
To: <stable@vger.kernel.org>
CC: <bfields@fieldses.org>, <greg@kroah.com>, <lizefan@huawei.com>,
        <skinsbursky@parallels.com>, <h.huangqiang@huawei.com>,
        <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 3.4 5/9] nfsd: pass net to nfsd_set_nrthreads()
Date: Wed, 30 Apr 2014 10:43:40 +0800
Message-ID: <1398825824-6360-6-git-send-email-wengmeiling.weng@huawei.com>
In-Reply-To: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
References: <1398825824-6360-1-git-send-email-wengmeiling.weng@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Stanislav Kinsbursky <skinsbursky@parallels.com>

commit 3938a0d5eb5effcc89c6909741403f4e6a37252d upstream.

Precursor patch. Hard-coded "init_net" will be replaced by proper one in
future.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
[wengmeiling: backport to 3.4: adjust context]
Signed-off-by: Weng Meiling <wengmeiling.weng@huawei.com>
---
 fs/nfsd/nfsctl.c | 3 ++-
 fs/nfsd/nfsd.h   | 2 +-
 fs/nfsd/nfssvc.c | 3 +--
 3 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 9463bc0..f58e0f9 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -440,6 +440,7 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 	int len;
 	int npools;
 	int *nthreads;
+	struct net *net = &init_net;
 
 	mutex_lock(&nfsd_mutex);
 	npools = nfsd_nrpools();
@@ -470,7 +471,7 @@ static ssize_t write_pool_threads(struct file *file, char *buf, size_t size)
 			if (nthreads[i] < 0)
 				goto out_free;
 		}
-		rv = nfsd_set_nrthreads(i, nthreads);
+		rv = nfsd_set_nrthreads(i, nthreads, net);
 		if (rv)
 			goto out_free;
 	}
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 5007654..a0989a2 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -71,7 +71,7 @@ int		nfsd_dispatch(struct svc_rqst *rqstp, __be32 *statp);
 int		nfsd_nrthreads(void);
 int		nfsd_nrpools(void);
 int		nfsd_get_nrthreads(int n, int *);
-int		nfsd_set_nrthreads(int n, int *);
+int		nfsd_set_nrthreads(int n, int *, struct net *);
 
 static inline void nfsd_destroy(struct net *net)
 {
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index b8aea64..0974818 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -374,12 +374,11 @@ int nfsd_get_nrthreads(int n, int *nthreads)
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
 
-- 
1.8.2.2


