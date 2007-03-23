From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 4] knfsd: nfsd4: fix inheritance flags on v4
	ace derived from posix default ace
Date: Fri, 23 Mar 2007 11:46:54 +1100
Message-ID: <1070323004654.28958@suse.de>
References: <20070323114512.28822.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HUXvn-00014t-GI
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 17:46:59 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HUXvo-0002BT-U6
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 17:47:01 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


From: Bruce Fields <bfields@citi.umich.edu>

A regression introduced in the last set of acl patches removed the
INHERIT_ONLY flag from aces derived from the posix acl.  Fix.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4acl.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff .prev/fs/nfsd/nfs4acl.c ./fs/nfsd/nfs4acl.c
--- .prev/fs/nfsd/nfs4acl.c	2007-03-23 11:18:58.000000000 +1100
+++ ./fs/nfsd/nfs4acl.c	2007-03-23 11:18:58.000000000 +1100
@@ -228,7 +228,7 @@ _posix_to_nfsv4_one(struct posix_acl *pa
 	struct posix_acl_summary pas;
 	unsigned short deny;
 	int eflag = ((flags & NFS4_ACL_TYPE_DEFAULT) ?
-					NFS4_INHERITANCE_FLAGS : 0);
+		NFS4_INHERITANCE_FLAGS | NFS4_ACE_INHERIT_ONLY_ACE : 0);
 
 	BUG_ON(pacl->a_count < 3);
 	summarize_posix_acl(pacl, &pas);

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
