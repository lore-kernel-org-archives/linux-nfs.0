From: Ian Kent <raven@themaw.net>
Subject: Re: time_after cannot be used alone by NFS code
	in	32bit	architectures
Date: Tue, 08 May 2007 17:43:55 +0800
Message-ID: <1178617435.3918.72.camel@raven.themaw.net>
References: <20070426043344.GO10449@sleipnir.redhat.com>
	<1178106770.5960.28.camel@raven.themaw.net>
	<1178591824.3918.10.camel@raven.themaw.net>
	<17984.5736.617053.65429@notabene.brown>
	<1178614201.3918.65.camel@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs <nfs@lists.sourceforge.net>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HlMEi-0007YR-6M
	for nfs@lists.sourceforge.net; Tue, 08 May 2007 02:44:00 -0700
Received: from out1.smtp.messagingengine.com ([66.111.4.25])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HlMEj-0003uO-IB
	for nfs@lists.sourceforge.net; Tue, 08 May 2007 02:44:02 -0700
In-Reply-To: <1178614201.3918.65.camel@raven.themaw.net>
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

On Tue, 2007-05-08 at 16:50 +0800, Ian Kent wrote:
> > 
> > If this is the problem situation, then just updating the jiffie stamp
> > on the negative dentry whenever it is seem to be in the future
> > wouldn't work because we hardly ever look at it.  I think the best
> > solution would be to somehow to force dcache entries out before the
> > jiffie stamp had a chance to wrap.  But I not convinced that doesn't
> > happen already simply because 24days is a LONG time.

Sure would be best to have some way of identifying these dentrys once
they were older than some fairly short time following creation but I
can't think of how to do it.

It's of particular interest to me because I plan on using something
similar for caching failed mount attempts in the autofs4 module when I
re-implement it.

Ian



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
