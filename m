From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Delays on "first" access to a NFS mount
Date: Fri, 16 Mar 2007 21:47:38 +0000
Message-ID: <20070316214737.GA3253@infradead.org>
References: <20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
	<20070307205016.GI26553@fieldses.org>
	<EXNANE01MWuLn5U9T3T00000074@exnane01.hq.netapp.com>
	<20070307211729.GO26553@fieldses.org>
	<EXNANE0169aZbLAX3cf00000075@exnane01.hq.netapp.com>
	<20070307215406.GR26553@fieldses.org>
	<17903.16030.26119.464793@notabene.brown>
	<20070307230601.GX26553@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Christoph Hellwig <hch@infradead.org>,
	"Talpey,  Thomas" <Thomas.Talpey@netapp.com>,
	nfs@lists.sourceforge.net, Simon Peter <simon.peter@gmx.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HSKH6-0004Dw-MT
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 14:47:48 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HSKH6-0003oV-GO
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 14:47:51 -0700
In-Reply-To: <20070307230601.GX26553@fieldses.org>
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

First I'd like to apologize for jumping in a little late, but I have
been very busy at work the last weeks.

Then I'll try to put my repsones to most concerns here in one length
mail because there's a lot of different things talked about here
that are are all interwinded.

There's a lot of things about exporting handling that can be static
vs ondemand, kernel vs userspace etc.


 - with NFSv4 there's a clear pseudo-filesystem structure where that
   really should be represented using the kernel mount tables, or
   to speak be a namespace reusing the infrastructure we have
 - for NFSv2/3 that's not as important, but when we have to have
   this namespace magic for NFSv4 anyway, it would be nice to reuse
   it for NFSv3 as far as possible, e.g. serving older NFS client
   from the same namespace as NFSv4 clients, even if only the actually
   defined mountpoints without the pseudo root instead of the full
   hiearchy that is visible
 - once we're talking about mounting filesystems into specific places
   we really should reuse all the existing excellent kernel code
   to deal with this.  Given that for NFSv4 we most likely want
   to represent a different tree that the normal local filesystem views
   that means a separate namespace.  Note that we should have a way
   for the administrator to easily see and modify this namespace to
   not cause all too much trouble.
 - using namespace and the kernel mount code means we need to have
   at least enough information on where these mount points are in
   kernel space.
 - it does however not mean that we need to set up all these mount
   points at boot time!  We have a nice scheme to creates mounts
   when a special follow_link operation that is for example used
   in the nfs client for submount, or we could have some sort
   of automounter that does userspace upcalls.

Does this give a better view of where I want to go?

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
