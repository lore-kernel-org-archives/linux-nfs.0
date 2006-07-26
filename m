From: Bernd Schubert <bernd.schubert@pci.uni-heidelberg.de>
Subject: Re: protocol question
Date: Wed, 26 Jul 2006 17:32:23 +0200
Message-ID: <200607261732.24191.bernd.schubert@pci.uni-heidelberg.de>
References: <200607261247.35653.bernd.schubert@pci.uni-heidelberg.de>
	<200607261356.38520.bernd.schubert@pci.uni-heidelberg.de>
	<1153916394.5656.23.camel@localhost>
Reply-To: bernd-schubert@gmx.de
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G671C-0007HB-LT
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 07:39:18 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1G6718-0006C1-Mz
	for nfs@lists.sourceforge.net; Thu, 27 Jul 2006 07:39:17 -0700
Received: from relay.uni-heidelberg.de ([129.206.100.212])
	by externalmx-1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41) id 1G5lNA-0001LY-8M
	for nfs@lists.sourceforge.net; Wed, 26 Jul 2006 08:32:33 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1153916394.5656.23.camel@localhost>
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

> > But the client returns an i/o error to the userspace, is this correct?
>
> No. It will return an ESTALE to userspace in this case.

Sorry, I didn't express myself properly, it _did_ return i/o error.

[...]
> Right. The inode generation number changes when the inode number is
> reused. After that, any NFS rpc request containing the filehandle with
> the old generation number should receive an immediate NFSERR3_STALE.

> Oops. Actually, it would be more correct to say that the filehandle is
> invalidated immediately once the file has been deleted on the server.
>
> The generation number is there in order to ensure that the old
> filehandle is not 'resurrected' when the inode number is reused.

I need to have a look how Pascal actually used the generation numbers.

>
> My point about inotify was merely a way to help enforce that in the case
> where a userland-based server might want to cache filehandles. I've no
> idea whether or not unfs3 actually does that sort of thing.

There is a cache, but thats the part I so far never looked into.

Thanks a lot for your help,
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
