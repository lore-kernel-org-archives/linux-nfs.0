From: Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de>
Subject: Re: protocol question
Date: Wed, 26 Jul 2006 13:56:38 +0200
Message-ID: <200607261356.38520.bernd.schubert@pci.uni-heidelberg.de>
References: <200607261247.35653.bernd.schubert@pci.uni-heidelberg.de>
	<1153914204.5656.13.camel@localhost>
Reply-To: bernd-schubert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G5i0R-0002Md-Pi
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 04:56:51 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G5i0S-0007A8-1h
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 04:56:52 -0700
Received: from relay2.uni-heidelberg.de ([129.206.210.211])
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1G5i0Q-0001Ln-NH
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 04:56:51 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1153914204.5656.13.camel@localhost>
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

[Sorry that I forgot a proper subject first]

Hi Trond,

thanks for your help,

On Wednesday 26 July 2006 13:43, Trond Myklebust wrote:
> On Wed, 2006-07-26 at 12:47 +0200, Bernd Schubert wrote:
[...]
> > Ethereal shows that the getattr gives the correct results, but the read
> > call gives an NFS3ERR_STALE.
> > Should the client in this case drop its filehandle cache and entirely
> > re-request the file from the server, or is the given i/o error ok?
>
> The ESTALE error is usually correct. The client should not be reopening
> the file unless it can guarantee that the file is the same as the one
> that was originally open()ed.

But the client returns an i/o error to the userspace, is this correct?

>
> > From the point of the server, I guess, it already should return the
> > NFS3ERR_STALE for the getattr call, shouldn't it? I will look into the
> > sources to see why it didn't. (unfs3 was compiled with inode generation
> > number support).
>
> Yes. Under the close-to-open caching model, the expectation is that the
> filehandle will remain valid from the moment the successful GETATTR call
> is sent in the first open() request until the last call to close(). If
> unfs3 is caching filehandles, then it needs to use something like
> inotify in order to figure out when to invalidate its cache.

Hmm, but the inode generation number should have changed, isn't it there fo=
r =

exactly this purpose? I also restarted unfs3 first, so it didn't have any =

filehandles cached.


Thanks again,
	Bernd

-- =

Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=3Djoin.php&p=3Dsourceforge&CID=3DDE=
VDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
