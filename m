From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 19 of 23] Check for openmode violations given a delegation stateid.
Date: Fri, 17 Dec 2004 16:23:57 +1100
Message-ID: <E1CfAar-0002ea-5u@notabene.cse.unsw.edu.au>
References: <20041217162128.9968.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CfAby-0005Ao-A0
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:06 -0800
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CfAbx-0006Aj-Hm
	for nfs@lists.sourceforge.net; Thu, 16 Dec 2004 21:25:06 -0800
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


Signed-off-by: Andy Adamson <andros@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

### Diffstat output
 ./fs/nfsd/nfs4state.c |   14 ++++++++++++++
 1 files changed, 14 insertions(+)

diff ./fs/nfsd/nfs4state.c~current~ ./fs/nfsd/nfs4state.c
--- ./fs/nfsd/nfs4state.c~current~	2004-12-15 13:37:51.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2004-12-15 13:37:51.000000000 +1100
@@ -1956,6 +1956,20 @@ out:
 	return status;
 }
 
+static int
+nfs4_check_delegmode(struct nfs4_delegation *dp, int flags)
+{
+	int status = nfserr_openmode;
+
+	if ((flags & WR_STATE) & (dp->dl_type == NFS4_OPEN_DELEGATE_READ))
+		goto out;
+	if ((flags & RD_STATE) & (dp->dl_type == NFS4_OPEN_DELEGATE_WRITE))
+		goto out;
+	status = nfs_ok;
+out:
+	return status;
+}
+
 /*
 * Checks for stateid operations
 */


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
