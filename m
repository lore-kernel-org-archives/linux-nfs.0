From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSdv4 - 4 of 10 - nfsd4_readdir fixes
Date: Thu, 08 Apr 2004 11:18:46 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BBOBq-0001Qn-Jc@notabene.cse.unsw.edu.au>
References: <20040408111135.5397.patches@notabene>
Cc: nfs@lists.sourceforge.net,  "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCP-0007l6-Fl
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:21 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BBOCP-000246-4R
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 18:19:21 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.241.7] == ppp2-007.ppp2.cse.unsw.EDU.AU) (auth-user neilb)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>)
	(for <bfields@fieldses.org>) By note With Smtp ;
	Thu, 8 Apr 2004 11:19:16 +1000
To: Andrew Morton <akpm@osdl.org>
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


From: "J. Bruce Fields" <bfields@fieldses.org>

Fix out-of-spec errors in nfs4 readdir.  Add checks for bad cookie values.

 ----------- Diffstat output ------------
 ./fs/nfsd/nfs4proc.c |    8 +++++++-
 ./fs/nfsd/nfs4xdr.c  |    2 ++
 2 files changed, 9 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2004-04-08 10:56:00.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2004-04-08 10:56:00.000000000 +1000
@@ -448,6 +448,11 @@ out:
 static inline int
 nfsd4_readdir(struct svc_rqst *rqstp, struct svc_fh *current_fh, struct nfsd4_readdir *readdir)
 {
+	u64 cookie = readdir->rd_cookie;
+	static const nfs4_verifier zeroverf = {
+		.data[0] = 0,
+	};
+
 	/* no need to check permission - this will be done in nfsd_readdir() */
 
 	if (readdir->rd_bmval[1] & NFSD_WRITEONLY_ATTRS_WORD1)
@@ -456,7 +461,8 @@ nfsd4_readdir(struct svc_rqst *rqstp, st
 	readdir->rd_bmval[0] &= NFSD_SUPPORTED_ATTRS_WORD0;
 	readdir->rd_bmval[1] &= NFSD_SUPPORTED_ATTRS_WORD1;
 
-	if (readdir->rd_cookie > ~(u32)0)
+	if ((cookie > ~(u32)0) || (cookie == 1) || (cookie == 2) ||
+	    (cookie == 0 && memcmp(readdir->rd_verf.data, zeroverf.data, NFS4_VERIFIER_SIZE)))
 		return nfserr_bad_cookie;
 
 	readdir->rd_rqstp = rqstp;

diff ./fs/nfsd/nfs4xdr.c~current~ ./fs/nfsd/nfs4xdr.c
--- ./fs/nfsd/nfs4xdr.c~current~	2004-04-08 10:56:00.000000000 +1000
+++ ./fs/nfsd/nfs4xdr.c	2004-04-08 10:56:00.000000000 +1000
@@ -2179,6 +2179,8 @@ nfsd4_encode_readdir(struct nfsd4_compou
 	    readdir->common.err == nfserr_toosmall &&
 	    readdir->buffer == page) 
 		nfserr = nfserr_toosmall;
+	if (nfserr == nfserr_symlink)
+		nfserr = nfserr_notdir;
 	if (nfserr)
 		goto err_no_verf;
 


-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
