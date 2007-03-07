From: Neil Brown <neilb@suse.de>
Subject: Re: Delays on "first" access to a NFS mount
Date: Thu, 8 Mar 2007 10:51:04 +1100
Message-ID: <17903.20457.448449.509272@notabene.brown>
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
	<20070307232414.GZ26553@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>,
	Simon Peter <simon.peter@gmx.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP5uc-0005oq-68
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 15:51:14 -0800
Received: from mx2.suse.de ([195.135.220.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HP5ud-00028F-JY
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 15:51:16 -0800
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
> On Thu, Mar 08, 2007 at 09:37:18AM +1100, Neil Brown wrote:
> > On Wednesday March 7, bfields@fieldses.org wrote:
> > > 
> > > Well, non-head-hurty ideas always welcomed.  I've got two export-related
> > > problems to fix:
> > > 
> > > 	- Our current NFSv4 pseudofs fsid=0 hack is a pain to administer
> > > 	  and results in inconsistent paths across different NFS
> > > 	  versions.
> > 
> > You've got to put that v4 pseudo root somewhere...
> > It just needs cleverness in nfs-utils to auto-bind-mount things into
> > the pseudoroot...
> 
> I've got make-mountd-clever patches here; if I can get them working in
> the next couple days then I'll pass them along so people can see what
> they're doing.

Cool.

> 
> > but I guess people cannot magically unmount things then.
> >
> > How about this.  We add an export option "follow-symlinks" so that
> > when nfsd is asked to stat a symlink it does a 'stat' instead of an
> > 'lstat' (effectively).
> > Then we get mountd to make a tmpfs in /var/lib/nfs/pseudoroot which
> > contains directories and symlinks to the various export points names
> > in etab.  This tmpfs is exported as fsid=0,follow-symlinks.
> > 
> > Problem solved?
> 
> Maybe.  Getting those symlink/mountpoints right sounds tricky.

Is it?
 mount -t tmpfs tmpfs /var/lib/nfs/pseudoroot
 grep '^/' /etc/exports | while read a b
 do
   d=`dirname $a`
   mkdir -p /var/lib/nfs/pseudoroot/$d
   ln -s $a /var/lib/nfs/pseudoroot/$a
 done
(untested, and probably has some corner cases but the essence is
 there).


> 
> How different is this from the in-kernel automounting that the NFS
> client is using for fsid traversal, for example?
> 
> > Ofcourse if different clients get to see different exports, then we
> > might need multiple tmpfs's in /var/lib/nfs/pseudoroot/$CLIENT/ ....
> 
> Ugh.  Is this something a lot of people do?

Well, if you export a different root filesystem to each diskless
client, or if you export /home to some places and /backup to others,
then you already have the potential for a different pseudo filesystem
for each client.  My little hacky shell script above essentially
merges them all which might be OK, or might not.

Suppose you wanted to allow every diskless client to see it's root as
'/'?  Is that a dumb thing to do, or just a difficult thing to do?

I was just looking at the RFC again and saw this in section 7.3:

   Based on the construction of the server's name space, it is possible
   that multiple pseudo filesystems may exist.  For example,

   /a         pseudo filesystem
   /a/b       real filesystem
   /a/b/c     pseudo filesystem
   /a/b/c/d   real filesystem

   Each of the pseudo filesystems are considered separate entities and
   therefore will have a unique fsid.

That adds a whole new dimension of complexity..... do we really want
to go there?

NeilBrown

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
