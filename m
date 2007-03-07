From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 002 of 2] Avoid flush-when-locking when
	interclient	consistency not needed.
Date: Thu, 8 Mar 2007 10:03:25 +1100
Message-ID: <17903.17597.832563.922428@notabene.brown>
References: <20070306163710.8128.patches@notabene> <1070306054029.8360@suse.de>
	<1173192029.6393.52.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP5AU-00012m-27
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 15:03:34 -0800
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HP5AV-0002gs-Io
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 15:03:36 -0800
In-Reply-To: message from Trond Myklebust on Tuesday March 6
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

On Tuesday March 6, trond.myklebust@fys.uio.no wrote:
> On Tue, 2007-03-06 at 16:40 +1100, NeilBrown wrote:
> > If nolock and nocto mount options are set, then the implication is
> > that cache consistency with other clients is not desired.  This is
> > likely to be the case when the filesystem is only access by the one
> > client - as a nfs-mounted root might be.
> > 
> > In that case, there is no benefit in flushing writes and invalidating
> > caches around lock/unlock requests.
> > 
> > This patch makes those flushes and invalidates conditional on either
> > nolock or nocto being clear.
> > 
> > Signed-off-by: Neil Brown <neilb@suse.de>
> 
> NACK.
> 
> Disabling close to open cache consistency using the "nocto" option is
> not equivalent to disabling _all_ cache consistency. If people are using
> remote locking, then it is because they are expecting a situation where
> synchronisation is needed.

"If people are using remote locking..."... but in this case (nolock)
they aren't.

> 
> You can argue for or against the need to invalidate caches when the user
> has specified "nolock" (it might be nice to add a Solaris-style "llock"
> alias to this one day, btw: nolock == local locking != no locking at
> all). We used to do this in early 2.4.x kernels, but that was changed.
> The reason is that locking is the only way of ensuring that the NFS
> cache is in sync with the server, and the "nolock" exception was
> breaking this.

Yes, the name "nolock" does seem to have been unfortunate.  We had one
customer wondering why it wasn't producing an 'ENOLCK' error status.
We could create an alias.  "nonlm"?

If you have chosen nocto,nolock, I cannot see any justification in
expecting any way of ensuring  the NFS cache is in sync with the
server except at unmount.

However if you don't like it, that's fine.  It was just a "this might
be useful, what do you think" rather than "this is important".  The
other patch of the two was the real bugfix.  Did that pass muster?

But I worry about adding an 'llock' option that was different from
'nolock'.  How would you explain the difference in a way that didn't
confuse people?

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
