From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 11 - nfsd_acceptable_typo.patch
Date: Fri, 28 May 2004 14:37:30 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E1BTZ7a-0008EG-U4@notabene.cse.unsw.edu.au>
References: <20040528143518.31534.patches@notabene>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkaX-00071A-6U
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:04:17 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkaV-0003Wl-RU
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:04:16 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb) (ident-user Debian-exim)
	(for <akpm@osdl.org>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 28 May 2004 14:37:31 +1000
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


there's a small typo in nfsd_acceptable.  It calls

	err = permission(parent->d_inode, S_IXOTH, NULL);

It really wants to use MAY_EXEC instead of S_IXOTH. Those
happen to be the same at the moment, but may not do so forever.



From: Olaf Kirch <okir@suse.de>:
From: "J. Bruce Fields" <bfields@fieldses.org>
Signed-off-by: Neil Brown <neilb@cse.unsw.edu.au>

 ----------- Diffstat output ------------
 ./fs/nfsd/nfsfh.c |    2 +-
 1 files changed, 1 insertion(+), 1 deletion(-)

diff ./fs/nfsd/nfsfh.c~current~ ./fs/nfsd/nfsfh.c
--- ./fs/nfsd/nfsfh.c~current~	2004-05-28 14:20:00.000000000 +1000
+++ ./fs/nfsd/nfsfh.c	2004-05-28 14:20:16.000000000 +1000
@@ -56,7 +56,7 @@ int nfsd_acceptable(void *expv, struct d
 		/* make sure parents give x permission to user */
 		int err;
 		parent = dget_parent(tdentry);
-		err = permission(parent->d_inode, S_IXOTH, NULL);
+		err = permission(parent->d_inode, MAY_EXEC, NULL);
 		if (err < 0) {
 			dput(parent);
 			break;


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
