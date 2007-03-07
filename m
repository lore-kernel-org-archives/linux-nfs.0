From: Neil Brown <neilb@suse.de>
Subject: Re: Delays on "first" access to a NFS mount
Date: Thu, 8 Mar 2007 10:39:23 +1100
Message-ID: <17903.19755.146916.321440@notabene.brown>
References: <20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
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
Cc: Christoph Hellwig <hch@infradead.org>, nfs@lists.sourceforge.net,
	"Talpey,  Thomas" <Thomas.Talpey@netapp.com>,
	Simon Peter <simon.peter@gmx.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP5jU-0004b0-UX
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 15:39:45 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HP5jV-0002Mh-Et
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 15:39:47 -0800
In-Reply-To: message from J. Bruce Fields on Wednesday March 7
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

On Wednesday March 7, bfields@fieldses.org wrote:
> 
> So could you remind me what the uses cases are here?  Who is it that
> requires demand loading, and why?

Partly it is the principle that demand-based configuration is more
flexible.  Witness the various efforts to replace rc.d scripts with
something event/demand based.

The IP->clientname table must be demand loaded because you obviously
cannot know all needed IP addresses in advance. (The rmtab experience
proves that)

The clientname+path->export-options table must be demand loaded
because - depending a bit of how you choose client names and how
complicated /etc/exports is - you either don't know all client names
in advance, or computing them all is complex and wasteful.

The fsid->path table could possible be made 'static', but I think
demand-loading is still best.  There are multiple possible fsids for
some filesystems, and telling the kernel about all of them when only
one will be used seems wasteful.  And the filesystems may not all be
available when you try to create the static table.  You could update
the table at every mount, but with demand-loading, you don't have to.

Imagine having hundreds of filesystems on some sort of library (a CD
library?) where each can be identified by a UUID which gets stored in
the fsid in the filehandle.
Imagine a simple extension to mountd so that a call-out were made when
an unknown filehandle arrived.  This callout could mount the required
filesystem and export it.  Maybe the library only allows 3 filesystems
to be mounted at a time, so it would unmount the lease-recently-used
one.

How are you going to handle that system except with demand-loading of
the fsid->path table?

> 
> I'll promise to write it all down someplace and then hopefully we won't
> have to re-ask the same questions too many times....

Sounds like a fine idea.
I have often wanted to write a 'Linux commentary' that explains all
the hows and whys of things.  I even started some bits once (to help
me understand the VFS layer).  But Linux changes so fast that any
entry in such a commentary would be out-of-date before it was
written....

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
