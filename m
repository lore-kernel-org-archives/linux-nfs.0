From: Stephen Hemminger <shemminger@osdl.org>
Subject: [PATCH] NFS4XDR get rid of warning
Date: Tue, 9 Sep 2003 15:04:34 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030909150434.3df7dc45.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19wqbZ-0008SS-00
	for <nfs@lists.sourceforge.net>; Tue, 09 Sep 2003 15:04:57 -0700
Received: from fw.osdl.org ([65.172.181.6] helo=mail.osdl.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 19wqbZ-00028H-Cw
	for nfs@lists.sourceforge.net; Tue, 09 Sep 2003 15:04:57 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>,
   Trond Myklebust <trond.myklebust@fys.uio.no>
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

On 2.6.0-test5 there is a warning because of calling return with an argument
on a void function. The root cause is putting a return statement in a macro
(evil side effect).

Change ENCODE_SEQID_OP_TAIL to be a more proper macro, and add the return's
where needed.

diff -Nru a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
--- a/fs/nfsd/nfs4xdr.c	Tue Sep  9 14:42:16 2003
+++ b/fs/nfsd/nfs4xdr.c	Tue Sep  9 14:42:16 2003
@@ -1116,13 +1116,13 @@
  * where seqids are incremented
  */
 
-#define ENCODE_SEQID_OP_TAIL(stateowner)		\
+#define ENCODE_SEQID_OP_TAIL(stateowner) do {		\
 	BUG_ON(!stateowner);				\
 	if (seqid_mutating_err(nfserr) && stateowner) {	\
 		if (stateowner->so_confirmed)		\
 			stateowner->so_seqid++;		\
 	}						\
-	return nfserr;
+} while(0)
 
 
 static u32 nfs4_ftypes[16] = {
@@ -1786,6 +1786,7 @@
 	}
 
 	ENCODE_SEQID_OP_TAIL(oc->oc_stateowner);
+	return nfserr;
 }
 
 static int
@@ -1801,6 +1802,7 @@
 	}
 
 	ENCODE_SEQID_OP_TAIL(od->od_stateowner);
+	return nfserr;
 }
 
 static int


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
