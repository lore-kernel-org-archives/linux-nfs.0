From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Delays on "first" access to a NFS mount
Date: Wed, 7 Mar 2007 15:50:16 -0500
Message-ID: <20070307205016.GI26553@fieldses.org>
References: <20070307112347.6a40faff.simon.peter@gmx.de>
	<EXNANE015HfqR77bieL0000006b@exnane01.hq.netapp.com>
	<20070307160633.77afb618.simon.peter@gmx.de>
	<20070307154240.GB26553@fieldses.org>
	<20070307194418.97fee0ec.simon.peter@gmx.de>
	<EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, Simon Peter <simon.peter@gmx.de>
To: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HP34z-0003Tp-8A
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 12:49:47 -0800
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HP34x-0007du-UF
	for nfs@lists.sourceforge.net; Wed, 07 Mar 2007 12:49:44 -0800
In-Reply-To: <EXNANE01FRaqbC8wSA100000073@exnane01.hq.netapp.com>
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

On Wed, Mar 07, 2007 at 03:31:49PM -0500, Talpey, Thomas wrote:
> At 01:44 PM 3/7/2007, Simon Peter wrote:
> >> Could we cache the stat information in the export and then
> >> double-check it if necessary when there's a match?  Or is there some
> >> way we could get the kernel to keep that cached for us?
> >
> >I could certainly cook up a patch for mountd to cache that information
> >on its own. I don't have too much clue about how the kernel does its
> >cacheing, though. If it's useful to do that directly in mountd, I could
> >get my hands on it.
> 
> This sounds like a job for inotify. The mountd could stat the export root
> and use inotify_add_watch(2) to keep an eye on it to see if the stat
> contents changed.

Hm.  Would it be enough just to hold an open file descriptor for the
directory?  Is it safe to assume that for any filesystem (uh, any disk
filesystem anyway) that if you have something open then stat() on it
won't have to go to the disk?

> You probably don't want to sign up for enhancing the in-kernel export
> cache. :-) Let's just say it's a bit mysterious, especially its interaction
> with mountd.

I sympathize, though this is actually one of the few mysteries of our
nfs implementation that I feel like I understand, at least on alternate
Thursdays....  What's bugging me a lot these days is I don't understand
well enough why it's the way it is and what might need to be done to
make it better.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
