From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH] NFSD: don't report compiled-out versions as present
Date: Fri, 14 May 2010 15:33:36 +0400
Message-ID: <4BED3510.80403@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "J. Bruce Fields" <bfields@citi.umich.edu>,
	linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:4442 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752879Ab0ENLdz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 May 2010 07:33:55 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The /proc/fs/nfsd/versions file calls nfsd_vers() to check whether
the particular nfsd version is present/available. The problem is
that once I turn off e.g. NFSD-V4 this call returns -1 which is
true from the callers POV which is wrong.

The proposal is to report false in that case.

Patch is against git://linux-nfs.org/~bfields/linux:master

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
index 171699e..06b2a26 100644
--- a/fs/nfsd/nfssvc.c
+++ b/fs/nfsd/nfssvc.c
@@ -120,7 +120,7 @@ u32 nfsd_supported_minorversion;
 int nfsd_vers(int vers, enum vers_op change)
 {
 	if (vers < NFSD_MINVERS || vers >= NFSD_NRVERS)
-		return -1;
+		return 0;
 	switch(change) {
 	case NFSD_SET:
 		nfsd_versions[vers] = nfsd_version[vers];
