From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] sunrpc: remove dead variable 'rpciod_running'
Date: Sun, 13 May 2007 15:51:29 -0400
Message-ID: <1179085889.6805.25.camel@heimdal.trondhjem.org>
References: <20070209200649.GA9686@infradead.org>
	<20070513151007.GA6059@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HnK6f-0006rc-3B
	for nfs@lists.sourceforge.net; Sun, 13 May 2007 12:51:49 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX18f0Tcj48pU9b/GQRwh5OZ9+smZ77Zk2/w=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HnK6Z-0008Rj-NO
	for nfs@lists.sourceforge.net; Sun, 13 May 2007 12:51:44 -0700
In-Reply-To: <20070513151007.GA6059@infradead.org>
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

On Sun, 2007-05-13 at 16:10 +0100, Christoph Hellwig wrote:
> On Fri, Feb 09, 2007 at 08:06:49PM +0000, Christoph Hellwig wrote:
> > rpciod_running is not used at all, but due to the way DECLARE_MUTEX_LOCKED
> > works we don't get a warning for it.
> 
> Looks like this one is still not in.  Any chance to send it to Linus
> in this merge cycle?

Oops. My bad. I must have dropped it by accident... I'll send it in.

Cheers
  Trond

> 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> > 
> > Index: linux-2.6/net/sunrpc/sched.c
> > ===================================================================
> > --- linux-2.6.orig/net/sunrpc/sched.c	2007-02-06 15:55:43.000000000 +0100
> > +++ linux-2.6/net/sunrpc/sched.c	2007-02-06 15:55:45.000000000 +0100
> > @@ -973,8 +973,6 @@
> >  	spin_unlock(&rpc_sched_lock);
> >  }
> >  
> > -static DECLARE_MUTEX_LOCKED(rpciod_running);
> > -
> >  static void rpciod_killall(void)
> >  {
> >  	unsigned long flags;
> ---end quoted text---
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
