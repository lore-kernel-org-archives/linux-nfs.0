From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Poor NFS performance, kernel 2.6.6.
Date: Tue, 01 Jun 2004 23:57:41 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1086159461.10317.5.camel@lade.trondhjem.org>
References: <Pine.LNX.4.58.0405271331430.7539@penti.sit.fi>
	 <1085695748.23934.94.camel@lade.trondhjem.org>
	 <Pine.LNX.4.58.0405280953240.29286@penti.sit.fi>
	 <20040528135515.GG5657@suse.de>
	 <Pine.LNX.4.58.0405282058300.14886@penti.sit.fi>
	 <1085771968.3882.17.camel@lade.trondhjem.org>
	 <20040601001658.GA7373@outblaze.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: Harald Hannelius <harald+nfs@arcada.fi>, Olaf Kirch <okir@suse.de>,  nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BVPi1-0007qd-JJ
	for nfs@lists.sourceforge.net; Tue, 01 Jun 2004 23:58:45 -0700
Received: from [209.101.250.228] (helo=lade.trondhjem.org)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BVPhz-0000CF-Mu
	for nfs@lists.sourceforge.net; Tue, 01 Jun 2004 23:58:44 -0700
To: Yusuf Goolamabbas <yusufg@outblaze.com>
In-Reply-To: <20040601001658.GA7373@outblaze.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

P=E5 m=E5 , 31/05/2004 klokka 17:16, skreiv Yusuf Goolamabbas:
> > > I guess (as a total don't-know) that nfsd reads and writes files in a
> > > different way than local processes do. I read somewhere something abo=
ut
> > > read-ahead but that was in 2.6.0-pre-something..
> >=20
> > Hmm... The current readahead code does a load of crap in order to
> > determine whether or not the user is doing linear or random I/O. It may
> > be that the nfsd server with all its multi-threading and out-of-sequenc=
e
> > I/O is triggering the random I/O readahead code (which of course aims t=
o
> > limit readahead).
>=20
> Any thoughts on this patch posted to lkml=20
>=20
> http://marc.theaimsgroup.com/?l=3Dlinux-kernel&m=3D108603045809565&w=3D2

May or may not fix a bug in the NFSd code. Does nothing to change the
basic readahead code in the VFS layer in order to fix the issues I
raised above.

Cheers,
 Trond


-------------------------------------------------------
This SF.Net email is sponsored by the new InstallShield X.
