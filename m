From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Client Lockups
Date: Mon, 13 Dec 2004 10:51:31 -0500
Message-ID: <1102953091.15571.8.camel@lade.trondhjem.org>
References: <2d3ad3600412122208434463fc@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CdsUI-0005uX-JK
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 07:51:50 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CdsUH-0006Th-R3
	for nfs@lists.sourceforge.net; Mon, 13 Dec 2004 07:51:50 -0800
To: IHE Lists <ihelists@gmail.com>
In-Reply-To: <2d3ad3600412122208434463fc@mail.gmail.com>
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

m=E5 den 13.12.2004 Klokka 00:08 (-0600) skreiv IHE Lists:
> Here's the situation:
>=20
> We have a multithreaded Java application that does a great deal of IO
> over NFS. Almost daily, sometimes several times within a single day,
> we get an application deadlock. The error in the kernel syslog message
> is:
>=20
> Dec 11 11:09:05 <hostname> kernel: RPC: error 512 connecting to server
> <NFS server>

error 512 =3D=3D ERESTARTSYS. That just means that someone interrupted the
RPC call: your deadlock monitor would trigger this error when it sends
the kill -9.

> I believe the eventual total deadlock is a problem in the Java virtual
> machine, but I cannot determine what is causing the problem to begin
> with. Other applications on the same system do not lockup accessing
> other NFS mounts.

Have you tried using "strace" to figure out which system call is
hanging?

Also, which server are you using? The basic RedHat 7.3 certainly would
not support tcp on the server side.

Cheers,
  Trond

--=20
Trond Myklebust <trond.myklebust@fys.uio.no>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
