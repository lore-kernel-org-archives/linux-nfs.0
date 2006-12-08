From: NeilBrown <neilb@suse.de>
Subject: [PATCH 010 of 18] knfsd: nfsd4: remove spurious replay_owner
	check
Date: Fri, 8 Dec 2006 12:14:13 +1100
Message-ID: <1061208011413.30677@suse.de>
References: <20061208120939.30428.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GsUJN-00039H-VA
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:14:02 -0800
Received: from mx1.suse.de ([195.135.220.2])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GsUJO-00052C-RR
	for nfs@lists.sourceforge.net; Thu, 07 Dec 2006 17:14:03 -0800
To: Andrew Morton <akpm@osdl.org>
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


From: J.Bruce Fields <bfields@fieldses.org>

OK, this is embarassing--I've even looked back at the history, and cannot
for the life of me figure out why I added this check.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4proc.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff .prev/fs/nfsd/nfs4proc.c ./fs/nfsd/nfs4proc.c
--- .prev/fs/nfsd/nfs4proc.c	2006-12-08 12:09:27.000000000 +1100
+++ ./fs/nfsd/nfs4proc.c	2006-12-08 12:09:27.000000000 +1100
@@ -1008,7 +1008,7 @@ encode_op:
 			nfsd4_encode_operation(resp, op);
 			status = op->status;
 		}
-		if (replay_owner && (replay_owner != (void *)(-1))) {
+		if (replay_owner) {
 			nfs4_put_stateowner(replay_owner);
 			replay_owner = NULL;
 		}

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
