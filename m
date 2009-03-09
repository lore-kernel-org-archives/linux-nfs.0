From: Steve Dickson <SteveD@redhat.com>
Subject: [Patch 9/9] Fixed a couple nits
Date: Mon, 09 Mar 2009 17:10:05 -0400
Message-ID: <49B585AD.6000704@RedHat.com>
References: <49B57FB2.9020000@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFSv4 mailing list <nfsv4@linux-nfs.org>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <49B57FB2.9020000@RedHat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

commit b329b584f72a7078c59d71afd238099e7e9b4dfa
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Mar 9 15:39:07 2009 -0400

    General clean up
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/nfs/conffile.c b/support/nfs/conffile.c
index a362700..f5e0f79 100644
--- a/support/nfs/conffile.c
+++ b/support/nfs/conffile.c
@@ -517,7 +517,7 @@ cleanup:
 }
 
 struct conf_list *
-conf_get_tag_list (char *section)
+conf_get_tag_list(char *section)
 {
 	struct conf_list *list = 0;
 	struct conf_list_node *node;
diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index c769b9c..28d87c4 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -156,7 +156,7 @@ static char *nobodyuser, *nobodygroup;
 static uid_t nobodyuid;
 static gid_t nobodygid;
 
-/* Used by cfg.c */
+/* Used by conffile.c in libnfs.a */
 char *conf_path;
 
 static int
diff --git a/utils/mount/configfile.c b/utils/mount/configfile.c
index 722eaba..d1dd1bf 100644
--- a/utils/mount/configfile.c
+++ b/utils/mount/configfile.c
@@ -1,6 +1,6 @@
 /*
  * configfile.c -- mount configuration file manipulation 
- * Copyright (C) 2008 Red Hat <nfs-team@redhat.com>
+ * Copyright (C) 2008 Red Hat <nfs@redhat.com>
  *
  * - Routines use to create mount options from the mount
  *   configuration file.
