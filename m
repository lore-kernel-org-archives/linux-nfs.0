From: Tomas Richter <krik3t@gmail.com>
Subject: Exportfs and rpc.mountd optimalization - patch
Date: Tue, 21 Jun 2005 21:51:21 +0200
Message-ID: <42B86FB9.6060102@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060303030504040107070500"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DkonY-00016a-M0
	for nfs@lists.sourceforge.net; Tue, 21 Jun 2005 12:52:40 -0700
Received: from wproxy.gmail.com ([64.233.184.206])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DkonX-0000Pz-Jp
	for nfs@lists.sourceforge.net; Tue, 21 Jun 2005 12:52:40 -0700
Received: by wproxy.gmail.com with SMTP id 36so1747891wra
        for <nfs@lists.sourceforge.net>; Tue, 21 Jun 2005 12:52:38 -0700 (PDT)
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

This is a multi-part message in MIME format.
--------------060303030504040107070500
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

There's patch for my optimalization of exportfs and rpc.mountd (attachment).

There were some problems with exportfs and rpc.mountd for long export 
lists - see https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=76643
I do optimalization as my bachelors thesis (Facuulty of informatics, 
Masaryk's university Brno, Czech Republic), under lead of Yenya Kasprzak.

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

Tomas Richter


--------------060303030504040107070500
Content-Type: text/plain;
 name="patch_optimalization"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="patch_optimalization"

diff -rbu nfs-utils/support/export/export.c nfs-utils-opt/support/export/export.c
--- nfs-utils/support/export/export.c	2005-06-20 23:26:00.000000000 +0200
+++ nfs-utils-opt/support/export/export.c	2005-05-05 16:15:45.000000000 +0200
@@ -4,6 +4,8 @@
  * Maintain list of exported file systems.
  *
  * Copyright (C) 1995, 1996 Olaf Kirch <okir@monad.swb.de>
+ *
+ * 2005 Tomas Richter <krik3t@gmail.com> Added hashing for exportlist
  */
 
 #include "config.h"
@@ -17,13 +19,15 @@
 #include "nfslib.h"
 #include "exportfs.h"
 
-nfs_export	*exportlist[MCL_MAXTYPES] = { NULL, };
+hash_table	exportlist[MCL_MAXTYPES] = {{NULL, {{NULL,NULL}, }}, }; 
 
 static void	export_init(nfs_export *exp, nfs_client *clp,
 					struct exportent *nep);
 static int	export_check(nfs_export *, struct hostent *, char *);
 static nfs_export *
 		export_allowed_internal(struct hostent *hp, char *path);
+void          hash_export_add(nfs_export*);
+nfs_export *  hash_export_lookup(char*, char*, int);
 
 int
 export_read(char *fname)
@@ -33,7 +37,7 @@
 
 	setexportent(fname, "r");
 	while ((eep = getexportent(0,1)) != NULL) {
-	  exp = export_lookup(eep->e_hostname, eep->e_path, 0);
+	  exp = hash_export_lookup(eep->e_hostname, eep->e_path, 0);
 	  if (!exp)
 	    export_create(eep,0);
 	  else {
@@ -72,7 +76,7 @@
 	}
 	exp = (nfs_export *) xmalloc(sizeof(*exp));
 	export_init(exp, clp, xep);
-	export_add(exp);
+	hash_export_add(exp);
 
 	return exp;
 }
@@ -113,11 +117,12 @@
 	new->m_exported = 0;
 	new->m_xtabent = 0;
 	new->m_changed = 0;
-	export_add(new);
+	hash_export_add(new);
 
 	return new;
 }
 
+/* This function was replaced by hash_export_add
 void
 export_add(nfs_export *exp)
 {
@@ -134,6 +139,7 @@
 	exp->m_next = *epp;
 	*epp = exp;
 }
+*/
 
 nfs_export *
 export_find(struct hostent *hp, char *path)
@@ -142,7 +148,7 @@
 	int		i;
 
 	for (i = 0; i < MCL_MAXTYPES; i++) {
-		for (exp = exportlist[i]; exp; exp = exp->m_next) {
+		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			if (!export_check(exp, hp, path))
 				continue;
 			if (exp->m_client->m_type == MCL_FQDN)
@@ -161,7 +167,7 @@
 	int		i;
 
 	for (i = 0; i < MCL_MAXTYPES; i++) {
-		for (exp = exportlist[i]; exp; exp = exp->m_next) {
+		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			if (!exp->m_mayexport ||
 			    !export_check(exp, hp, path))
 				continue;
@@ -199,6 +205,7 @@
 	return NULL;
 }
 
+/* This function was replace by hash_export_lookup
 nfs_export *
 export_lookup(char *hname, char *path, int canonical)
 {
@@ -207,11 +214,12 @@
 
 	if (!(clp = client_lookup(hname, canonical)))
 		return NULL;
-	for (exp = exportlist[clp->m_type]; exp; exp = exp->m_next)
+	for (exp = exportlist[clp->m_type].p_head; exp; exp = exp->m_next)
 		if (exp->m_client == clp && !strcmp(exp->m_export.e_path, path))
 			return exp;
 	return NULL;
 }
+*/
 
 static int
 export_check(nfs_export *exp, struct hostent *hp, char *path)
@@ -226,10 +234,10 @@
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
@@ -240,7 +248,11 @@
 				free(exp->m_export.e_mountpoint);
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
@@ -256,3 +268,90 @@
 		sizeof (exp->m_export.m_path) - 1);
 	exp->m_export.m_path[sizeof (exp->m_export.m_path) - 1] = '\0';
 }
+
+/*
+* Functions for work with hash table.
+*/
+
+/*
+* compute and returns int from string
+* int can be same for different strings, but in that case it doesn'n matter.
+*/
+unsigned int strtoint(char *str){
+  int i = 0;
+  unsigned int n = 0;
+  while ( str[i] != '\0') {
+    n+=((int)str[i])*i;
+    i++;
+  }
+  return n;
+}
+
+/*
+* represents hash function
+*/
+int hashint(unsigned int num){
+  return num % HASH_TABLE_SIZE;
+}
+
+/*
+* add nfs_export exp into hash table
+*/
+void hash_export_add(nfs_export *exp){
+  hash_table * p_tbl;
+  hash_entry * p_hen;
+  nfs_export * p_next;
+  
+  int type = exp->m_client->m_type;
+  /* hashing by m_hostname */
+  int pos = hashint(strtoint(exp->m_client->m_hostname)); 
+  
+  if (type < 0 || type >= MCL_MAXTYPES) {
+    xlog(L_FATAL, "unknown client type in hash_export_add");
+  }
+  
+  p_tbl = &(exportlist[type]); /* pointer to hash table */
+  p_hen = &(p_tbl->entries[pos]); /* pointer to hash table entry */
+  
+  if (!(p_hen->p_first)) { /* hash table entry is empty */ 
+     p_hen->p_first = exp;
+     p_hen->p_last  = exp;
+
+     exp->m_next = p_tbl->p_head;
+     p_tbl->p_head = exp;
+
+  } else { /* hash table entry is NOT empty */
+    p_next = p_hen->p_last->m_next;
+    p_hen->p_last->m_next = exp;
+    exp->m_next = p_next;
+    p_hen->p_last = exp;
+  }
+}
+
+/*
+* search for export in hash table
+* if it is present, returns pointer to export else returns NULL
+*/  
+nfs_export * hash_export_lookup(char *hname, char*path, int canonical) {
+  nfs_client * clp;
+  nfs_export * exp;
+  hash_entry * p_hen;
+  
+  if(!(clp = client_lookup(hname, canonical))) {
+    return NULL;
+  }
+  
+  int pos = hashint( strtoint( clp->m_hostname ) );
+  p_hen = &(exportlist[clp->m_type].entries[pos]); /* pointer to hash entry */ 
+  
+  for(exp = p_hen->p_first; exp && (exp != p_hen->p_last->m_next); 
+      exp = exp->m_next) {
+    if (exp->m_client == clp && !strcmp(exp->m_export.e_path, path)) {
+      return exp;
+    }
+  }
+  
+  return NULL;
+
+}
+
diff -rbu nfs-utils/support/export/rmtab.c nfs-utils-opt/support/export/rmtab.c
--- nfs-utils/support/export/rmtab.c	2005-06-20 23:26:00.000000000 +0200
+++ nfs-utils-opt/support/export/rmtab.c	2005-04-24 15:31:35.000000000 +0200
@@ -36,7 +36,7 @@
 			/* see if the entry already exists, otherwise this was an instantiated
 			 * wild card, and we must add it
 			 */
-			nfs_export *exp2 = export_lookup(rep->r_client,
+			nfs_export *exp2 = hash_export_lookup(rep->r_client,
 							exp->m_export.e_path, 0);
 			if (!exp2) {
 				struct exportent ee;
diff -rbu nfs-utils/support/export/xtab.c nfs-utils-opt/support/export/xtab.c
--- nfs-utils/support/export/xtab.c	2005-06-20 23:26:00.000000000 +0200
+++ nfs-utils-opt/support/export/xtab.c	2005-04-24 15:31:04.000000000 +0200
@@ -35,7 +35,7 @@
 		return 0;
 	setexportent(xtab, "r");
 	while ((xp = getexportent(is_export==0, 0)) != NULL) {
-		if (!(exp = export_lookup(xp->e_hostname, xp->e_path, is_export != 1)) &&
+		if (!(exp = hash_export_lookup(xp->e_hostname, xp->e_path, is_export != 1)) &&
 		    !(exp = export_create(xp, is_export!=1))) {
 			continue;
 		}
@@ -92,7 +92,7 @@
 	setexportent(xtabtmp, "w");
 
 	for (i = 0; i < MCL_MAXTYPES; i++) {
-		for (exp = exportlist[i]; exp; exp = exp->m_next) {
+		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			if (is_export && !exp->m_xtabent)
 				continue;
 			if (!is_export && ! exp->m_exported)
diff -rbu nfs-utils/support/include/exportfs.h nfs-utils-opt/support/include/exportfs.h
--- nfs-utils/support/include/exportfs.h	2005-06-20 23:26:00.000000000 +0200
+++ nfs-utils-opt/support/include/exportfs.h	2005-04-24 20:17:10.000000000 +0200
@@ -9,6 +9,8 @@
 #ifndef EXPORTFS_H
 #define EXPORTFS_H
 
+#define HASH_TABLE_SIZE 1021
+
 #include <netdb.h>
 #include "nfslib.h"
 
@@ -43,8 +45,18 @@
 				m_changed  : 1; /* options (may) have changed */
 } nfs_export;
 
+typedef struct m_hash_entry {
+  nfs_export * p_first;
+  nfs_export * p_last;
+} hash_entry;
+
+typedef struct m_hash_table {
+  nfs_export * p_head;
+  hash_entry entries[HASH_TABLE_SIZE];
+} hash_table;
+
 extern nfs_client *		clientlist[MCL_MAXTYPES];
-extern nfs_export *		exportlist[MCL_MAXTYPES];
+extern hash_table exportlist[MCL_MAXTYPES];
 
 nfs_client *			client_lookup(char *hname, int canonical);
 nfs_client *			client_find(struct hostent *);
@@ -59,9 +71,11 @@
 int 				client_member(char *client, char *name);
 
 int				export_read(char *fname);
-void				export_add(nfs_export *);
+/* void				export_add(nfs_export *);*/
+void          hash_export_add(nfs_export *exp);
 void				export_reset(nfs_export *);
-nfs_export *			export_lookup(char *hname, char *path, int caconical);
+/* nfs_export *			export_lookup(char *hname, char *path, int caconical); */
+nfs_export *			hash_export_lookup(char *hname, char *path, int caconical);
 nfs_export *			export_find(struct hostent *, char *path);
 nfs_export *			export_allowed(struct hostent *, char *path);
 nfs_export *			export_create(struct exportent *, int canonical);
diff -rbu nfs-utils/utils/exportfs/exportfs.c nfs-utils-opt/utils/exportfs/exportfs.c
--- nfs-utils/utils/exportfs/exportfs.c	2005-06-20 23:28:00.000000000 +0200
+++ nfs-utils-opt/utils/exportfs/exportfs.c	2005-06-20 23:58:45.000000000 +0200
@@ -189,10 +189,10 @@
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
@@ -208,7 +208,7 @@
 	int		i;
 
 	for (i = 0; i < MCL_MAXTYPES; i++) {
-		for (exp = exportlist[i]; exp; exp = exp->m_next) {
+		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			if (verbose)
 				printf("exporting %s:%s\n",
 				       exp->m_client->m_hostname, 
@@ -252,7 +252,7 @@
 		exp = export_find(hp, path);
 		hname = hp->h_name;
 	} else {
-		exp = export_lookup(hname, path, 0);
+		exp = hash_export_lookup(hname, path, 0);
 	}
 
 	if (!exp) {
@@ -300,7 +300,7 @@
 		}
 	}
 
-	for (exp = exportlist[htype]; exp; exp = exp->m_next) {
+	for (exp = exportlist[htype].p_head; exp; exp = exp->m_next) {
 		if (path && strcmp(path, exp->m_export.e_path))
 			continue;
 		if (htype != exp->m_client->m_type)
@@ -357,7 +357,7 @@
 	char		*hname, c;
 
 	for (htype = 0; htype < MCL_MAXTYPES; htype++) {
-		for (exp = exportlist[htype]; exp; exp = exp->m_next) {
+		for (exp = exportlist[htype].p_head; exp; exp = exp->m_next) {
 			ep = &exp->m_export;
 			if (!exp->m_xtabent)
 			    continue; /* neilb */
Pouze v nfs-utils-opt/utils/exportfs: exportfs.c~
diff -rbu nfs-utils/utils/mountd/auth.c nfs-utils-opt/utils/mountd/auth.c
--- nfs-utils/utils/mountd/auth.c	2005-06-20 23:28:00.000000000 +0200
+++ nfs-utils-opt/utils/mountd/auth.c	2005-04-24 15:23:14.000000000 +0200
@@ -93,7 +93,7 @@
 
 		exp = NULL;
 		for (i = 0; !exp && i < MCL_MAXTYPES; i++) 
-			for (exp = exportlist[i]; exp; exp = exp->m_next) {
+			for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 				if (!client_member(my_client.m_hostname, exp->m_client->m_hostname))
 					continue;
 				if (strcmp(path, exp->m_export.e_path))
diff -rbu nfs-utils/utils/mountd/cache.c nfs-utils-opt/utils/mountd/cache.c
--- nfs-utils/utils/mountd/cache.c	2005-06-20 23:28:00.000000000 +0200
+++ nfs-utils-opt/utils/mountd/cache.c	2005-04-24 15:24:14.000000000 +0200
@@ -144,7 +144,7 @@
 
 	/* Now determine export point for this fsid/domain */
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
-		for (exp = exportlist[i]; exp; exp = exp->m_next) {
+		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			if (!client_member(dom, exp->m_client->m_hostname))
 				continue;
 			if (fsidtype == 1 &&
@@ -244,7 +244,7 @@
 
 	/* now find flags for this export point in this domain */
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
-		for (exp = exportlist[i]; exp; exp = exp->m_next) {
+		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			if (!client_member(dom, exp->m_client->m_hostname))
 				continue;
 			if (strcmp(path, exp->m_export.e_path))
diff -rbu nfs-utils/utils/mountd/mountd.c nfs-utils-opt/utils/mountd/mountd.c
--- nfs-utils/utils/mountd/mountd.c	2005-06-20 23:28:00.000000000 +0200
+++ nfs-utils-opt/utils/mountd/mountd.c	2005-06-20 23:53:01.000000000 +0200
@@ -371,7 +371,7 @@
 	elist = NULL;
 
 	for (i = 0; i < MCL_MAXTYPES; i++) {
-		for (exp = exportlist[i]; exp; exp = exp->m_next) {
+		for (exp = exportlist[i].p_head; exp; exp = exp->m_next) {
 			for (e = elist; e != NULL; e = e->ex_next) {
 				if (!strcmp(exp->m_export.m_path, e->ex_dir))
 					break;

--------------060303030504040107070500--



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
