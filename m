From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH] nfsd: fix horrible indentation in nfsd_setattr
Date: Mon, 14 May 2007 10:21:57 +1000
Message-ID: <17991.43941.702458.638020@notabene.brown>
References: <20070307152625.GA29633@infradead.org>
	<20070513204407.GC13563@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HnOKG-0006tI-RI
	for nfs@lists.sourceforge.net; Sun, 13 May 2007 17:22:08 -0700
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HnOKI-0002SA-67
	for nfs@lists.sourceforge.net; Sun, 13 May 2007 17:22:11 -0700
In-Reply-To: message from Christoph Hellwig on Sunday May 13
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

On Sunday May 13, hch@infradead.org wrote:
> On Wed, Mar 07, 2007 at 03:26:25PM +0000, Christoph Hellwig wrote:
> > 
> > Signed-off-by: Christoph Hellwig <hch@lst.de>
> 
> ping?
> 

I don't remember seeing this, and I don't see to still have it sitting
unread in my INBOX...

Except for spending a whole line on "/*" which I would rather avoid
(inside functions) it's all very sensible.  I will apply it.

Thanks,
NeilBrown

> > 
> > Index: linux-2.6/fs/nfsd/vfs.c
> > ===================================================================
> > --- linux-2.6.orig/fs/nfsd/vfs.c	2007-03-06 17:43:28.000000000 +0100
> > +++ linux-2.6/fs/nfsd/vfs.c	2007-03-06 17:45:48.000000000 +0100
> > @@ -277,7 +277,8 @@
> >  	if (!iap->ia_valid)
> >  		goto out;
> >  
> > -	/* NFSv2 does not differentiate between "set-[ac]time-to-now"
> > +	/*
> > +	 * NFSv2 does not differentiate between "set-[ac]time-to-now"
> >  	 * which only requires access, and "set-[ac]time-to-X" which
> >  	 * requires ownership.
> >  	 * So if it looks like it might be "set both to the same time which

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
