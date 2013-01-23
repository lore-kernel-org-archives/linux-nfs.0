Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cn.fujitsu.com ([222.73.24.84]:28010 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753972Ab3AWJ57 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Jan 2013 04:57:59 -0500
Message-ID: <50FFB43A.8030105@cn.fujitsu.com>
Date: Wed, 23 Jan 2013 17:58:18 +0800
From: fanchaoting <fanchaoting@cn.fujitsu.com>
MIME-Version: 1.0
To: "bfields@fieldses.org" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH] nfsd: Check the nfsd support version when enable or disable
 the minorversion
Content-Type: text/plain; charset=ISO-2022-JP
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

when enable or disable the minorversion throw /proc/fs/nfsd/versions,it
should check the support version.

for example
if we do like following:

echo "+2 +3 +4 +7.1">/proc/fs/nfsd/versions
echo "+2 +3 +4 -7.1">/proc/fs/nfsd/versions
it will enable or disable nfs4.1, but now the number nfs7 didn't support.

Signed-off-by: Fan Chaoting <fanchaoting@cn.fujitsu.com>

---
 fs/nfsd/nfsctl.c |    2 +-
 fs/nfsd/nfsd.h   |    1 +
 fs/nfsd/nfssvc.c |    4 ++++
 3 files changed, 6 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index dab350d..1a6e89c 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -532,7 +532,7 @@ static ssize_t __write_versions(struct file *file, char *buf, size_t size)
 			else
 				num = simple_strtol(vers, &minorp, 0);
 			if (*minorp == '.') {
-				if (num < 4)
+				if (num < 4 || num >= nfsd_number_vers())
 					return -EINVAL;
 				minor = simple_strtoul(minorp+1, NULL, 0);
 				if (minor == 0)
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 80d5ce4..c9d7203 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -104,6 +104,7 @@ int nfsd_vers(int vers, enum vers_op change);
 int nfsd_minorversion(u32 minorversion, enum vers_op change);
 void nfsd_reset_versions(void);
 int nfsd_create_serv(void);
+int nfsd_number_vers(void);
 
 extern int nfsd_max_blksize;
 
diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 2013aa00..072cdb9 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -670,3 +670,7 @@ int nfsd_pool_stats_release(struct inode *inode, struct file *file)
 	mutex_unlock(&nfsd_mutex);
 	return ret;
 }
+
+int nfsd_number_vers(void) {
+	return NFSD_NRVERS;
+}
-- 
1.7.10.1

