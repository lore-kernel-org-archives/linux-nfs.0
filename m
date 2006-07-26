From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: protocol question
Date: Wed, 26 Jul 2006 08:19:54 -0400
Message-ID: <1153916394.5656.23.camel@localhost>
References: <200607261247.35653.bernd.schubert@pci.uni-heidelberg.de>
	<1153914204.5656.13.camel@localhost>
	<200607261356.38520.bernd.schubert@pci.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5k3c-0004ds-NL
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 07:08:16 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5k3b-0005qc-Lj
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 07:08:16 -0700
Received: from pat.uio.no ([129.240.10.4] ident=7411)
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41) id 1G5iN3-00067l-OL
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 05:20:14 -0700
To: bernd-schubert@gmx.de
In-Reply-To: <200607261356.38520.bernd.schubert@pci.uni-heidelberg.de>
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

On Wed, 2006-07-26 at 13:56 +0200, Bernd Schubert wrote:
> [Sorry that I forgot a proper subject first]
> 
> Hi Trond,
> 
> thanks for your help,
> 
> On Wednesday 26 July 2006 13:43, Trond Myklebust wrote:
> > On Wed, 2006-07-26 at 12:47 +0200, Bernd Schubert wrote:
> [...]
> > > Ethereal shows that the getattr gives the correct results, but the read
> > > call gives an NFS3ERR_STALE.
> > > Should the client in this case drop its filehandle cache and entirely
> > > re-request the file from the server, or is the given i/o error ok?
> >
> > The ESTALE error is usually correct. The client should not be reopening
> > the file unless it can guarantee that the file is the same as the one
> > that was originally open()ed.
> 
> But the client returns an i/o error to the userspace, is this correct?

No. It will return an ESTALE to userspace in this case.

> > > From the point of the server, I guess, it already should return the
> > > NFS3ERR_STALE for the getattr call, shouldn't it? I will look into the
> > > sources to see why it didn't. (unfs3 was compiled with inode generation
> > > number support).
> >
> > Yes. Under the close-to-open caching model, the expectation is that the
> > filehandle will remain valid from the moment the successful GETATTR call
> > is sent in the first open() request until the last call to close(). If
> > unfs3 is caching filehandles, then it needs to use something like
> > inotify in order to figure out when to invalidate its cache.
> 
> Hmm, but the inode generation number should have changed, isn't it there for 
> exactly this purpose? I also restarted unfs3 first, so it didn't have any 
> filehandles cached.

Right. The inode generation number changes when the inode number is
reused. After that, any NFS rpc request containing the filehandle with
the old generation number should receive an immediate NFSERR3_STALE.

My point about inotify was merely a way to help enforce that in the case
where a userland-based server might want to cache filehandles. I've no
idea whether or not unfs3 actually does that sort of thing.

Cheers,
  Trond


-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
