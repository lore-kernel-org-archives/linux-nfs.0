From: NeilBrown <neilb@suse.de>
Subject: [PATCH 003 of 4] knfsd: nfsd4: demote "clientid in use"
	printk to a dprintk
Date: Fri, 23 Mar 2007 11:46:59 +1100
Message-ID: <1070323004659.28973@suse.de>
References: <20070323114512.28822.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HUXvt-00016n-T2
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 17:47:06 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HUXvu-0005jq-R4
	for nfs@lists.sourceforge.net; Thu, 22 Mar 2007 17:47:08 -0700
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

The reused clientid here is a more of a problem for the client than the
server, and the client can report the problem itself if it's serious.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./fs/nfsd/nfs4state.c |    5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff .prev/fs/nfsd/nfs4state.c ./fs/nfsd/nfs4state.c
--- .prev/fs/nfsd/nfs4state.c	2007-03-23 11:19:14.000000000 +1100
+++ ./fs/nfsd/nfs4state.c	2007-03-23 11:19:14.000000000 +1100
@@ -750,9 +750,8 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		status = nfserr_clid_inuse;
 		if (!cmp_creds(&conf->cl_cred, &rqstp->rq_cred)
 				|| conf->cl_addr != sin->sin_addr.s_addr) {
-			printk("NFSD: setclientid: string in use by client"
-			"(clientid %08x/%08x)\n",
-			conf->cl_clientid.cl_boot, conf->cl_clientid.cl_id);
+			dprintk("NFSD: setclientid: string in use by client"
+				"at %u.%u.%u.%u\n", NIPQUAD(conf->cl_addr));
 			goto out;
 		}
 	}

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
