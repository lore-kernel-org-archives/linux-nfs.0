Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:42415 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753952Ab3KTQs4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 20 Nov 2013 11:48:56 -0500
From: Susant Sahani <ssahani@redhat.com>
To: Libtirpc-devel Mailing List <libtirpc-devel@lists.sourceforge.net>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] Race in getnetconfig
Date: Wed, 20 Nov 2013 22:19:33 +0530
Message-Id: <1384966173-6229-4-git-send-email-ssahani@redhat.com>
In-Reply-To: <1384966173-6229-1-git-send-email-ssahani@redhat.com>
References: <1384966173-6229-1-git-send-email-ssahani@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Susant Sahani <ssahani@redhat.com>
---
 src/getnetconfig.c | 51 +++++++++++++++++++++++++++++++++++++++++----------
 1 file changed, 41 insertions(+), 10 deletions(-)

diff --git a/src/getnetconfig.c b/src/getnetconfig.c
index 2460a6e..9c21562 100644
--- a/src/getnetconfig.c
+++ b/src/getnetconfig.c
@@ -120,6 +120,7 @@ static struct netconfig *dup_ncp(struct netconfig *);
 
 static FILE *nc_file;		/* for netconfig db */
 static struct netconfig_info	ni = { 0, 0, NULL, NULL};
+static pthread_mutex_t nc_db_lock = PTHREAD_MUTEX_INITIALIZER;
 
 #define MAXNETCONFIGLINE    1000
 
@@ -192,14 +193,17 @@ setnetconfig()
      * For multiple calls, i.e. nc_file is not NULL, we just return the
      * handle without reopening the netconfig db.
      */
+    mutex_lock(&nc_db_lock);
     ni.ref++;
     if ((nc_file != NULL) || (nc_file = fopen(NETCONFIG, "r")) != NULL) {
 	nc_vars->valid = NC_VALID;
 	nc_vars->flag = 0;
 	nc_vars->nc_configs = ni.head;
+	mutex_unlock(&nc_db_lock);
 	return ((void *)nc_vars);
     }
     ni.ref--;
+    mutex_unlock(&nc_db_lock);
     nc_error = NC_NONETCONFIG;
     free(nc_vars);
     return (NULL);
@@ -222,12 +226,15 @@ void *handlep;
     char *stringp;		/* tmp string pointer */
     struct netconfig_list	*list;
     struct netconfig *np;
+    struct netconfig *result;
 
     /*
      * Verify that handle is valid
      */
+    mutex_lock(&nc_db_lock);
     if (ncp == NULL || nc_file == NULL) {
 	nc_error = NC_NOTINIT;
+	mutex_unlock(&nc_db_lock);
 	return (NULL);
     }
 
@@ -244,11 +251,14 @@ void *handlep;
 	if (ncp->flag == 0) {	/* first time */
 	    ncp->flag = 1;
 	    ncp->nc_configs = ni.head;
-	    if (ncp->nc_configs != NULL)	/* entry already exist */
+	    if (ncp->nc_configs != NULL)	/* entry already exist */ {
+		mutex_unlock(&nc_db_lock);
 		return(ncp->nc_configs->ncp);
+            }
 	}
 	else if (ncp->nc_configs != NULL && ncp->nc_configs->next != NULL) {
 	    ncp->nc_configs = ncp->nc_configs->next;
+	    mutex_unlock(&nc_db_lock);
 	    return(ncp->nc_configs->ncp);
 	}
 
@@ -256,16 +266,22 @@ void *handlep;
 	 * If we cannot find the entry in the list and is end of file,
 	 * we give up.
 	 */
-	if (ni.eof == 1)	return(NULL);
+	if (ni.eof == 1) {
+            mutex_unlock(&nc_db_lock);
+            return(NULL);
+        }
 	break;
     default:
 	nc_error = NC_NOTINIT;
+	mutex_unlock(&nc_db_lock);
 	return (NULL);
     }
 
     stringp = (char *) malloc(MAXNETCONFIGLINE);
-    if (stringp == NULL)
+    if (stringp == NULL) {
+	mutex_unlock(&nc_db_lock);
     	return (NULL);
+    }
 
 #ifdef MEM_CHK
     if (malloc_verify() == 0) {
@@ -281,6 +297,7 @@ void *handlep;
 	if (fgets(stringp, MAXNETCONFIGLINE, nc_file) == NULL) {
 	    free(stringp);
 	    ni.eof = 1;
+	    mutex_unlock(&nc_db_lock);
 	    return (NULL);
         }
     } while (*stringp == '#');
@@ -288,12 +305,14 @@ void *handlep;
     list = (struct netconfig_list *) malloc(sizeof (struct netconfig_list));
     if (list == NULL) {
     	free(stringp);
+	mutex_unlock(&nc_db_lock);
     	return(NULL);
     }
     np = (struct netconfig *) malloc(sizeof (struct netconfig));
     if (np == NULL) {
     	free(stringp);
 	free(list);
+	mutex_unlock(&nc_db_lock);
     	return(NULL);
     }
     list->ncp = np;
@@ -304,6 +323,7 @@ void *handlep;
 	free(stringp);
 	free(np);
 	free(list);
+	mutex_unlock(&nc_db_lock);
 	return (NULL);
     }
     else {
@@ -321,7 +341,9 @@ void *handlep;
     	    ni.tail = ni.tail->next;
     	}
 	ncp->nc_configs = ni.tail;
-	return(ni.tail->ncp);
+	result = ni.tail->ncp;
+	mutex_unlock(&nc_db_lock);
+	return result;
     }
 }
 
@@ -355,7 +377,9 @@ void *handlep;
     nc_handlep->valid = NC_INVALID;
     nc_handlep->flag = 0;
     nc_handlep->nc_configs = NULL;
+    mutex_lock(&nc_db_lock);
     if (--ni.ref > 0) {
+	mutex_unlock(&nc_db_lock);
     	free(nc_handlep);
 	return(0);
     }
@@ -377,9 +401,11 @@ void *handlep;
 	q = p;
     }
     free(nc_handlep);
-
-    fclose(nc_file);
+    if(nc_file != NULL) {
+        fclose(nc_file);
+    }
     nc_file = NULL;
+    mutex_unlock(&nc_db_lock);
     return (0);
 }
 
@@ -427,16 +453,21 @@ getnetconfigent(netid)
      * If all the netconfig db has been read and placed into the list and
      * there is no match for the netid, return NULL.
      */
+    mutex_lock(&nc_db_lock);
     if (ni.head != NULL) {
 	for (list = ni.head; list; list = list->next) {
 	    if (strcmp(list->ncp->nc_netid, netid) == 0) {
-	        return(dup_ncp(list->ncp));
+		ncp = dup_ncp(list->ncp);
+		mutex_unlock(&nc_db_lock);
+		return ncp;
 	    }
 	}
-	if (ni.eof == 1)	/* that's all the entries */
-		return(NULL);
+        if (ni.eof == 1) {	/* that's all the entries */
+	    mutex_unlock(&nc_db_lock);
+	    return(NULL);
+        }
     }
-
+    mutex_unlock(&nc_db_lock);
 
     if ((file = fopen(NETCONFIG, "r")) == NULL) {
 	nc_error = NC_NONETCONFIG;
-- 
1.8.4.2

