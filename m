From: Michael Griffith <grif@michaelgriffith.com>
Subject: nfsstat printing overflow
Date: Thu, 29 May 2003 16:26:54 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030529232654.GA32598@doubt>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YiEDa0DAkWCtVeE4"
Cc: neilb@cse.unsw.edu.au, hjl@lucon.org
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from adsl-209-76-203-130.dsl.snfc21.pacbell.net ([209.76.203.130] helo=michaelgriffith.com)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19LWnY-0002zs-00
	for <nfs@lists.sourceforge.net>; Thu, 29 May 2003 16:27:04 -0700
To: nfs@lists.sourceforge.net, okir@monad.swb.de
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


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

A small patch to handle when the RPC call counts are > 2^32/100.

-- 
Michael A. Griffith
<grif@acm.org>
408-907-2151
650-292-1516

--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="nfsstat.diff"



Without this patch, nfsstat reports the wrong percentage for
any RPC which has more than 2^32/100 calls.  For example
my machine running 1.0.1 reports:

l-sim-208-11:diag/testgen/batch_0/nv40_curie_ogtest/000001> nfsstat at
-c
Client rpc stats:
calls      retrans    authrefrsh
61096094   181        0
Client nfs v2:
null       getattr    setattr    root       lookup     readlink
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
read       wrcache    write      create     remove     rename
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%
link       symlink    mkdir      rmdir      readdir    fsstat
0       0% 0       0% 0       0% 0       0% 0       0% 0       0%

Client nfs v3:
null       getattr    setattr    lookup     access     readlink
0       0% 2661431  4% 76995   0% 4938464  8% 3254610  5% 131     0%
read       write      create     mkdir      symlink    mknod
138409  0% 259382  0% 185867  0% 3570    0% 49      0% 0       0%
remove     rmdir      rename     link       readdir    readdirplus
4035088  6% 318094  0% 157     0% 0       0% 1626490  2% 43597144  1%
fsstat     fsinfo     pathconf   commit
18      0% 195     0% 0       0% 0       0%


Note that readdir plus should be 71%, not 1%. 



--- 1.0.1/nfsstat.c	Sun May  5 16:33:30 2002
+++ nfsstat.c	Thu May 29 16:10:21 2003
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
+                        printf("%-6d %2d%% ", info[i+j], pct);
+                }
 		printf("\n");
 	}
 	printf("\n");

--YiEDa0DAkWCtVeE4--


-------------------------------------------------------
This SF.net email is sponsored by: eBay
Get office equipment for less on eBay!
http://adfarm.mediaplex.com/ad/ck/711-11697-6916-5
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
