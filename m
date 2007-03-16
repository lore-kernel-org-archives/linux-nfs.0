From: Christoph Hellwig <hch@infradead.org>
Subject: Re: Delays on "first" access to a NFS mount
Date: Fri, 16 Mar 2007 21:57:34 +0000
Message-ID: <20070316215734.GA6021@infradead.org>
References: <EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
	<20070307205016.GI26553@fieldses.org>
	<EXNANE01MWuLn5U9T3T00000074@exnane01.hq.netapp.com>
	<20070307211729.GO26553@fieldses.org>
	<EXNANE0169aZbLAX3cf00000075@exnane01.hq.netapp.com>
	<20070307215406.GR26553@fieldses.org>
	<17903.16030.26119.464793@notabene.brown>
	<20070307230601.GX26553@fieldses.org>
	<20070316214737.GA3253@infradead.org>
	<20070316215429.GG4538@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>,
	Neil Brown <neilb@suse.de>,
	"Talpey,  Thomas" <Thomas.Talpey@netapp.com>,
	nfs@lists.sourceforge.net, Simon Peter <simon.peter@gmx.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HSKQc-0005Dn-Vf
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 14:57:39 -0700
Received: from pentafluge.infradead.org ([213.146.154.40])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HSKQf-0000Zp-0p
	for nfs@lists.sourceforge.net; Fri, 16 Mar 2007 14:57:41 -0700
In-Reply-To: <20070316215429.GG4538@fieldses.org>
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

On Fri, Mar 16, 2007 at 05:54:29PM -0400, J. Bruce Fields wrote:
> On Fri, Mar 16, 2007 at 09:47:38PM +0000, Christoph Hellwig wrote:
> >  - using namespace and the kernel mount code means we need to have
> >    at least enough information on where these mount points are in
> >    kernel space.
> >  - it does however not mean that we need to set up all these mount
> >    points at boot time!  We have a nice scheme to creates mounts
> >    when a special follow_link operation that is for example used
> >    in the nfs client for submount, or we could have some sort
> >    of automounter that does userspace upcalls.
> 
> Note that clients may access filesystems by traversing mountpoints, but
> they may also just jump in with a filehandle they got on a previous
> boot.  So we still need to be able to look up exports by filehandle as
> well as by path.

Yeah, but an explicit kern_mount is easy.  For old dev_t based filehandles
anyway, and for uuid or fsid based onces we'd need an upcall for a uuid/fsid
to dev_t mapping.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
