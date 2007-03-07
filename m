From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Delays on "first" access to a NFS mount
Date: Wed, 7 Mar 2007 18:24:15 -0500
Message-ID: <20070307232414.GZ26553@fieldses.org>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	nfs@lists.sourceforge.net, Simon Peter <simon.peter@gmx.de>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP5Tw-00035R-9F
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 15:23:40 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HP5Tx-0007FA-0M
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 15:23:42 -0800
In-Reply-To: <17903.16030.26119.464793@notabene.brown>
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

On Thu, Mar 08, 2007 at 09:37:18AM +1100, Neil Brown wrote:
> On Wednesday March 7, bfields@fieldses.org wrote:
> > 
> > Well, non-head-hurty ideas always welcomed.  I've got two export-related
> > problems to fix:
> > 
> > 	- Our current NFSv4 pseudofs fsid=0 hack is a pain to administer
> > 	  and results in inconsistent paths across different NFS
> > 	  versions.
> 
> You've got to put that v4 pseudo root somewhere...
> It just needs cleverness in nfs-utils to auto-bind-mount things into
> the pseudoroot...

I've got make-mountd-clever patches here; if I can get them working in
the next couple days then I'll pass them along so people can see what
they're doing.

> but I guess people cannot magically unmount things then.
>
> How about this.  We add an export option "follow-symlinks" so that
> when nfsd is asked to stat a symlink it does a 'stat' instead of an
> 'lstat' (effectively).
> Then we get mountd to make a tmpfs in /var/lib/nfs/pseudoroot which
> contains directories and symlinks to the various export points names
> in etab.  This tmpfs is exported as fsid=0,follow-symlinks.
> 
> Problem solved?

Maybe.  Getting those symlink/mountpoints right sounds tricky.

How different is this from the in-kernel automounting that the NFS
client is using for fsid traversal, for example?

> Ofcourse if different clients get to see different exports, then we
> might need multiple tmpfs's in /var/lib/nfs/pseudoroot/$CLIENT/ ....

Ugh.  Is this something a lot of people do?

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
