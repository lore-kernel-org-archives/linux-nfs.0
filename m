From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: nfsstat printing overflow
Date: Fri, 30 May 2003 15:43:00 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16086.61284.133472.312148@notabene.cse.unsw.edu.au>
References: <20030529232654.GA32598@doubt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net,
    okir@monad.swb.de,
    hjl@lucon.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28] ident=root)
	by sc8-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19Lcfe-0003e4-00
	for <nfs@lists.sourceforge.net>; Thu, 29 May 2003 22:43:18 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <grif@michaelgriffith.com>) (for <nfs@lists.sourceforge.net>)
	(for <okir@monad.swb.de>) (for <hjl@lucon.org>) By tone With Smtp ;
	Fri, 30 May 2003 15:43:09 +1000
To: Michael Griffith <grif@michaelgriffith.com>
In-Reply-To: message from Michael Griffith on Thursday May 29
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

On Thursday May 29, grif@michaelgriffith.com wrote:
> A small patch to handle when the RPC call counts are > 2^32/100.
> 
Thanks.
However:

> +        unsigned long long      pct;

> +		for (j = 0; j < 6 && i + j < nr; j++) {
> +                        pct = ((unsigned long long) info[i+j]*100)/total;
> +                        printf("%-6d %2d%% ", info[i+j], pct);
> +                }

if pct is an "unsigned long long" we should use "%llu" to print it.

The following patch has been commited to the nfs-utils CVS and will be
in the next release, which will probably be 1.1.0

NeilBrown

Index: ChangeLog
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/ChangeLog,v
retrieving revision 1.202
diff -u -r1.202 ChangeLog
--- ChangeLog	30 May 2003 05:16:52 -0000	1.202
+++ ChangeLog	30 May 2003 05:38:44 -0000
@@ -1,3 +1,9 @@
+2003-05-30 Michael Griffith <grif@michaelgriffith.com>
+	NeilBrown <neilb@cse.unsw.edu.au>
+
+	utils/nfsstat/nfsstat.c(print_callstats): use unsigned
+	long long to avoid overflow when printing stats.
+	
 2003-05-30  NeilBrown <neilb@cse.unsw.edu.au>
 
 	* support/export/export.c, support/include/nfslib.h,
Index: utils/nfsstat/nfsstat.c
===================================================================
RCS file: /cvsroot/nfs/nfs-utils/utils/nfsstat/nfsstat.c,v
retrieving revision 1.4
diff -u -r1.4 nfsstat.c
--- utils/nfsstat/nfsstat.c	5 May 2002 23:33:30 -0000	1.4
+++ utils/nfsstat/nfsstat.c	30 May 2003 05:38:46 -0000
@@ -307,7 +307,8 @@
 print_callstats(const char *hdr, const char **names,
 				 unsigned int *info, unsigned int nr)
 {
-	unsigned int	total;
+	unsigned long long	total;
+        unsigned long long      pct;
 	int		i, j;
 
 	fputs(hdr, stdout);
@@ -319,9 +320,10 @@
 		for (j = 0; j < 6 && i + j < nr; j++)
 			printf("%-11s", names[i+j]);
 		printf("\n");
-		for (j = 0; j < 6 && i + j < nr; j++)
-			printf("%-6d %2d%% ",
-				info[i+j], 100 * info[i+j] / total);
+		for (j = 0; j < 6 && i + j < nr; j++) {
+                        pct = ((unsigned long long) info[i+j]*100)/total;
+                        printf("%-6d %2llu%% ", info[i+j], pct);
+                }
 		printf("\n");
 	}
 	printf("\n");


-------------------------------------------------------
This SF.net email is sponsored by: eBay
Get office equipment for less on eBay!
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
