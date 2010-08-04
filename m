From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 23/24] Removed warnings from mountd.c
Date: Wed,  4 Aug 2010 11:12:19 -0400
Message-ID: <1280934740-11366-24-git-send-email-steved@redhat.com>
References: <1280934740-11366-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:45179 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754727Ab0HDPvR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 4 Aug 2010 11:51:17 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1Ogfdo-0002SZ-Ow
	for linux-nfs@vger.kernel.org; Wed, 04 Aug 2010 11:12:24 -0400
In-Reply-To: <1280934740-11366-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

mountd.c: In function 'mount_null_1_svc':
mountd.c:195: warning: unused parameter 'rqstp'
mountd.c:195: warning: unused parameter 'argp'
mountd.c:195: warning: unused parameter 'resp'
mountd.c: In function 'mount_dump_1_svc':
mountd.c:213: warning: unused parameter 'argp'
mountd.c: In function 'mount_umnt_1_svc':
mountd.c:224: warning: unused parameter 'resp'
mountd.c: In function 'mount_umntall_1_svc':
mountd.c:248: warning: unused parameter 'argp'
mountd.c:248: warning: unused parameter 'resp'
mountd.c: In function 'mount_export_1_svc':
mountd.c:258: warning: unused parameter 'argp'
mountd.c: In function 'mount_exportall_1_svc':
mountd.c:269: warning: unused parameter 'argp'
mountd.c: In function 'mount_dump_1_svc':
mountd.c:216: warning: unused parameter 'argp'
mountd.c: In function 'mount_umnt_1_svc':
mountd.c:227: warning: unused parameter 'resp'
mountd.c: In function 'mount_umntall_1_svc':
mountd.c:251: warning: unused parameter 'argp'
mountd.c:251: warning: unused parameter 'resp'
mountd.c: In function 'mount_export_1_svc':
mountd.c:261: warning: unused parameter 'argp'
mountd.c: In function 'mount_exportall_1_svc':
mountd.c:272: warning: unused parameter 'argp'

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/mountd.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 6571454..dc84404 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -192,7 +192,8 @@ sig_hup (int sig)
 }
 
 bool_t
-mount_null_1_svc(struct svc_req *rqstp, void *argp, void *resp)
+mount_null_1_svc(struct svc_req *UNUSED(rqstp), void *UNUSED(argp), 
+	void *UNUSED(resp))
 {
 	return 1;
 }
@@ -210,7 +211,7 @@ mount_mnt_1_svc(struct svc_req *rqstp, dirpath *path, fhstatus *res)
 }
 
 bool_t
-mount_dump_1_svc(struct svc_req *rqstp, void *argp, mountlist *res)
+mount_dump_1_svc(struct svc_req *rqstp, void *UNUSED(argp), mountlist *res)
 {
 	struct sockaddr_in *addr = nfs_getrpccaller_in(rqstp->rq_xprt);
 
@@ -221,7 +222,7 @@ mount_dump_1_svc(struct svc_req *rqstp, void *argp, mountlist *res)
 }
 
 bool_t
-mount_umnt_1_svc(struct svc_req *rqstp, dirpath *argp, void *resp)
+mount_umnt_1_svc(struct svc_req *rqstp, dirpath *argp, void *UNUSED(resp))
 {
 	struct sockaddr_in *sin = nfs_getrpccaller_in(rqstp->rq_xprt);
 	nfs_export	*exp;
@@ -245,7 +246,8 @@ mount_umnt_1_svc(struct svc_req *rqstp, dirpath *argp, void *resp)
 }
 
 bool_t
-mount_umntall_1_svc(struct svc_req *rqstp, void *argp, void *resp)
+mount_umntall_1_svc(struct svc_req *rqstp, void *UNUSED(argp), 
+	void *UNUSED(resp))
 {
 	/* Reload /etc/xtab if necessary */
 	auth_reload();
@@ -255,7 +257,7 @@ mount_umntall_1_svc(struct svc_req *rqstp, void *argp, void *resp)
 }
 
 bool_t
-mount_export_1_svc(struct svc_req *rqstp, void *argp, exports *resp)
+mount_export_1_svc(struct svc_req *rqstp, void *UNUSED(argp), exports *resp)
 {
 	struct sockaddr_in *addr = nfs_getrpccaller_in(rqstp->rq_xprt);
 
@@ -266,7 +268,7 @@ mount_export_1_svc(struct svc_req *rqstp, void *argp, exports *resp)
 }
 
 bool_t
-mount_exportall_1_svc(struct svc_req *rqstp, void *argp, exports *resp)
+mount_exportall_1_svc(struct svc_req *rqstp, void *UNUSED(argp), exports *resp)
 {
 	struct sockaddr_in *addr = nfs_getrpccaller_in(rqstp->rq_xprt);
 
-- 
1.7.2

