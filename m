From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS problem - close to open cache consistency broken ?
Date: Thu, 15 Sep 2005 06:50:49 -0700
Message-ID: <044B81DE141D7443BCE91E8F44B3C1E288E451@exsvl02.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EFu8k-00031y-JM
	for nfs@lists.sourceforge.net; Thu, 15 Sep 2005 06:51:02 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EFu8i-000469-Hd
	for nfs@lists.sourceforge.net; Thu, 15 Sep 2005 06:51:02 -0700
To: "Thomas Stockheim" <tommi@bub-agema.de>,
	"Peter Staubach" <staubach@redhat.com>
Sender: nfs-admin@lists.sourceforge.net
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

> > the client uses mtime and size to detect file changes on=20
> the server.  if
> > the mtime doesn't change on the server, the clients won't detect any
> > data changes.
> >=20
> > what physical file system are you using on the server?
>=20
> Thanks for the reply, but thats exactly my problem: Mtime does change
> on the server, and the client even sees that change ( faster=20
> or slower=20
> depending on caching settings ).
>=20
> But the data on the client never gets updated.
>=20
> I tested some more, and this only happens if another=20
> application on the
> client has the file open for writing.
>=20
> I think it might have to do something with the data_unstable flag in
> nfs_refresh_inode - but I don't understand the kernel code well enough
> to see what happens exactly or how to fix it for us.

peter, do you happen to know how the solaris NFS client behaves when an
application holds a file open like this?

close-to-open is a convention, not a specification, so it's really up to
the client developers to implement what they think is right.  i'm
guessing that the Linux client is working as designed here.  i'm not
convinced it's very *convenient* behavior, though.


-------------------------------------------------------
SF.Net email is sponsored by:
Tame your development challenges with Apache's Geronimo App Server. 
Download it for free - -and be entered to win a 42" plasma tv or your very
own Sony(tm)PSP.  Click here to play: http://sourceforge.net/geronimo.php
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
