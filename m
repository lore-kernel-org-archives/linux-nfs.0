From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 008 of 16] nfsd4: support CLAIM_DELEGATE_CUR
Date: Fri, 08 Apr 2005 11:00:16 +1000
Message-ID: <E1DJhr6-0006dq-9U@notabene.cse.unsw.edu.au>
References: <20050408105936.25374.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJikO-0006U6-Kg
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DJikM-0000ue-Ku
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 18:57:24 -0700
To: Andrew Morton <akpm@osdl.org>
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


Add OPEN claim type NFS4_OPEN_CLAIM_DELEGATE_CUR to nfsd4_open().

A delegation stateid and a name are provided. OPEN with O_CREAT is not legal
with this claim type; otherwise, use the NFS4_OPEN_CLAIM_NULL code path to
lookup the filename to be opened.

Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |    6 +++++-
 1 files changed, 5 insertions(+), 1 deletion(-)

diff ./fs/nfsd/nfs4proc.c~current~ ./fs/nfsd/nfs4proc.c
--- ./fs/nfsd/nfs4proc.c~current~	2005-04-08 10:31:12.000000000 +1000
+++ ./fs/nfsd/nfs4proc.c	2005-04-08 10:42:30.000000000 +1000
@@ -198,6 +198,11 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 	if (status)
 		goto out;
 	switch (open->op_claim_type) {
+		case NFS4_OPEN_CLAIM_DELEGATE_CUR:
+			status = nfserr_inval;
+			if (open->op_create)
+				goto out;
+			/* fall through */
 		case NFS4_OPEN_CLAIM_NULL:
 			/*
 			 * (1) set CURRENT_FH to the file being opened,
@@ -220,7 +225,6 @@ nfsd4_open(struct svc_rqst *rqstp, struc
 			if (status)
 				goto out;
 			break;
-		case NFS4_OPEN_CLAIM_DELEGATE_CUR:
              	case NFS4_OPEN_CLAIM_DELEGATE_PREV:
 			printk("NFSD: unsupported OPEN claim type %d\n",
 				open->op_claim_type);


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
