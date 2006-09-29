From: Olaf Kirch <okir@suse.de>
Subject: Re: [PATCH 002 of 8] knfsd: lockd: fix refount on nsm.
Date: Fri, 29 Sep 2006 08:01:55 +0200
Message-ID: <20060929060155.GB2852@suse.de>
References: <20060929130518.23919.patches@notabene>
	<1060929030845.24038@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GTBRl-00056N-8t
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 23:02:05 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GTBRj-0004GW-On
	for nfs@lists.sourceforge.net; Thu, 28 Sep 2006 23:02:06 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060929030845.24038@suse.de>
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

On Fri, Sep 29, 2006 at 01:08:45PM +1000, NeilBrown wrote:
> If nlm_lookup_host finds what it is looking for
> it exits with an extra reference on the matching
> 'nsm' structure.
> So don't actually count the reference until we are
> (fairly) sure it is going to be used.
> 
> Signed-off-by: Neil Brown <neilb@suse.de>

Correct, even though I would have done it slightly differently. The if()
is not needed anymore, and there's another if (nsm) two lines down.

Olaf

 fs/lockd/host.c |   10 ++++++----
 1 files changed, 6 insertions(+), 4 deletions(-)

Index: build/fs/lockd/host.c
===================================================================
--- build.orig/fs/lockd/host.c
+++ build/fs/lockd/host.c
@@ -109,9 +109,9 @@ nlm_lookup_host(int server, const struct
 		if (!nlm_cmp_addr(&host->h_addr, sin))
 			continue;
 
-		/* See if we have an NSM handle for this client */
-		if (!nsm && (nsm = host->h_nsmhandle) != 0)
-			atomic_inc(&nsm->sm_count);
+		/* Stash away the NSM handle in case we need
+		 * to create a new host entry. */
+		nsm = host->h_nsmhandle;
 
 		if (host->h_proto != proto)
 			continue;
@@ -133,7 +133,9 @@ nlm_lookup_host(int server, const struct
 	/* Sadly, the host isn't in our hash table yet. See if
 	 * we have an NSM handle for it. If not, create one.
 	 */
-	if (!nsm && !(nsm = nsm_find(sin, hostname, hostname_len)))
+	if (nsm != NULL)
+		atomic_inc(&nsm->sm_count);
+	else if (!(nsm = nsm_find(sin, hostname, hostname_len)))
 		goto out;
 
 	if (!(host = (struct nlm_host *) kmalloc(sizeof(*host), GFP_KERNEL))) {

-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
