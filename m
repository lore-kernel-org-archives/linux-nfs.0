Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:58514 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755071Ab3KYRsS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 25 Nov 2013 12:48:18 -0500
Message-ID: <52938D8E.7020806@redhat.com>
Date: Mon, 25 Nov 2013 23:19:02 +0530
From: Susant Sahani <ssahani@redhat.com>
MIME-Version: 1.0
To: Steve Dickson <SteveD@redhat.com>,
        Libtirpc-devel Mailing List
	<libtirpc-devel@lists.sourceforge.net>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/1] data race in bindresvport_sa
References: <1384966173-6229-1-git-send-email-ssahani@redhat.com> <528F8631.2070604@RedHat.com>
In-Reply-To: <528F8631.2070604@RedHat.com>
Content-Type: multipart/mixed;
 boundary="------------060408070601060409070600"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a multi-part message in MIME format.
--------------060408070601060409070600
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hi Steved,
      I am sorry not for giving proper description . I have addressed 
your comments attached the patches .
Thanks,
Susant


On 11/22/2013 09:58 PM, Steve Dickson wrote:
> Hello,
>
> Would it be possible to get a little better description as
> to what this patch does and why its needed...
> "data race in bindresvport_sa" have very little
> meaning, at least to me...
>
> More comments below...
>
> On 20/11/13 11:49, Susant Sahani wrote:
>> Signed-off-by: Susant Sahani <ssahani@redhat.com>
>> ---
>>   src/bindresvport.c | 16 +++++++++++++---
>>   1 file changed, 13 insertions(+), 3 deletions(-)
>>
>> diff --git a/src/bindresvport.c b/src/bindresvport.c
>> index 6ce3e81..d26d754 100644
>> --- a/src/bindresvport.c
>> +++ b/src/bindresvport.c
>> @@ -46,6 +46,7 @@
>>   #include <rpc/rpc.h>
>>   
>>   #include <string.h>
>> +#include <reentrant.h>
>>   
>>   /*
>>    * Bind a socket to a privileged IP port
>> @@ -79,17 +80,23 @@ bindresvport_sa(sd, sa)
>>   	u_int16_t *portp;
>>   	static u_int16_t port;
>>   	static short startport = STARTPORT;
>> +	static pthread_mutex_t port_lock = PTHREAD_MUTEX_INITIALIZER;
> How come you define this mutex statically instead in src/mt_misc.c
> like the rest of the mutexes?
>
> Would you mind moving this (and the other two in the patches)
> to src/mt_misc.c and added a commit talking about what they
> are protecting
>
> tia!
>
> steved.
>
>>   	socklen_t salen;
>> -	int nports = ENDPORT - startport + 1;
>> +	int nports;
>>   	int endport = ENDPORT;
>>   	int i;
>>   
>> +	mutex_lock(&port_lock);
>> +	nports = ENDPORT - startport + 1;
>> +
>>           if (sa == NULL) {
>>                   salen = sizeof(myaddr);
>>                   sa = (struct sockaddr *)&myaddr;
>>   
>> -                if (getsockname(sd, (struct sockaddr *)&myaddr, &salen) == -1)
>> -                        return -1;      /* errno is correctly set */
>> +                if (getsockname(sd, (struct sockaddr *)&myaddr, &salen) == -1) {
>> +                    mutex_unlock(&port_lock);
>> +                    return -1;      /* errno is correctly set */
>> +                }
>>   
>>                   af = myaddr.ss_family;
>>           } else
>> @@ -112,6 +119,7 @@ bindresvport_sa(sd, sa)
>>   #endif
>>           default:
>>                   errno = EPFNOSUPPORT;
>> +                mutex_unlock(&port_lock);
>>                   return (-1);
>>           }
>>           sa->sa_family = af;
>> @@ -137,6 +145,8 @@ bindresvport_sa(sd, sa)
>>   	    port = LOWPORT + port % (STARTPORT - LOWPORT);
>>   	    goto again;
>>   	}
>> +	mutex_unlock(&port_lock);
>> +
>>           return (res);
>>   }
>>   #else
>>


--------------060408070601060409070600
Content-Type: text/x-patch;
 name="0001-Race-conditions-in-getnetconfig.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0001-Race-conditions-in-getnetconfig.patch"

>From 37ce9e21d64f98e79be9da4415a78cb4f644737f Mon Sep 17 00:00:00 2001
From: Susant Sahani <ssahani@redhat.com>
Date: Sat, 23 Nov 2013 13:07:14 +0530
Subject: [PATCH 1/3] Race conditions in getnetconfig

 The clnt_* functions are *not* thread safe. Race conditions are caused
by the functions setnetconfig , getnetconfig, endnetconfig and
getnetconfigent that accesses global static data nc_file and ni which
are defined in the file getnetconfig are *not* protected by any mutex.
When more than one thread access them the variables become a nonlocal
side effect . These race conditions causing process to give undesired
behavior and leading to crash on file operations mostly on fclose. By
introducing the mutex nc_db_lock the netconfig database is synchronized
and prevented from crash.

Signed-off-by: Susant Sahani <ssahani@redhat.com>
---
 src/getnetconfig.c | 51 +++++++++++++++++++++++++++++++++++++++++----------
 src/mt_misc.c      |  3 +++
 2 files changed, 44 insertions(+), 10 deletions(-)

diff --git a/src/getnetconfig.c b/src/getnetconfig.c
index af4a484..3d9a9ea 100644
--- a/src/getnetconfig.c
+++ b/src/getnetconfig.c
@@ -120,6 +120,7 @@ static struct netconfig *dup_ncp(struct netconfig *);
 
 static FILE *nc_file;		/* for netconfig db */
 static struct netconfig_info	ni = { 0, 0, NULL, NULL};
+extern pthread_mutex_t nc_db_lock;
 
 #define MAXNETCONFIGLINE    1000
 
@@ -191,14 +192,17 @@ setnetconfig()
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
@@ -221,12 +225,15 @@ void *handlep;
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
 
@@ -243,11 +250,14 @@ void *handlep;
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
 
@@ -255,16 +265,22 @@ void *handlep;
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
@@ -280,6 +296,7 @@ void *handlep;
 	if (fgets(stringp, MAXNETCONFIGLINE, nc_file) == NULL) {
 	    free(stringp);
 	    ni.eof = 1;
+	    mutex_unlock(&nc_db_lock);
 	    return (NULL);
         }
     } while (*stringp == '#');
@@ -287,12 +304,14 @@ void *handlep;
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
@@ -303,6 +322,7 @@ void *handlep;
 	free(stringp);
 	free(np);
 	free(list);
+	mutex_unlock(&nc_db_lock);
 	return (NULL);
     }
     else {
@@ -320,7 +340,9 @@ void *handlep;
     	    ni.tail = ni.tail->next;
     	}
 	ncp->nc_configs = ni.tail;
-	return(ni.tail->ncp);
+	result = ni.tail->ncp;
+	mutex_unlock(&nc_db_lock);
+	return result;
     }
 }
 
@@ -354,7 +376,9 @@ void *handlep;
     nc_handlep->valid = NC_INVALID;
     nc_handlep->flag = 0;
     nc_handlep->nc_configs = NULL;
+    mutex_lock(&nc_db_lock);
     if (--ni.ref > 0) {
+	mutex_unlock(&nc_db_lock);
     	free(nc_handlep);
 	return(0);
     }
@@ -376,9 +400,11 @@ void *handlep;
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
 
@@ -426,16 +452,21 @@ getnetconfigent(netid)
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
diff --git a/src/mt_misc.c b/src/mt_misc.c
index fe12c31..b24c130 100644
--- a/src/mt_misc.c
+++ b/src/mt_misc.c
@@ -91,6 +91,9 @@ pthread_mutex_t	xprtlist_lock = PTHREAD_MUTEX_INITIALIZER;
 /* serializes calls to public key routines */
 pthread_mutex_t serialize_pkey = PTHREAD_MUTEX_INITIALIZER;
 
+/* protects global variables ni and nc_file (getnetconfig.c) */
+pthread_mutex_t nc_db_lock = PTHREAD_MUTEX_INITIALIZER;
+
 #undef	rpc_createerr
 
 struct rpc_createerr rpc_createerr;
-- 
1.8.4.2


--------------060408070601060409070600
Content-Type: text/x-patch;
 name="0002-Race-condition-in-bindresvport.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0002-Race-condition-in-bindresvport.patch"

>From 08af7bdaf61fc69b5dbc6136d8311d51b586ed63 Mon Sep 17 00:00:00 2001
From: Susant Sahani <ssahani@redhat.com>
Date: Sat, 23 Nov 2013 13:10:32 +0530
Subject: [PATCH 2/3] Race condition in bindresvport

 The function clnt_create is *not* thread safe . Race conditions in
the function bindresvport that accesses static data port and startport,
which are *not* protected by any mutex. When more than one thread
access them the variables become a nonlocal side effect. These race conditions
can lead to undesired behaviour . By introducing the mutex port_lock
the function bindresvport is serialized.

Signed-off-by: Susant Sahani <ssahani@redhat.com>
---
 src/bindresvport.c | 16 +++++++++++++---
 src/mt_misc.c      |  3 +++
 2 files changed, 16 insertions(+), 3 deletions(-)

diff --git a/src/bindresvport.c b/src/bindresvport.c
index 6ce3e81..910056e 100644
--- a/src/bindresvport.c
+++ b/src/bindresvport.c
@@ -46,6 +46,7 @@
 #include <rpc/rpc.h>
 
 #include <string.h>
+#include <reentrant.h>
 
 /*
  * Bind a socket to a privileged IP port
@@ -79,17 +80,23 @@ bindresvport_sa(sd, sa)
 	u_int16_t *portp;
 	static u_int16_t port;
 	static short startport = STARTPORT;
+	extern pthread_mutex_t port_lock;
 	socklen_t salen;
-	int nports = ENDPORT - startport + 1;
+	int nports;
 	int endport = ENDPORT;
 	int i;
 
+	mutex_lock(&port_lock);
+	nports = ENDPORT - startport + 1;
+
         if (sa == NULL) {
                 salen = sizeof(myaddr);
                 sa = (struct sockaddr *)&myaddr;
 
-                if (getsockname(sd, (struct sockaddr *)&myaddr, &salen) == -1)
-                        return -1;      /* errno is correctly set */
+                if (getsockname(sd, (struct sockaddr *)&myaddr, &salen) == -1) {
+                    mutex_unlock(&port_lock);
+                    return -1;      /* errno is correctly set */
+                }
 
                 af = myaddr.ss_family;
         } else
@@ -112,6 +119,7 @@ bindresvport_sa(sd, sa)
 #endif
         default:
                 errno = EPFNOSUPPORT;
+                mutex_unlock(&port_lock);
                 return (-1);
         }
         sa->sa_family = af;
@@ -137,6 +145,8 @@ bindresvport_sa(sd, sa)
 	    port = LOWPORT + port % (STARTPORT - LOWPORT);
 	    goto again;
 	}
+	mutex_unlock(&port_lock);
+
         return (res);
 }
 #else
diff --git a/src/mt_misc.c b/src/mt_misc.c
index b24c130..ddbb0a5 100644
--- a/src/mt_misc.c
+++ b/src/mt_misc.c
@@ -94,6 +94,9 @@ pthread_mutex_t serialize_pkey = PTHREAD_MUTEX_INITIALIZER;
 /* protects global variables ni and nc_file (getnetconfig.c) */
 pthread_mutex_t nc_db_lock = PTHREAD_MUTEX_INITIALIZER;
 
+/* protects static port and startport (bindresvport.c) */
+pthread_mutex_t port_lock = PTHREAD_MUTEX_INITIALIZER;
+
 #undef	rpc_createerr
 
 struct rpc_createerr rpc_createerr;
-- 
1.8.4.2


--------------060408070601060409070600
Content-Type: text/x-patch;
 name="0003-Race-in-Race-in-clnt_vc_create.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="0003-Race-in-Race-in-clnt_vc_create.patch"

>From f850621962cb57c7bebfc93bd28db1f26be213aa Mon Sep 17 00:00:00 2001
From: Susant Sahani <ssahani@redhat.com>
Date: Sat, 23 Nov 2013 13:12:59 +0530
Subject: [PATCH 3/3] Race in Race in clnt_vc_create

 The function clnt_create is *not* thread safe. Race conditions in the
function clnt_vc_create that accesses static data disrupt, which is
*not* protected by any mutex. When more than one thread access it
it has become a nonlocal side effect . This race conditions can lead to
undesired behaviour . By introducing the mutex disrupt_lock
the function clnt_vc_create is serialized

Signed-off-by: Susant Sahani <ssahani@redhat.com>
---
 src/clnt_vc.c | 5 +++++
 src/mt_misc.c | 3 +++
 2 files changed, 8 insertions(+)

diff --git a/src/clnt_vc.c b/src/clnt_vc.c
index 2eab9e4..cbbfc58 100644
--- a/src/clnt_vc.c
+++ b/src/clnt_vc.c
@@ -173,14 +173,17 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
 	struct timeval now;
 	struct rpc_msg call_msg;
 	static u_int32_t disrupt;
+	extern pthread_mutex_t disrupt_lock;
 	sigset_t mask;
 	sigset_t newmask;
 	struct sockaddr_storage ss;
 	socklen_t slen;
 	struct __rpc_sockinfo si;
 
+	mutex_lock(&disrupt_lock);
 	if (disrupt == 0)
 		disrupt = (u_int32_t)(long)raddr;
+	mutex_unlock(&disrupt_lock);
 
 	cl = (CLIENT *)mem_alloc(sizeof (*cl));
 	ct = (struct ct_data *)mem_alloc(sizeof (*ct));
@@ -270,7 +273,9 @@ clnt_vc_create(fd, raddr, prog, vers, sendsz, recvsz)
 	 * Initialize call message
 	 */
 	(void)gettimeofday(&now, NULL);
+	mutex_lock(&disrupt_lock);
 	call_msg.rm_xid = ((u_int32_t)++disrupt) ^ __RPC_GETXID(&now);
+	mutex_unlock(&disrupt_lock);
 	call_msg.rm_direction = CALL;
 	call_msg.rm_call.cb_rpcvers = RPC_MSG_VERSION;
 	call_msg.rm_call.cb_prog = (u_int32_t)prog;
diff --git a/src/mt_misc.c b/src/mt_misc.c
index ddbb0a5..d459dec 100644
--- a/src/mt_misc.c
+++ b/src/mt_misc.c
@@ -97,6 +97,9 @@ pthread_mutex_t nc_db_lock = PTHREAD_MUTEX_INITIALIZER;
 /* protects static port and startport (bindresvport.c) */
 pthread_mutex_t port_lock = PTHREAD_MUTEX_INITIALIZER;
 
+/* protects static disrupt (clnt_vc.c) */
+pthread_mutex_t disrupt_lock = PTHREAD_MUTEX_INITIALIZER;
+
 #undef	rpc_createerr
 
 struct rpc_createerr rpc_createerr;
-- 
1.8.4.2


--------------060408070601060409070600--
