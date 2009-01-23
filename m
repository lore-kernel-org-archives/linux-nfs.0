From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH 1/3] nfs-utils: Hash only on IP address and Program number
Date: Fri, 23 Jan 2009 13:10:06 -0500
Message-ID: <497A07FE.9060008@RedHat.com>
References: <497A056E.1030606@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:46282 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753690AbZAWSMb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Jan 2009 13:12:31 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n0NICV9l001543
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2009 13:12:31 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n0NICVOX008498
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2009 13:12:32 -0500
Received: from xenhat.boston.devel.redhat.com (vpn-10-54.bos.redhat.com [10.16.10.54])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n0NICV5O003113
	for <linux-nfs@vger.kernel.org>; Fri, 23 Jan 2009 13:12:31 -0500
In-Reply-To: <497A056E.1030606-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

commit efc33a7844332bfe9f22b34ccf4035458a9b344a
Author: Steve Dickson <steved@redhat.com>
Date:   Fri Jan 23 08:59:19 2009 -0500

    Only hash on IP address and Program number. Including the Procedure
    number only creates needles extra hash entries.
    
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/misc/tcpwrapper.c b/support/misc/tcpwrapper.c
index 977dfca..a450ad5 100644
--- a/support/misc/tcpwrapper.c
+++ b/support/misc/tcpwrapper.c
@@ -108,8 +108,8 @@ typedef struct _hash_head {
 	TAILQ_HEAD(host_list, _haccess_t) h_head;
 } hash_head;
 hash_head haccess_tbl[HASH_TABLE_SIZE];
-static haccess_t *haccess_lookup(struct sockaddr_in *addr, u_long, u_long);
-static void haccess_add(struct sockaddr_in *addr, u_long, u_long, int);
+static haccess_t *haccess_lookup(struct sockaddr_in *addr, u_long);
+static void haccess_add(struct sockaddr_in *addr, u_long, int);
 
 inline unsigned int strtoint(char *str)
 {
@@ -126,11 +126,10 @@ inline int hashint(unsigned int num)
 {
 	return num % HASH_TABLE_SIZE;
 }
-#define HASH(_addr, _proc, _prog) \
-	hashint((strtoint((_addr))+(_proc)+(_prog)))
+#define HASH(_addr, _prog) \
+	hashint((strtoint((_addr))+(_prog)))
 
-void haccess_add(struct sockaddr_in *addr, u_long proc, 
-	u_long prog, int access)
+void haccess_add(struct sockaddr_in *addr, u_long prog, int access)
 {
 	hash_head *head;
  	haccess_t *hptr;
@@ -140,7 +139,7 @@ void haccess_add(struct sockaddr_in *addr, u_long proc,
 	if (hptr == NULL)
 		return;
 
-	hash = HASH(inet_ntoa(addr->sin_addr), proc, prog);
+	hash = HASH(inet_ntoa(addr->sin_addr), prog);
 	head = &(haccess_tbl[hash]);
 
 	hptr->access = access;
@@ -151,13 +150,13 @@ void haccess_add(struct sockaddr_in *addr, u_long proc,
 	else
 		TAILQ_INSERT_TAIL(&head->h_head, hptr, list);
 }
-haccess_t *haccess_lookup(struct sockaddr_in *addr, u_long proc, u_long prog)
+haccess_t *haccess_lookup(struct sockaddr_in *addr, u_long prog)
 {
 	hash_head *head;
  	haccess_t *hptr;
 	int hash;
 
-	hash = HASH(inet_ntoa(addr->sin_addr), proc, prog);
+	hash = HASH(inet_ntoa(addr->sin_addr), prog);
 	head = &(haccess_tbl[hash]);
 
 	TAILQ_FOREACH(hptr, &head->h_head, list) {
@@ -302,7 +301,7 @@ u_long  prog;
 	haccess_t *acc = NULL;
 	int changed = check_files();
 
-	acc = haccess_lookup(addr, proc, prog);
+	acc = haccess_lookup(addr, prog);
 	if (acc && changed == 0)
 		return (acc->access);
 
@@ -311,7 +310,7 @@ u_long  prog;
 		if (acc)
 			acc->access = FALSE;
 		else 
-			haccess_add(addr, proc, prog, FALSE);
+			haccess_add(addr, prog, FALSE);
 		return (FALSE);
 	}
 	if (verboselog)
@@ -320,7 +319,7 @@ u_long  prog;
 	if (acc)
 		acc->access = TRUE;
 	else 
-		haccess_add(addr, proc, prog, TRUE);
+		haccess_add(addr, prog, TRUE);
     return (TRUE);
 }
 
