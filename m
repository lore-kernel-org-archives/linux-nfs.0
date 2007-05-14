From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: nfsv3 client process stuck in rwsem_down_failed_common()
Date: Mon, 14 May 2007 13:17:57 -0400
Message-ID: <1179163077.6474.40.camel@heimdal.trondhjem.org>
References: <20070514155449.GA5169@janus>
	<1179158385.6474.11.camel@heimdal.trondhjem.org>
	<20070514160547.GB5169@janus>
	<1179159094.6474.21.camel@heimdal.trondhjem.org>
	<20070514161512.GC5169@janus>
	<1179160379.6474.25.camel@heimdal.trondhjem.org>
	<20070514163919.GA6063@janus>
	<1179161763.6474.31.camel@heimdal.trondhjem.org>
	<20070514170216.GA6475@janus>  <20070514170557.GA6551@janus>
	<1179162920.6474.38.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
To: Frank van Maarseveen <frankvm@frankvm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HneBO-00061e-2z
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 10:18:07 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX19FihsMWTXsidoWpvMUF5vsX9zfBLIJjT4=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HneBP-0003NI-5q
	for nfs@lists.sourceforge.net; Mon, 14 May 2007 10:18:04 -0700
In-Reply-To: <1179162920.6474.38.camel@heimdal.trondhjem.org>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 2007-05-14 at 13:15 -0400, Trond Myklebust wrote:
> > > > 
> > > > One last question, just in case: what value are you using for CONFIG_HZ?
> > > 
> > > 1000
> > 
> > hmm, so the timeout has become 10 * HZ * HZ?
> 
> Yeah... nlmsvc_timeout is already in HZ, so the line in fs/lockd/host.c
> is wrong...

The following patch should fix it.

Trond

---------------------------------------------
commit 471c10cf35e2743746d9a5f671d9cceeb61393c7
Author: Trond Myklebust <Trond.Myklebust@netapp.com>
Date:   Mon May 14 13:16:36 2007 -0400

    NLM: Fix locking client timeouts...
    
    nlmsvc_timeout is already in units of HZ...
    
    Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index ad21c07..96070bf 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -221,7 +221,7 @@ nlm_bind_host(struct nlm_host *host)
 					host->h_nextrebind - jiffies);
 		}
 	} else {
-		unsigned long increment = nlmsvc_timeout * HZ;
+		unsigned long increment = nlmsvc_timeout;
 		struct rpc_timeout timeparms = {
 			.to_initval	= increment,
 			.to_increment	= increment,



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
