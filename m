Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:62961 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753343Ab0IMRWg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Sep 2010 13:22:36 -0400
Received: by yxp4 with SMTP id 4so2096756yxp.19
        for <linux-nfs@vger.kernel.org>; Mon, 13 Sep 2010 10:22:35 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/12] mountd: clean up cache API
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Mon, 13 Sep 2010 13:22:32 -0400
Message-ID: <20100913172232.19017.54813.stgit@seurat.1015granger.net>
In-Reply-To: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
References: <20100913171844.19017.13446.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Clean up: Squelch compiler warnings and document public parts of
cache API.

cache.c: At top level:
cache.c:67: warning: no previous prototype for ‘auth_unix_ip’
cache.c:123: warning: no previous prototype for ‘auth_unix_gid’
cache.c:217: warning: no previous prototype for ‘get_uuid’
cache.c:247: warning: no previous prototype for ‘uuid_by_path’
cache.c:326: warning: no previous prototype for ‘nfsd_fh’
cache.c:745: warning: no previous prototype for ‘nfsd_export’
cache.c:820: warning: no previous prototype for ‘cache_open’
cache.c:832: warning: no previous prototype for ‘cache_set_fds’
cache.c:841: warning: no previous prototype for ‘cache_process_req’
cache.c:921: warning: no previous prototype for ‘cache_export’
cache.c:953: warning: no previous prototype for ‘cache_get_filehandle’

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mountd/cache.c  |   49 +++++++++++++++++++++++++++++++++++++++----------
 utils/mountd/mountd.c |    4 ----
 utils/mountd/mountd.h |    4 ++++
 3 files changed, 43 insertions(+), 14 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 2909ad3..ab873d5 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -37,6 +37,11 @@
 #include "blkid/blkid.h"
 #endif
 
+/*
+ * Invoked by RPC service loop
+ */
+void	cache_set_fds(fd_set *fdset);
+int	cache_process_req(fd_set *readfds);
 
 enum nfsd_fsid {
 	FSID_DEV = 0,
@@ -57,14 +62,14 @@ enum nfsd_fsid {
  * Record is terminated with newline.
  *
  */
-int cache_export_ent(char *domain, struct exportent *exp, char *p);
+static int cache_export_ent(char *domain, struct exportent *exp, char *p);
 
 
 char *lbuf  = NULL;
 int lbuflen = 0;
 extern int use_ipaddr;
 
-void auth_unix_ip(FILE *f)
+static void auth_unix_ip(FILE *f)
 {
 	/* requests are
 	 *  class IP-ADDR
@@ -120,7 +125,7 @@ void auth_unix_ip(FILE *f)
 	free(client);
 }
 
-void auth_unix_gid(FILE *f)
+static void auth_unix_gid(FILE *f)
 {
 	/* Request are
 	 *  uid
@@ -214,7 +219,7 @@ static const char *get_uuid_blkdev(char *path)
 #define get_uuid_blkdev(path) (NULL)
 #endif
 
-int get_uuid(const char *val, int uuidlen, char *u)
+static int get_uuid(const char *val, int uuidlen, char *u)
 {
 	/* extract hex digits from uuidstr and compose a uuid
 	 * of the given length (max 16), xoring bytes to make
@@ -244,7 +249,7 @@ int get_uuid(const char *val, int uuidlen, char *u)
 	return 1;
 }
 
-int uuid_by_path(char *path, int type, int uuidlen, char *uuid)
+static int uuid_by_path(char *path, int type, int uuidlen, char *uuid)
 {
 	/* get a uuid for the filesystem found at 'path'.
 	 * There are several possible ways of generating the
@@ -323,7 +328,7 @@ static char *next_mnt(void **v, char *p)
 	return me->mnt_dir;
 }
 
-void nfsd_fh(FILE *f)
+static void nfsd_fh(FILE *f)
 {
 	/* request are:
 	 *  domain fsidtype fsid
@@ -742,7 +747,7 @@ lookup_export(char *dom, char *path, struct addrinfo *ai)
 	return found;
 }
 
-void nfsd_export(FILE *f)
+static void nfsd_export(FILE *f)
 {
 	/* requests are:
 	 *  domain path
@@ -817,6 +822,11 @@ struct {
 };
 
 extern int manage_gids;
+
+/**
+ * cache_open - prepare communications channels with kernel RPC caches
+ *
+ */
 void cache_open(void) 
 {
 	int i;
@@ -829,6 +839,10 @@ void cache_open(void)
 	}
 }
 
+/**
+ * cache_set_fds - prepare cache file descriptors for one iteration of the service loop
+ * @fdset: pointer to fd_set to prepare
+ */
 void cache_set_fds(fd_set *fdset)
 {
 	int i;
@@ -838,6 +852,10 @@ void cache_set_fds(fd_set *fdset)
 	}
 }
 
+/**
+ * cache_process_req - process any active cache file descriptors during service loop iteration
+ * @fdset: pointer to fd_set to examine for activity
+ */
 int cache_process_req(fd_set *readfds) 
 {
 	int i;
@@ -860,7 +878,7 @@ int cache_process_req(fd_set *readfds)
  * % echo $domain $path $[now+30*60] $options $anonuid $anongid $fsid > /proc/net/rpc/nfsd.export/channel
  */
 
-int cache_export_ent(char *domain, struct exportent *exp, char *path)
+static int cache_export_ent(char *domain, struct exportent *exp, char *path)
 {
 	int err;
 	FILE *f = fopen("/proc/net/rpc/nfsd.export/channel", "w");
@@ -918,6 +936,11 @@ int cache_export_ent(char *domain, struct exportent *exp, char *path)
 	return err;
 }
 
+/**
+ * cache_export - Inform kernel of a new nfs_export
+ * @exp: target nfs_export
+ * @path: NUL-terminated C string containing export path
+ */
 int cache_export(nfs_export *exp, char *path)
 {
 	char buf[INET_ADDRSTRLEN];
@@ -943,7 +966,14 @@ int cache_export(nfs_export *exp, char *path)
 	return err;
 }
 
-/* Get a filehandle.
+/**
+ * cache_get_filehandle - given an nfs_export, get its root filehandle
+ * @exp: target nfs_export
+ * @len: length of requested file handle
+ * @p: NUL-terminated C string containing export path
+ *
+ * Returns pointer to NFS file handle of root directory of export
+ *
  * { 
  *   echo $domain $path $length 
  *   read filehandle <&0
@@ -977,4 +1007,3 @@ cache_get_filehandle(nfs_export *exp, int len, char *p)
 	fh.fh_size = qword_get(&bp, (char *)fh.fh_handle, NFS3_FHSIZE);
 	return &fh;
 }
-
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 98b396d..982b06e 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -28,10 +28,6 @@
 #include "rpcmisc.h"
 #include "pseudoflavors.h"
 
-extern void	cache_open(void);
-extern struct nfs_fh_len *cache_get_filehandle(nfs_export *exp, int len, char *p);
-extern int cache_export(nfs_export *exp, char *path);
-
 extern void my_svc_run(void);
 
 static void		usage(const char *, int exitcode);
diff --git a/utils/mountd/mountd.h b/utils/mountd/mountd.h
index 0d31ca7..4c184d2 100644
--- a/utils/mountd/mountd.h
+++ b/utils/mountd/mountd.h
@@ -51,5 +51,9 @@ void		mountlist_del(char *host, const char *path);
 void		mountlist_del_all(const struct sockaddr *sap);
 mountlist	mountlist_list(void);
 
+void		cache_open(void);
+struct nfs_fh_len *
+		cache_get_filehandle(nfs_export *exp, int len, char *p);
+int		cache_export(nfs_export *exp, char *path);
 
 #endif /* MOUNTD_H */

