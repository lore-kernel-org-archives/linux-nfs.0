From: fumihiko kakuma <kakmy@mvh.biglobe.ne.jp>
Subject: Re: exporfs no keep sequence of etab entry
Date: Mon, 14 Jul 2003 16:52:03 +0900
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030714165117.1C2E.KAKMY@mvh.biglobe.ne.jp>
References: <20030709202020.5172.KAKMY@mvh.biglobe.ne.jp>
Reply-To: kakuma@tko.ncs.co.jp
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from rcpt-expgw.biglobe.ne.jp ([202.225.89.184])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19by89-0003W8-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Jul 2003 00:52:17 -0700
To: kakuma@tko.ncs.co.jp
In-Reply-To: <20030709202020.5172.KAKMY@mvh.biglobe.ne.jp>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


On Wed, 09 Jul 2003 20:20:32 +0900
fumihiko kakuma <kakmy@mvh.biglobe.ne.jp> wrote:

> =================================================================================
> --- support/export/export.c.orig	Wed Jul  9 17:36:58 2003
> +++ support/export/export.c	Wed Jul  9 17:36:59 2003
> @@ -124,15 +124,34 @@
>  	nfs_export	**epp;
>  	int		type = exp->m_client->m_type;
>  	int		slen = strlen(exp->m_export.e_path);
> +	int		eslen;
>  
>  	if (type < 0 || type >= MCL_MAXTYPES)
>  		xlog(L_FATAL, "unknown client type in export_add");
>  
>  	epp = exportlist + type;
> -	while (*epp && slen < strlen((*epp)->m_export.e_path))
> +	while (*epp && slen <= (eslen = strlen((*epp)->m_export.e_path))) {
> +		if (slen == eslen && 
> +		(*epp)->m_mayexport && (*epp)->m_changed)
> +			break;
>  		epp = &((*epp)->m_next);
> -	exp->m_next = *epp;
> -	*epp = exp;
> +	}
> +	if (!(*epp)) {						/* queing ahead */
> +		exp->m_next = *epp;
> +		*epp = exp;
> +	} else if (slen > eslen) {				/* queing ahead */
> +		exp->m_next = *epp;
> +		*epp = exp;
> +	} else if (slen < eslen) {				/* queing behind */
> +		exp->m_next = (*epp)->m_next;
> +		(*epp)->m_next = exp;
> +	} else if ((*epp)->m_mayexport && (*epp)->m_changed){	/* queing ahead */
> +		exp->m_next = *epp;
> +		*epp = exp;
> +	} else {						/* queing behind */
> +		exp->m_next = (*epp)->m_next;
> +		(*epp)->m_next = exp;
> +	}
>  }
>  
>  nfs_export *
> =================================================================================

I'm sorry.
The above patch had been insufficient patch.
It will not keep the priority for the request from mountd.
It needs the following patch.

The following patch use a easy way.
At the other way, there may be idea that In function export_find()
search applied queue making reverse chain for queues of exportlist,
make another function of export.c and xtab.c for mountd or
add argument of function export_create(), export_dup().
I had not thought that those are good ways, and I can't find
the other better way.

=================================================================================
diff -ruN nfs-utils-1.0.orig/support/export/export.c nfs-utils-1.0/support/export/export.c
--- nfs-utils-1.0.orig/support/export/export.c	Thu Dec 27 10:47:31 2001
+++ nfs-utils-1.0/support/export/export.c	Mon Jul 14 10:19:26 2003
@@ -18,6 +18,7 @@
 #include "exportfs.h"
 
 nfs_export	*exportlist[MCL_MAXTYPES] = { NULL, };
+int		exportlist_flg = EXPORTLIST_WRT;
 
 static void	export_init(nfs_export *exp, nfs_client *clp,
 					struct exportent *nep);
@@ -72,7 +73,10 @@
 	}
 	exp = (nfs_export *) xmalloc(sizeof(*exp));
 	export_init(exp, clp, xep);
-	export_add(exp);
+	if (exportlist_flg == EXPORTLIST_WRT)
+		export_add(exp);
+	else
+		export_add_priority(exp);
 
 	return exp;
 }
@@ -113,13 +117,52 @@
 	new->m_exported = 0;
 	new->m_xtabent = 0;
 	new->m_changed = 0;
-	export_add(new);
+	if (exportlist_flg == EXPORTLIST_WRT)
+		export_add(new);
+	else
+		export_add_priority(new);
 
 	return new;
 }
 
 void
 export_add(nfs_export *exp)
+{
+	nfs_export	**epp;
+	int		type = exp->m_client->m_type;
+	int		slen = strlen(exp->m_export.e_path);
+	int		eslen;
+
+	if (type < 0 || type >= MCL_MAXTYPES)
+		xlog(L_FATAL, "unknown client type in export_add");
+
+	epp = exportlist + type;
+	while (*epp && slen <= (eslen = strlen((*epp)->m_export.e_path))) {
+		if (slen == eslen && 
+		(*epp)->m_mayexport && (*epp)->m_changed)
+			break;
+		epp = &((*epp)->m_next);
+	}
+	if (!(*epp)) {						/* queueing ahead */
+		exp->m_next = *epp;
+		*epp = exp;
+	} else if (slen > eslen) {				/* queueing ahead */
+		exp->m_next = *epp;
+		*epp = exp;
+	} else if (slen < eslen) {				/* queueing behind */
+		exp->m_next = (*epp)->m_next;
+		(*epp)->m_next = exp;
+	} else if ((*epp)->m_mayexport && (*epp)->m_changed){	/* queueing ahead */
+		exp->m_next = *epp;
+		*epp = exp;
+	} else {						/* queueing behind */
+		exp->m_next = (*epp)->m_next;
+		(*epp)->m_next = exp;
+	}
+}
+
+void
+export_add_priority(nfs_export *exp)
 {
 	nfs_export	**epp;
 	int		type = exp->m_client->m_type;
diff -ruN nfs-utils-1.0.orig/support/include/exportfs.h nfs-utils-1.0/support/include/exportfs.h
--- nfs-utils-1.0.orig/support/include/exportfs.h	Tue Oct  9 05:50:20 2001
+++ nfs-utils-1.0/support/include/exportfs.h	Mon Jul 14 10:19:49 2003
@@ -12,6 +12,9 @@
 #include <netdb.h>
 #include "nfslib.h"
 
+#define EXPORTLIST_PRI 1
+#define EXPORTLIST_WRT 0
+
 enum {
 	MCL_FQDN = 0,
 	MCL_SUBNETWORK,
@@ -44,6 +47,7 @@
 
 extern nfs_client *		clientlist[MCL_MAXTYPES];
 extern nfs_export *		exportlist[MCL_MAXTYPES];
+extern int			exportlist_flg;
 
 nfs_client *			client_lookup(char *hname, int canonical);
 nfs_client *			client_find(struct hostent *);
@@ -57,6 +61,7 @@
 
 int				export_read(char *fname);
 void				export_add(nfs_export *);
+void				export_add_priority(nfs_export *);
 void				export_reset(nfs_export *);
 nfs_export *			export_lookup(char *hname, char *path, int caconical);
 nfs_export *			export_find(struct hostent *, char *path);
diff -ruN nfs-utils-1.0.orig/utils/mountd/mountd.c nfs-utils-1.0/utils/mountd/mountd.c
--- nfs-utils-1.0.orig/utils/mountd/mountd.c	Fri Oct 12 05:00:55 2001
+++ nfs-utils-1.0/utils/mountd/mountd.c	Mon Jul 14 10:20:22 2003
@@ -397,6 +397,7 @@
 	struct sigaction sa;
 	struct rlimit rlim;
 
+	exportlist_flg = EXPORTLIST_PRI;
 	/* Parse the command line options and arguments. */
 	opterr = 0;
 	while ((c = getopt_long(argc, argv, "o:Fd:f:p:P:hN:V:v", longopts, NULL)) != EOF)
=================================================================================

-- 
fumihiko kakuma <kakmy@mvh.biglobe.ne.jp>



-------------------------------------------------------
This SF.Net email sponsored by: Parasoft
Error proof Web apps, automate testing & more.
Download & eval WebKing and get a free book.
www.parasoft.com/bulletproofapps1
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
