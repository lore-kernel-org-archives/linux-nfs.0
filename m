From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Delays on "first" access to a NFS mount
Date: Wed, 7 Mar 2007 15:29:49 -0500
Message-ID: <20070307202949.GH26553@fieldses.org>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net,
	"Talpey, Thomas" <Thomas.Talpey@netapp.com>
To: Simon Peter <simon.peter@gmx.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP2lB-0001Cq-Cl
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 12:29:17 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HP2lC-0002p3-4w
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 12:29:19 -0800
In-Reply-To: <20070307194418.97fee0ec.simon.peter@gmx.de>
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

On Wed, Mar 07, 2007 at 07:44:18PM +0100, Simon Peter wrote:
> > > just verified that the server indeed spins up all disks before
> > > answering the request. I thus suspect it is somehow checking all
> > > exports whenever any one export is accessed. Is this correct
> > > behaviour?
> > Hm.  If you have the nfs-utils source, you can see there's a loop in
> > 	nfs-utils/utils/mountd/cache.c:nfsd_fh()
> > that stats the root of each export, in two places; the first it looks
> > like you shouldn't hit if you don't have the mountpoint export option
> > set:
> 
> Correct. This one is never hit in my case.
> 
> > The second is to figure out which filesystem the filehandle that you
> > passed in that getattr is for:
> >          if (stat(exp->m_export.e_path, &stb) != 0)
> >                  continue;
> 
> This is where the wait for the respective disk to spin up occurs.

OK, cool, so we understand the problem.

> > Could we cache the stat information in the export and then
> > double-check it if necessary when there's a match?  Or is there some
> > way we could get the kernel to keep that cached for us?
> 
> I could certainly cook up a patch for mountd to cache that information
> on its own.  I don't have too much clue about how the kernel does its
> cacheing, though. If it's useful to do that directly in mountd, I
> could get my hands on it.

There's two caches involved:

	- the filesystem caches attributes so that subsequent stat's of
	  the exported directory can be answered without having to go to
	  disk.  I guess it's not suprising that that wouldn't be cached
	  anymore if you hadn't touched the filesystem in a long time.
	  Though there's one point I'm unclear on: are the directories
	  you're exporting mountpoints?  That's the normal
	  configuration, and in that case I would've thought the inode
	  for that directory would be pinned in memory so the stat
	  wouldn't have to go to disk.  I'm probably missing something.

	- the filehandle->export mapping that this function tells the
	  kernel about is cached by nfsd for a half-hour.  That time is
	  set a little later in nfsd_fh:

	          qword_printint(f, time(0)+30*60);

	  I don't think there would be any harm to just changing that
	  time(0)+30*60 to 0x7FFFFFFF (== never expire)--nfs-utils
	  should be invalidating that cache explicitly whenever it's
	  needed.  Maybe that should be the default.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
