Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yi0-f46.google.com ([209.85.218.46]:49292 "EHLO
	mail-yi0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755131Ab1CYVjn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Mar 2011 17:39:43 -0400
Received: by mail-yi0-f46.google.com with SMTP id 27so624224yia.19
        for <linux-nfs@vger.kernel.org>; Fri, 25 Mar 2011 14:39:42 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] exports: add a configurable time-to-live for the kernel
	cache entries
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 25 Mar 2011 17:38:56 -0400
Message-ID: <20110325213856.27166.41564.stgit@matisse.1015granger.net>
In-Reply-To: <20110325213559.27166.71461.stgit@matisse.1015granger.net>
References: <20110325213559.27166.71461.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Trond Myklebust <Trond.Myklebust@netapp.com>

The fedfs ldap server will specify a ttl for its entries.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

This is a refactoring change only.  There should be no change in
behavior.

Original patch had updates to utils/mountd/junctions.c, which no
longer exists.  These are not included here.

Create a macro for the default cache TTL, which is used in several
places besides the export cache.

Make e_ttl unsigned.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 support/include/exportfs.h |    1 +
 support/include/nfslib.h   |    1 +
 support/nfs/exports.c      |    1 +
 utils/mountd/cache.c       |   15 ++++++++-------
 4 files changed, 11 insertions(+), 7 deletions(-)

diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index 3cf1ee8..01e87dd 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -100,6 +100,7 @@ typedef struct mexport {
 } nfs_export;
 
 #define HASH_TABLE_SIZE 1021
+#define DEFAULT_TTL	(30 * 60)
 
 typedef struct _exp_hash_entry {
 	nfs_export * p_first;
diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index cee826b..73f3c20 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -95,6 +95,7 @@ struct exportent {
 	char *          e_fslocdata;
 	char *		e_uuid;
 	struct sec_entry e_secinfo[SECFLAVOR_COUNT+1];
+	unsigned int	e_ttl;
 };
 
 struct rmtabent {
diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index 1744ed6..6acb2b6 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -107,6 +107,7 @@ static void init_exportent (struct exportent *ee, int fromkernel)
 	ee->e_nsquids = 0;
 	ee->e_nsqgids = 0;
 	ee->e_uuid = NULL;
+	ee->e_ttl = DEFAULT_TTL;
 }
 
 struct exportent *
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index f70f4d6..1d6e953 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -114,7 +114,7 @@ static void auth_unix_ip(FILE *f)
 
 	qword_print(f, "nfsd");
 	qword_print(f, ipaddr);
-	qword_printint(f, time(0)+30*60);
+	qword_printuint(f, time(0) + DEFAULT_TTL);
 	if (use_ipaddr)
 		qword_print(f, ipaddr);
 	else if (client)
@@ -161,7 +161,7 @@ static void auth_unix_gid(FILE *f)
 		}
 	}
 	qword_printuint(f, uid);
-	qword_printuint(f, time(0)+30*60);
+	qword_printuint(f, time(0) + DEFAULT_TTL);
 	if (rv >= 0) {
 		qword_printuint(f, ngroups);
 		for (i=0; i<ngroups; i++)
@@ -644,11 +644,11 @@ static int dump_to_cache(FILE *f, char *domain, char *path, struct exportent *ex
 {
 	qword_print(f, domain);
 	qword_print(f, path);
-	qword_printint(f, time(0)+30*60);
 	if (exp) {
 		int different_fs = strcmp(path, exp->e_path) != 0;
 		int flag_mask = different_fs ? ~NFSEXP_FSID : ~0;
 
+		qword_printuint(f, time(0) + exp->e_ttl);
 		qword_printint(f, exp->e_flags & flag_mask);
 		qword_printint(f, exp->e_anonuid);
 		qword_printint(f, exp->e_anongid);
@@ -667,7 +667,8 @@ static int dump_to_cache(FILE *f, char *domain, char *path, struct exportent *ex
  			qword_print(f, "uuid");
  			qword_printhex(f, u, 16);
  		}
-	}
+	} else
+		qword_printuint(f, time(0) + DEFAULT_TTL);
 	return qword_eol(f);
 }
 
@@ -874,8 +875,8 @@ int cache_process_req(fd_set *readfds)
 
 /*
  * Give IP->domain and domain+path->options to kernel
- * % echo nfsd $IP  $[now+30*60] $domain > /proc/net/rpc/auth.unix.ip/channel
- * % echo $domain $path $[now+30*60] $options $anonuid $anongid $fsid > /proc/net/rpc/nfsd.export/channel
+ * % echo nfsd $IP  $[now+DEFAULT_TTL] $domain > /proc/net/rpc/auth.unix.ip/channel
+ * % echo $domain $path $[now+DEFAULT_TTL] $options $anonuid $anongid $fsid > /proc/net/rpc/nfsd.export/channel
  */
 
 static int cache_export_ent(char *domain, struct exportent *exp, char *path)
@@ -955,7 +956,7 @@ int cache_export(nfs_export *exp, char *path)
 	qword_print(f, "nfsd");
 	qword_print(f,
 		host_ntop(get_addrlist(exp->m_client, 0), buf, sizeof(buf)));
-	qword_printint(f, time(0)+30*60);
+	qword_printuint(f, time(0) + exp->m_export.e_ttl);
 	qword_print(f, exp->m_client->m_hostname);
 	err = qword_eol(f);
 	

