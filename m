From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 9 of 16 - Discard cl_addr
Date: Thu, 12 Sep 2002 12:35:27 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1020912023527.19621@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJpW-0002I6-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:35:42 -0700
To: Linus Torvalds <torvalds@transmeta.com>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


### Comments for ChangeSet

We currently store the address list with each
client and use it only to print out comments
on /proc/fs/nfs/exports
While these can be helpful, they are not critical and
could be added back later after we restructure the exports
table.

 ----------- Diffstat output ------------
 ./fs/nfsd/export.c            |   37 ++-----------------------------------
 ./include/linux/nfsd/export.h |    2 --
 2 files changed, 2 insertions(+), 37 deletions(-)

--- ./include/linux/nfsd/export.h	2002/09/11 01:35:40	1.6
+++ ./include/linux/nfsd/export.h	2002/09/11 01:37:30	1.7
@@ -51,8 +51,6 @@
 struct svc_client {
 	struct svc_client *	cl_next;
 	char			cl_ident[NFSCLNT_IDMAX];
-	int			cl_naddr;
-	struct in_addr		cl_addr[NFSCLNT_ADDRMAX];
 	struct list_head	cl_export[NFSCLNT_EXPMAX];
 	struct list_head	cl_expfsid[NFSCLNT_EXPMAX];
 	struct list_head	cl_list;
--- ./fs/nfsd/export.c	2002/09/11 01:35:40	1.8
+++ ./fs/nfsd/export.c	2002/09/11 01:37:30	1.9
@@ -640,7 +640,6 @@ static int e_show(struct seq_file *m, vo
 	struct svc_export *exp = p;
 	struct svc_client *clp;
 	char *pbuf;
-	int j, first = 0;
 
 	if (p == (void *)1) {
 		seq_puts(m, "# Version 1.1\n");
@@ -659,31 +658,7 @@ static int e_show(struct seq_file *m, vo
 	seq_putc(m, '(');
 	exp_flags(m, exp->ex_flags, exp->ex_fsid, 
 		  exp->ex_anon_uid, exp->ex_anon_gid);
-	seq_puts(m, ") # ");
-	for (j = 0; j < clp->cl_naddr; j++) {
-		struct svc_clnthash **hp, **head, *tmp;
-		struct in_addr addr = clp->cl_addr[j]; 
-
-		head = &clnt_hash[CLIENT_HASH(addr.s_addr)];
-		for (hp = head; (tmp = *hp) != NULL; hp = &(tmp->h_next)) {
-			if (tmp->h_addr.s_addr == addr.s_addr)
-				break;
-		}
-		if (tmp) {
-			if (first++)
-				seq_putc(m, ' ');
-			if (tmp->h_client != clp)
-				seq_putc(m, '(');
-			seq_printf(m, "%d.%d.%d.%d",
-				htonl(addr.s_addr) >> 24 & 0xff,
-				htonl(addr.s_addr) >> 16 & 0xff,
-				htonl(addr.s_addr) >>  8 & 0xff,
-				htonl(addr.s_addr) >>  0 & 0xff);
-			if (tmp->h_client != clp)
-				seq_putc(m, ')');
-		}
-	}
-	seq_putc(m, '\n');
+	seq_puts(m, ")\n");
 	return 0;
 }
 
@@ -751,19 +726,13 @@ exp_addclient(struct nfsctl_client *ncp)
 		}
 	}
 
-	/* Copy addresses. */
-	for (i = 0; i < ncp->cl_naddr; i++) {
-		clp->cl_addr[i] = ncp->cl_addrlist[i];
-	}
-	clp->cl_naddr = ncp->cl_naddr;
-
 	/* Remove old client hash entries. */
 	if (change)
 		exp_unhashclient(clp);
 
 	/* Insert client into hashtable. */
 	for (i = 0; i < ncp->cl_naddr; i++) {
-		struct in_addr	addr = clp->cl_addr[i];
+		struct in_addr	addr = ncp->cl_addrlist[i];
 		int		hash;
 
 		hash = CLIENT_HASH(addr.s_addr);
@@ -853,8 +822,6 @@ again:
 			}
 		}
 	}
-	if (count != clp->cl_naddr)
-		printk(KERN_WARNING "nfsd: bad address count in freeclient!\n");
 	if (err)
 		goto again;
 	for (i = 0; i < count; i++)


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
