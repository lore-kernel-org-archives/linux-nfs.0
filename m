From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS Performance Between SGI Servers and Linux Clients
Date: Thu, 22 May 2003 15:07:33 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113127DEB@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19IyEU-00055u-00
	for <nfs@lists.sourceforge.net>; Thu, 22 May 2003 15:08:18 -0700
To: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
   "Iain Irwin-Powell" <iain@cinesite.co.uk>
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

> -----Original Message-----
> From: Trond Myklebust [mailto:trond.myklebust@fys.uio.no]
> Sent: Thursday, May 22, 2003 5:13 PM
> To: Iain Irwin-Powell
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] NFS Performance Between SGI Servers and=20
> Linux Clients
>=20
>=20
> >>>>> " " =3D=3D Iain Irwin-Powell <iain@cinesite.co.uk> writes:
>=20
>      > Looking a bit deeper in a packet trace when the grep is
>      > running, Linux seems to issue 16 read requests (16KB) at a time
>      > whilst an SGI will only issue between 2 and 4. May or may not
>      > be relevant.
>=20
> ... and this is a problem because .... ???
>=20
> The Linux client tries to read ahead as much as it can and as quickly
> as it can. Why should it doing anything else?

well, this is one reason why NFS O_DIRECT is a desirable
feature.  no readahead.  certain applications don't need
it because the workload they generate is entirely random
small reads.  in these cases, read ahead wastes I/O
bandwidth and memory space with data that is never used
by an application.

trond, isn't there a read ahead value in the client that
can be tweaked?  he could trim down vm_max_readahead,=20
unless there is a max_readahead[] entry for anonymous
file systems.

either that will help iain, or prove that the problem
is not a result of read ahead.


-------------------------------------------------------
This SF.net email is sponsored by: ObjectStore.
If flattening out C++ or Java code to make your application fit in a
relational database is painful, don't do it! Check out ObjectStore.
Now part of Progress Software. http://www.objectstore.net/sourceforge
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
