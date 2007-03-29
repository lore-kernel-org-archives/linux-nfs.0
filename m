From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: RELEASE CANDIDATE - nfs-utils-1.1.0-rc1
Date: Thu, 29 Mar 2007 12:35:21 -0400
Message-ID: <20070329163521.GB6143@fieldses.org>
References: <17931.15549.578071.112573@notabene.brown>
	<20070329084433.GA1627@sith.mimuw.edu.pl>
	<17931.34669.47062.146703@notabene.brown>
	<20070329124446.GZ23295@sith.mimuw.edu.pl>
	<1175178043.6182.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Jan Rekorajski <baggins@sith.mimuw.edu.pl>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HWxb9-0001Y7-6S
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 09:35:39 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HWxb8-0007E1-7H
	for nfs@lists.sourceforge.net; Thu, 29 Mar 2007 09:35:41 -0700
In-Reply-To: <1175178043.6182.4.camel@heimdal.trondhjem.org>
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

On Thu, Mar 29, 2007 at 10:20:43AM -0400, Trond Myklebust wrote:
> On Thu, 2007-03-29 at 14:44 +0200, Jan Rekorajski wrote:
> 
> > >   - idmapd and svcgssd should be started before nfsd
> > 
> > Here I must disagree, my experience shows that idmapd must be started (or
> > at least restarted) after mountd (or exportfs) is run.
> > I had no id mapping when I started idmapd before mountd/nfsd.
> 
> The only reason I can think of why you might have to restart idmapd
> after mountd is if your idmapd init script is failing to
> mount /proc/fs/nfsd.
> 
> > >  idmapd/svcgssd/gssd:
> > >    simply provide service to the kernel modules.   So they should
> > >    be running before the kernel wants them.
> > 
> > What's troubling me here is svcgssd - does it behave like idmapd and
> > requires mountd? My quick investigation in the source telss me it is so.
> 
> Ditto. svcgssd also assumes that you have mounted /proc/fs/nfsd. Fix
> your svcgssd init script if this is not already the case.

That's been a common source of errors in the past.  Maybe svcgssd and
idmapd should be taught to watch for changes to the /proc/ directories
it cares about, maybe using dnotify or inotify.

--b.

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
