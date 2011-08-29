Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f46.google.com ([74.125.83.46]:41407 "EHLO
	mail-gw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753945Ab1H2SuK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Aug 2011 14:50:10 -0400
Received: by gwaa12 with SMTP id a12so5039185gwa.19
        for <linux-nfs@vger.kernel.org>; Mon, 29 Aug 2011 11:50:09 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] NFSD: Remove the ex_pathname field from struct svc_export
To: bfields@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 29 Aug 2011 14:50:06 -0400
Message-ID: <20110829185006.3369.19413.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Trond Myklebust <Trond.Myklebust@netapp.com>

There are no more users...

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfsd/export.c            |   11 -----------
 include/linux/nfsd/export.h |    1 -
 2 files changed, 0 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index d9a6611..bf985f7 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -318,7 +318,6 @@ static void svc_export_put(struct kref *ref)
 	struct svc_export *exp = container_of(ref, struct svc_export, h.ref);
 	path_put(&exp->ex_path);
 	auth_domain_put(exp->ex_client);
-	kfree(exp->ex_pathname);
 	nfsd4_fslocs_free(&exp->ex_fslocs);
 	kfree(exp);
 }
@@ -528,11 +527,6 @@ static int svc_export_parse(struct cache_detail *cd, char *mesg, int mlen)
 
 	exp.ex_client = dom;
 
-	err = -ENOMEM;
-	exp.ex_pathname = kstrdup(buf, GFP_KERNEL);
-	if (!exp.ex_pathname)
-		goto out2;
-
 	/* expiry */
 	err = -EINVAL;
 	exp.h.expiry_time = get_expiry(&mesg);
@@ -613,8 +607,6 @@ out4:
 	nfsd4_fslocs_free(&exp.ex_fslocs);
 	kfree(exp.ex_uuid);
 out3:
-	kfree(exp.ex_pathname);
-out2:
 	path_put(&exp.ex_path);
 out1:
 	auth_domain_put(dom);
@@ -678,7 +670,6 @@ static void svc_export_init(struct cache_head *cnew, struct cache_head *citem)
 	new->ex_client = item->ex_client;
 	new->ex_path.dentry = dget(item->ex_path.dentry);
 	new->ex_path.mnt = mntget(item->ex_path.mnt);
-	new->ex_pathname = NULL;
 	new->ex_fslocs.locations = NULL;
 	new->ex_fslocs.locations_count = 0;
 	new->ex_fslocs.migrated = 0;
@@ -696,8 +687,6 @@ static void export_update(struct cache_head *cnew, struct cache_head *citem)
 	new->ex_fsid = item->ex_fsid;
 	new->ex_uuid = item->ex_uuid;
 	item->ex_uuid = NULL;
-	new->ex_pathname = item->ex_pathname;
-	item->ex_pathname = NULL;
 	new->ex_fslocs.locations = item->ex_fslocs.locations;
 	item->ex_fslocs.locations = NULL;
 	new->ex_fslocs.locations_count = item->ex_fslocs.locations_count;
diff --git a/include/linux/nfsd/export.h b/include/linux/nfsd/export.h
index 7ba3fd4..f85308e 100644
--- a/include/linux/nfsd/export.h
+++ b/include/linux/nfsd/export.h
@@ -96,7 +96,6 @@ struct svc_export {
 	struct auth_domain *	ex_client;
 	int			ex_flags;
 	struct path		ex_path;
-	char			*ex_pathname;
 	uid_t			ex_anon_uid;
 	gid_t			ex_anon_gid;
 	int			ex_fsid;

