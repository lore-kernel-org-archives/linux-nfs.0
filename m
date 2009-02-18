From: Steve Dickson <SteveD@redhat.com>
Subject: [PATCH] Exportfs and rpc.mountd optimalization (revisited)
Date: Wed, 18 Feb 2009 13:50:09 -0500
Message-ID: <499C5861.6050408@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:41891 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751095AbZBRSwl (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 18 Feb 2009 13:52:41 -0500
Received: from int-mx2.corp.redhat.com (int-mx2.corp.redhat.com [172.16.27.26])
	by mx2.redhat.com (8.13.8/8.13.8) with ESMTP id n1IIqeZ3024843
	for <linux-nfs@vger.kernel.org>; Wed, 18 Feb 2009 13:52:40 -0500
Received: from ns3.rdu.redhat.com (ns3.rdu.redhat.com [10.11.255.199])
	by int-mx2.corp.redhat.com (8.13.1/8.13.1) with ESMTP id n1IIqemc025205
	for <linux-nfs@vger.kernel.org>; Wed, 18 Feb 2009 13:52:41 -0500
Received: from xenhat.boston.devel.redhat.com (vpn-10-20.bos.redhat.com [10.16.10.20])
	by ns3.rdu.redhat.com (8.13.8/8.13.8) with ESMTP id n1IIqcjM031902
	for <linux-nfs@vger.kernel.org>; Wed, 18 Feb 2009 13:52:39 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Very long time ago Tomas Richter submitted a patch that added
a export hash table to both exportfs and mountd. Very recently 
I ran across it and actually used some parts in the recent TCP
wrappers patch... 

Looking at the discussion 
    http://marc.info/?l=linux-nfs&m=111938362106991&w=2
It seem no one took the time to test out the patch.. There
was even a Red Hat bug opened on it but for some reason
it got closed... Anyway... 

This is a good patch... imho.. It does help with very large exports 
at least in my testing... And I'm also hoping the hash table will
useful in the pseudo root work... 

Any objections to committing this?? 

steved.

commit 4cacc965afc4fb03a465ffcc6cb3078aeadc3818
Author: Tomas Richter <krik3t@gmail.com>
Date:   Wed Feb 18 13:33:27 2009 -0500

    Exportfs and rpc.mountd optimalization
    
    There were some problems with exportfs and rpc.mountd for long export
    lists - see https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=76643
    I do optimalization as my bachelors thesis (Facuulty of informatics,
    Masaryk's university Brno, Czech Republic), under lead of Yenya
    Kasprzak.
    
    Both exportfs and rpc.mount build linked list of exports (shared
    functions in export.c). Every time they are inserting new export into
    list, they search for same export in list.
    I replaced linked list by hash table and functions export_add and
    export_lookup by functions hash_export_add and hash_export_lookup
    (export.c).
    
    Because some other functions required exportlist as linked list, hash
    table has some implementation modification im comparison with ordinary
    hash table. It also keeps exports in linked list  and has pointer to
    head of the list. So there's no need of implementation function
    <for_all_in_hash_table>.
    
    Signed-off-by: Tomas Richter <krik3t@gmail.com>
    Signed-off-by: Steve Dickson <steved@redhat.com>

diff --git a/support/export/export.c b/support/export/export.c
index 14af112..e5e6cb0 100644
--- a/support/export/export.c
+++ b/support/export/export.c
@@ -19,7 +19,8 @@
 #include "nfslib.h"
 #include "exportfs.h"
 
-nfs_export	*exportlist[MCL_MAXTYPES] = { NULL, };
+exp_hash_table exportlist[MCL_MAXTYPES] = {{NULL, {{NULL,NULL}, }}, }; 
+static int export_hash(char *);
 
 static void	export_init(nfs_export *exp, nfs_client *clp,
 					struct exportent *nep);
@@ -125,22 +126,35 @@ export_dup(nfs_export *exp, struct hostent *hp)
 
 	return new;
 }
-
-void
+/*
+ * Add export entry to hash table
+ */
+void 
 export_add(nfs_export *exp)
 {
-	nfs_export	**epp;
-	int		type = exp->m_client->m_type;
-	int		slen = strlen(exp->m_export.e_path);
-
-	if (type < 0 || type >= MCL_MAXTYPES)
-		xlog(L_FATAL, "unknown client type in export_add");
-
-	epp = exportlist + type;
-	while (*epp && slen <= strlen((*epp)->m_export.e_path))
-		epp = &((*epp)->m_next);
-	exp->m_next = *epp;
-	*epp = exp;
+	exp_hash_table *p_tbl;
+	exp_hash_entry *p_hen;
+	nfs_export *p_next;
+
+	int type = exp->m_client->m_type;
+	int pos;
+
+	pos = export_hash(exp->m_export.e_path);
+	p_tbl = &(exportlist[type]); /* pointer to hash table */
+	p_hen = &(p_tbl->entries[pos]); /* pointer to hash table entry */
+
+	if (!(p_hen->p_first)) { /* hash table entry is empty */ 
+ 		p_hen->p_first = exp;
+ 		p_hen->p_last  = exp;
+
+ 		exp->m_next = p_tbl->p_head;
+ 		p_tbl->p_head = exp;
+	} else { /* hash table entry is NOT empty */
+		p_next = p_hen->p_last->m_next;
+		p_hen->p_last->m_next = exp;
+		exp->m_next = p_next;
+		p_hen->p_last = exp;
+	}
 }
 
 nfs_export *
@@ -150,7 +164,7 @@ export_find(struct hostent *hp, char *path)
 	int		i;
 
 	for (i = 0; i < MCL_MAXTYPES; i++) {
-		for (exp = exportlist[i]; exp; exp = exp->m_next) {
+		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			if (!export_check(exp, hp, path))
 				continue;
 			if (exp->m_client->m_type == MCL_FQDN)
@@ -169,7 +183,7 @@ export_allowed_internal (struct hostent *hp, char *path)
 	int		i;
 
 	for (i = 0; i < MCL_MAXTYPES; i++) {
-		for (exp = exportlist[i]; exp; exp = exp->m_next) {
+		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			if (!exp->m_mayexport ||
 			    !export_check(exp, hp, path))
 				continue;
@@ -207,17 +221,30 @@ export_allowed(struct hostent *hp, char *path)
 	return NULL;
 }
 
+/*
+ * Search hash table for export entry. 
+ */  
 nfs_export *
-export_lookup(char *hname, char *path, int canonical)
+export_lookup(char *hname, char *path, int canonical) 
 {
-	nfs_client	*clp;
-	nfs_export	*exp;
+	nfs_client *clp;
+	nfs_export *exp;
+	exp_hash_entry *p_hen;
+
+	int pos;
 
-	if (!(clp = client_lookup(hname, canonical)))
+	clp = client_lookup(hname, canonical);
+	if(clp == NULL)
 		return NULL;
-	for (exp = exportlist[clp->m_type]; exp; exp = exp->m_next)
-		if (exp->m_client == clp && !strcmp(exp->m_export.e_path, path))
-			return exp;
+
+	pos = export_hash(path);
+	p_hen = &(exportlist[clp->m_type].entries[pos]); 
+	for(exp = p_hen->p_first; exp && (exp != p_hen->p_last->m_next); 
+  			exp = exp->m_next) {
+		if (exp->m_client == clp && !strcmp(exp->m_export.e_path, path)) {
+  			return exp;
+		}
+	}
 	return NULL;
 }
 
@@ -234,10 +261,10 @@ void
 export_freeall(void)
 {
 	nfs_export	*exp, *nxt;
-	int		i;
+	int		i, j;
 
 	for (i = 0; i < MCL_MAXTYPES; i++) {
-		for (exp = exportlist[i]; exp; exp = nxt) {
+		for (exp = exportlist[i].p_head; exp; exp = nxt) {
 			nxt = exp->m_next;
 			client_release(exp->m_client);
 			if (exp->m_export.e_squids)
@@ -251,7 +278,40 @@ export_freeall(void)
 			xfree(exp->m_export.e_hostname);
 			xfree(exp);
 		}
-		exportlist[i] = NULL;
+      for(j = 0; j < HASH_TABLE_SIZE; j++) {
+        exportlist[i].entries[j].p_first = NULL;
+        exportlist[i].entries[j].p_last = NULL;
+      }
+      exportlist[i].p_head = NULL;
 	}
 	client_freeall();
 }
+
+/*
+ * Compute and returns integer from string. 
+ * Note: Its understood the smae integers can be same for 
+ *       different strings, but it should not matter.
+ */
+static unsigned int 
+strtoint(char *str)
+{
+	int i = 0;
+	unsigned int n = 0;
+
+	while ( str[i] != '\0') {
+		n+=((int)str[i])*i;
+		i++;
+	}
+	return n;
+}
+
+/*
+ * Hash function
+ */
+static int 
+export_hash(char *str)
+{
+	int num = strtoint(str);
+
+	return num % HASH_TABLE_SIZE;
+}
diff --git a/support/export/xtab.c b/support/export/xtab.c
index 990113e..510765a 100644
--- a/support/export/xtab.c
+++ b/support/export/xtab.c
@@ -100,7 +100,7 @@ xtab_write(char *xtab, char *xtabtmp, int is_export)
 	setexportent(xtabtmp, "w");
 
 	for (i = 0; i < MCL_MAXTYPES; i++) {
-		for (exp = exportlist[i]; exp; exp = exp->m_next) {
+		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			if (is_export && !exp->m_xtabent)
 				continue;
 			if (!is_export && ! exp->m_exported)
diff --git a/support/include/exportfs.h b/support/include/exportfs.h
index c1ba543..a5cf482 100644
--- a/support/include/exportfs.h
+++ b/support/include/exportfs.h
@@ -52,8 +52,21 @@ typedef struct mexport {
 						 * matching one client */
 } nfs_export;
 
+#define HASH_TABLE_SIZE 1021
+
+typedef struct _exp_hash_entry {
+	nfs_export * p_first;
+  	nfs_export * p_last;
+} exp_hash_entry;
+
+typedef struct _exp_hash_table {
+	nfs_export * p_head;
+	exp_hash_entry entries[HASH_TABLE_SIZE];
+} exp_hash_table;
+
+extern exp_hash_table exportlist[MCL_MAXTYPES];
+
 extern nfs_client *		clientlist[MCL_MAXTYPES];
-extern nfs_export *		exportlist[MCL_MAXTYPES];
 
 nfs_client *			client_lookup(char *hname, int canonical);
 nfs_client *			client_find(struct hostent *);
@@ -69,7 +82,7 @@ struct hostent *		client_resolve(struct in_addr addr);
 int 				client_member(char *client, char *name);
 
 int				export_read(char *fname);
-void				export_add(nfs_export *);
+void			export_add(nfs_export *);
 void				export_reset(nfs_export *);
 nfs_export *			export_lookup(char *hname, char *path, int caconical);
 nfs_export *			export_find(struct hostent *, char *path);
diff --git a/support/misc/tcpwrapper.c b/support/misc/tcpwrapper.c
index 977dfca..e9eb1df 100644
--- a/support/misc/tcpwrapper.c
+++ b/support/misc/tcpwrapper.c
@@ -122,7 +122,7 @@ inline unsigned int strtoint(char *str)
 
 	return n;
 }
-inline int hashint(unsigned int num)
+static inline int hashint(unsigned int num)
 {
 	return num % HASH_TABLE_SIZE;
 }
diff --git a/utils/exportfs/exportfs.c b/utils/exportfs/exportfs.c
index fec2571..593a8eb 100644
--- a/utils/exportfs/exportfs.c
+++ b/utils/exportfs/exportfs.c
@@ -111,7 +111,6 @@ main(int argc, char **argv)
 			return 0;
 		}
 	}
-
 	if (f_export && ! f_ignore)
 		export_read(_PATH_EXPORTS);
 	if (f_export) {
@@ -193,10 +192,10 @@ exports_update(int verbose)
 {
 	nfs_export 	*exp;
 
-	for (exp = exportlist[MCL_FQDN]; exp; exp=exp->m_next) {
+	for (exp = exportlist[MCL_FQDN].p_head; exp; exp=exp->m_next) {
 		exports_update_one(exp, verbose);
 	}
-	for (exp = exportlist[MCL_GSS]; exp; exp=exp->m_next) {
+	for (exp = exportlist[MCL_GSS].p_head; exp; exp=exp->m_next) {
 		exports_update_one(exp, verbose);
 	}
 }
@@ -212,7 +211,7 @@ export_all(int verbose)
 	int		i;
 
 	for (i = 0; i < MCL_MAXTYPES; i++) {
-		for (exp = exportlist[i]; exp; exp = exp->m_next) {
+		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			if (verbose)
 				printf("exporting %s:%s\n",
 				       exp->m_client->m_hostname, 
@@ -308,7 +307,7 @@ unexportfs(char *arg, int verbose)
 		}
 	}
 
-	for (exp = exportlist[htype]; exp; exp = exp->m_next) {
+	for (exp = exportlist[htype].p_head; exp; exp = exp->m_next) {
 		if (path && strcmp(path, exp->m_export.e_path))
 			continue;
 		if (htype != exp->m_client->m_type)
@@ -453,7 +452,7 @@ dump(int verbose)
 	char		*hname, c;
 
 	for (htype = 0; htype < MCL_MAXTYPES; htype++) {
-		for (exp = exportlist[htype]; exp; exp = exp->m_next) {
+		for (exp = exportlist[htype].p_head; exp; exp = exp->m_next) {
 			ep = &exp->m_export;
 			if (!exp->m_xtabent)
 			    continue; /* neilb */
diff --git a/utils/mountd/auth.c b/utils/mountd/auth.c
index dfe61ea..575f207 100644
--- a/utils/mountd/auth.c
+++ b/utils/mountd/auth.c
@@ -142,7 +142,7 @@ auth_authenticate_internal(char *what, struct sockaddr_in *caller,
 
 		exp = NULL;
 		for (i = 0; !exp && i < MCL_MAXTYPES; i++) 
-			for (exp = exportlist[i]; exp; exp = exp->m_next) {
+			for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 				if (strcmp(path, exp->m_export.e_path))
 					continue;
 				if (!use_ipaddr && !client_member(my_client.m_hostname, exp->m_client->m_hostname))
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index fa15472..9bbbfb3 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -394,7 +394,7 @@ void nfsd_fh(FILE *f)
 	/* Now determine export point for this fsid/domain */
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
 		nfs_export *next_exp;
-		for (exp = exportlist[i]; exp; exp = next_exp) {
+		for (exp = exportlist[i].p_head; exp; exp = next_exp) {
 			struct stat stb;
 			char u[16];
 			char *path;
@@ -654,7 +654,7 @@ void nfsd_export(FILE *f)
 
 	/* now find flags for this export point in this domain */
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
-		for (exp = exportlist[i]; exp; exp = exp->m_next) {
+		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			if (!use_ipaddr && !client_member(dom, exp->m_client->m_hostname))
 				continue;
 			if (exp->m_export.e_flags & NFSEXP_CROSSMOUNT) {
diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 6adb68f..deeaa07 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -521,7 +521,7 @@ get_exportlist(void)
 	elist = NULL;
 
 	for (i = 0; i < MCL_MAXTYPES; i++) {
-		for (exp = exportlist[i]; exp; exp = exp->m_next) {
+		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			for (e = elist; e != NULL; e = e->ex_next) {
 				if (!strcmp(exp->m_export.e_path, e->ex_dir))
 					break;
