From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Input/output error on hard mounted NFS directory
Date: Tue, 14 May 2002 14:37:26 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200205141437.26169.trond.myklebust@fys.uio.no>
References: <Pine.LNX.4.30.0205141313470.28229-100000@elin.scali.no>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: NFS mailinglist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mons.uio.no ([129.240.130.14])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 177bZH-0005yT-00
	for <nfs@lists.sourceforge.net>; Tue, 14 May 2002 05:38:15 -0700
To: Steffen Persvold <sp@scali.com>
In-Reply-To: <Pine.LNX.4.30.0205141313470.28229-100000@elin.scali.no>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

Tysdag 14. mai 2002 13:15 skreiv Steffen Persvold:

> > If you want to run a 2.2. client, then grab 2.2.21-rc2, and apply the
> > patch from
> >
> >   http://www.fys.uio.no/~trondmy/src/2.2.21-rc2/linux-2.2.21-NFS.dif
>
> Do I have to ?

Not if you can live with the bugs ;-)

> Will it fix my problem ? Other known NFS bugs ?

The 2.2.21-NFS patch fixes all the EIO bugs that were found in 2.4.x. You=
=20
might of course have found totally different bugs, but I really can't tel=
l=20
until you eliminate the first possibility.

Cheers,
  Trond

_______________________________________________________________

Have big pipes? SourceForge.net is looking for download mirrors. We supply
the hardware. You get the recognition. Email Us: bandwidth@sourceforge.net
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
