From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 2/3] nfs-utils: Enabling TCP wrappers
Date: Mon, 15 Dec 2008 12:10:22 -0500
Message-ID: <49468F7E.1000408@RedHat.com>
References: <49468BC7.2000907@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:60494 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754199AbYLORMd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Dec 2008 12:12:33 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id mBFHCXHE008348
	for <linux-nfs@vger.kernel.org>; Mon, 15 Dec 2008 12:12:33 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id mBFHCWnd010357
	for <linux-nfs@vger.kernel.org>; Mon, 15 Dec 2008 12:12:33 -0500
Received: from [10.16.60.47] (xenhat.boston.devel.redhat.com [10.16.60.47])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id mBFHCWFH024828
	for <linux-nfs@vger.kernel.org>; Mon, 15 Dec 2008 12:12:32 -0500
In-Reply-To: <49468BC7.2000907-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit 6f970988b390633efbe3629fc2c19109f7cf96a3
Author: Steve Dickson <steved@redhat.com>
Date:   Mon Dec 15 11:31:45 2008 -0500

    Clients IP address and host names are check on
    every RPC request, to both mountd and statd
    when TCP wrappers are enabled. To help this
    process scale better the access rights are stored
    in a hash table, which are hashed per IP address,
    RPC program and procudure numbers.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/misc/tcpwrapper.c b/support/misc/tcpwrapper.c
index ceea5ce..f7fd3a9 100644
--- a/support/misc/tcpwrapper.c
+++ b/support/misc/tcpwrapper.c
@@ -44,6 +44,7 @@
 #include <pwd.h>
 #include <sys/types.h>
 #include <sys/signal.h>
+#include <sys/queue.h>
 #ifdef SYSV40
 #include <netinet/in.h>
 #include <rpc/rpcent.h>
@@ -89,6 +90,76 @@ int hosts_ctl(char *daemon, char *name, char *addr, char *user)
 #define ALLOW 1
 #define DENY 0
 
+typedef struct _haccess_t {
+	TAILQ_ENTRY(_haccess_t) list;
+	int access;
+    struct in_addr addr;
+} haccess_t;
+
+#define HASH_TABLE_SIZE 1021
+typedef struct _hash_head {
+	TAILQ_HEAD(host_list, _haccess_t) h_head;
+} hash_head;
+hash_head haccess_tbl[HASH_TABLE_SIZE];
+static haccess_t *haccess_lookup(struct sockaddr_in *addr, u_long, u_long);
+static void haccess_add(struct sockaddr_in *addr, u_long, u_long, int);
+
+inline unsigned int strtoint(char *str)
+{
+	unsigned int n = 0;
+	int len = strlen(str);
+	int i;
+
+	for (i=0; i < len; i++)
+		n+=((int)str[i])*i;
+
+	return n;
+}
+inline int hashint(unsigned int num)
+{
+	return num % HASH_TABLE_SIZE;
+}
+#define HASH(_addr, _proc, _prog) \
+	hashint((strtoint((_addr))+(_proc)+(_prog)))
+
+void haccess_add(struct sockaddr_in *addr, u_long proc, 
+	u_long prog, int access)
+{
+	hash_head *head;
+ 	haccess_t *hptr;
+	int hash;
+
+	hptr = (haccess_t *)malloc(sizeof(haccess_t));
+	if (hptr == NULL)
+		return;
+
+	hash = HASH(inet_ntoa(addr->sin_addr), proc, prog);
+	head = &(haccess_tbl[hash]);
+
+	hptr->access = access;
+	hptr->addr.s_addr = addr->sin_addr.s_addr;
+
+	if (TAILQ_EMPTY(&head->h_head))
+		TAILQ_INSERT_HEAD(&head->h_head, hptr, list);
+	else
+		TAILQ_INSERT_TAIL(&head->h_head, hptr, list);
+}
+haccess_t *haccess_lookup(struct sockaddr_in *addr, u_long proc, u_long prog)
+{
+	hash_head *head;
+ 	haccess_t *hptr;
+	int hash;
+
+	hash = HASH(inet_ntoa(addr->sin_addr), proc, prog);
+	head = &(haccess_tbl[hash]);
+
+	TAILQ_FOREACH(hptr, &head->h_head, list) {
+		if (hptr->addr.s_addr == addr->sin_addr.s_addr)
+			return hptr;
+	}
+	return NULL;
+}
+
 int
 good_client(daemon, addr)
 char *daemon;
@@ -184,13 +255,21 @@ struct sockaddr_in *addr;
 u_long  proc;
 u_long  prog;
 {
+	haccess_t *acc = NULL;
+
+	acc = haccess_lookup(addr, proc, prog);
+	if (acc)
+		return (acc->access);
+
 	if (!(from_local(addr) || good_client(daemon, addr))) {
 		log_bad_host(addr, proc, prog);
+		haccess_add(addr, proc, prog, FALSE);
 		return (FALSE);
 	}
 	if (verboselog)
 		log_client(addr, proc, prog);
 
+	haccess_add(addr, proc, prog, TRUE);
     return (TRUE);
 }
 
