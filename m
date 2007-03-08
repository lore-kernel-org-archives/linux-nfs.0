From: Neil Brown <neilb@suse.de>
Subject: Re: Delays on "first" access to a NFS mount
Date: Thu, 8 Mar 2007 16:42:15 +1100
Message-ID: <17903.41527.623137.618107@notabene.brown>
References: <20070307194418.97fee0ec.simon.peter@gmx.de>
	<EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
	<20070307205016.GI26553@fieldses.org>
	<EXNANE01MWuLn5U9T3T00000074@exnane01.hq.netapp.com>
	<20070307211729.GO26553@fieldses.org>
	<EXNANE0169aZbLAX3cf00000075@exnane01.hq.netapp.com>
	<20070307215406.GR26553@fieldses.org>
	<17903.16030.26119.464793@notabene.brown>
	<20070307230601.GX26553@fieldses.org>
	<17903.19755.146916.321440@notabene.brown>
	<20070308051401.GC15814@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net,
	"Talpey,  Thomas" <Thomas.Talpey@netapp.com>,
	Simon Peter <simon.peter@gmx.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPBOj-0005d8-Fx
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 21:42:41 -0800
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HPBOj-00029n-OU
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 21:42:43 -0800
In-Reply-To: message from J. Bruce Fields on Thursday March 8
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

On Thursday March 8, bfields@fieldses.org wrote:
> On Thu, Mar 08, 2007 at 10:39:23AM +1100, Neil Brown wrote:
> > Imagine having hundreds of filesystems on some sort of library (a CD
> > library?) where each can be identified by a UUID which gets stored in
> > the fsid in the filehandle.
> > Imagine a simple extension to mountd so that a call-out were made when
> > an unknown filehandle arrived.  This callout could mount the required
> > filesystem and export it.  Maybe the library only allows 3 filesystems
> > to be mounted at a time, so it would unmount the lease-recently-used
> > one.
> 
> Maybe.  Is this practical?  Do we know of any cases of users doing this?

Someone once mentioned doing something vaguely like this... I don't
know the exact details.  It was mentioned in the context of the fsid
being too small to do a really good job.

I wonder if you can export autofs to get them mounted in the first
place..... 

> Do you block forever if you try to access 4 filesystems at once?  I
> dunno....

round-robin?  Sending lots of EINPROGRESS for one filesystem while the
others have a turn.


> 
> > I have often wanted to write a 'Linux commentary' that explains all
> > the hows and whys of things.  I even started some bits once (to help
> > me understand the VFS layer).  But Linux changes so fast that any
> > entry in such a commentary would be out-of-date before it was
> > written....
> 
> And there's a lot to document.  I mean, look:
> 
> 	http://www.oreilly.com/catalog/understandlni/
> 
> Just over a thousand pages, just covering the kernel networking code
> (and only some of it at that).  Maybe they just lost the forest for the
> trees, but still, yipes.

Is there really a market for that sort of book?  Maybe we should write
"Understanding Linux NFS" in our spare time .... oh wait, we don't
have any spare time.  Maybe in a couple of decades when I retire:-)

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
