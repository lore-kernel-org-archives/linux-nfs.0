From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 8] knfsd: lockd: fix refount on nsm.
Date: Fri, 29 Sep 2006 13:08:45 +1000
Message-ID: <1060929030845.24038@suse.de>
References: <20060929130518.23919.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GT8k6-0007oN-W8
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 20:08:52 -0700
Received: from ns1.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GT8k7-0001WD-Bs
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 20:08:51 -0700
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


If nlm_lookup_host finds what it is looking for
it exits with an extra reference on the matching
'nsm' structure.
So don't actually count the reference until we are
(fairly) sure it is going to be used.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/lockd/host.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff .prev/fs/lockd/host.c ./fs/lockd/host.c
--- .prev/fs/lockd/host.c	2006-09-29 11:44:21.000000000 +1000
+++ ./fs/lockd/host.c	2006-09-29 11:55:15.000000000 +1000
@@ -103,8 +103,8 @@ nlm_lookup_host(int server, const struct
 			continue;
 
 		/* See if we have an NSM handle for this client */
-		if (!nsm && (nsm = host->h_nsmhandle) != 0)
-			atomic_inc(&nsm->sm_count);
+		if (!nsm)
+			nsm = host->h_nsmhandle;
 
 		if (host->h_proto != proto)
 			continue;
@@ -120,6 +120,8 @@ nlm_lookup_host(int server, const struct
 		nlm_get_host(host);
 		goto out;
 	}
+	if (nsm)
+		atomic_inc(&nsm->sm_count);
 
 	host = NULL;
 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
