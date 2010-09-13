Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:62750 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865Ab0IMRVc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 13:21:32 -0400
Received: by mail-pz0-f46.google.com with SMTP id 34so2221811pzk.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 10:21:32 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/12] mountd: support IPv6 in mountlist_del_all()
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Sep 2010 13:21:28 -0400
Message-ID: <20100913172128.19017.28249.stgit@seurat.1015granger.net>
In-Reply-To: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
References: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Replace IPv4-specific code in the mountlist_del_all() path with code
that is address family agnostic.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/mountd.c |    2 +-
 utils/mountd/mountd.h |    2 +-
 utils/mountd/rmtab.c  |   12 +++++-------
 3 files changed, 7 insertions(+), 9 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 19dc4ee..98b396d 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -275,7 +275,7 @@ mount_umntall_1_svc(struct svc_req *rqstp, void *UNUSED(argp),
 	/* Reload /etc/xtab if necessary */
 	auth_reload();
 
-	mountlist_del_all(nfs_getrpccaller_in(rqstp->rq_xprt));
+	mountlist_del_all(nfs_getrpccaller(rqstp->rq_xprt));
 	return 1;
 }
 
diff --git a/utils/mountd/mountd.h b/utils/mountd/mountd.h
index 96e9bf1..0d31ca7 100644
--- a/utils/mountd/mountd.h
+++ b/utils/mountd/mountd.h
@@ -48,7 +48,7 @@ void		auth_export(nfs_export *exp);
 
 void		mountlist_add(char *host, const char *path);
 void		mountlist_del(char *host, const char *path);
-void		mountlist_del_all(struct sockaddr_in *sin);
+void		mountlist_del_all(const struct sockaddr *sap);
 mountlist	mountlist_list(void);
 
 
diff --git a/utils/mountd/rmtab.c b/utils/mountd/rmtab.c
index d23712b..b2c04e7 100644
--- a/utils/mountd/rmtab.c
+++ b/utils/mountd/rmtab.c
@@ -131,21 +131,20 @@ mountlist_del(char *hname, const char *path)
 }
 
 void
-mountlist_del_all(struct sockaddr_in *sin)
+mountlist_del_all(const struct sockaddr *sap)
 {
 	char		*hostname;
 	struct rmtabent	*rep;
-	nfs_export	*exp;
 	FILE		*fp;
 	int		lockid;
 
 	if ((lockid = xflock(_PATH_RMTABLCK, "w")) < 0)
 		return;
-	hostname = host_canonname((struct sockaddr *)sin);
+	hostname = host_canonname(sap);
 	if (hostname == NULL) {
-		char buf[INET_ADDRSTRLEN];
+		char buf[INET6_ADDRSTRLEN];
 		xlog(L_ERROR, "can't get hostname of %s",
-			host_ntop((struct sockaddr *)sin, buf, sizeof(buf)));
+			host_ntop(sap, buf, sizeof(buf)));
 		goto out_unlock;
 	}
 
@@ -157,8 +156,7 @@ mountlist_del_all(struct sockaddr_in *sin)
 
 	while ((rep = getrmtabent(1, NULL)) != NULL) {
 		if (strcmp(rep->r_client, hostname) == 0 &&
-		    (exp = auth_authenticate("umountall",
-				(struct sockaddr *)sin, rep->r_path)))
+		    auth_authenticate("umountall", sap, rep->r_path) != NULL)
 			continue;
 		fputrmtabent(fp, rep, NULL);
 	}

