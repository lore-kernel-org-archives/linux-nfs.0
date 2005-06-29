From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Re: [PATCH] Smooth out NFS client writeback
Date: Wed, 29 Jun 2005 07:25:41 -0700
Message-ID: <482A3FA0050D21419C269D13989C611307CF4CE6@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: "Trond Myklebust" <trond.myklebust@fys.uio.no>,
	<nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.92] (helo=sc8-sf-mx2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DndVe-0001EO-5p
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 07:25:50 -0700
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx2-new.sourceforge.net with esmtp (Exim 4.44)
	id 1DndVb-0003PD-Vt
	for nfs@lists.sourceforge.net; Wed, 29 Jun 2005 07:25:50 -0700
To: "Peter Staubach" <staubach@redhat.com>,
	"Shantanu Goel" <sgoel01@yahoo.com>
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

hi peter-

> On Solaris, at least with UFS as the underlying file system,=20
> the COMMIT
> operations are processed by looking through the entire cached=20
> page list
> or by doing page lookup operations on each individual page. =20
> If the entire
> file is specified, ie. len =3D 0, then the page list is walked.=20
>  If a range
> is specified, then just the pages within the range are looked up.
>=20
> Specifying the range can result in significantly less CPU=20
> overhead on the
> server.  This is why the NFSv3 COMMIT operation has a range=20
> which can be specified...  :-)

a server CPU inefficiency hardly qualifies as a client bug.  in the most
common cases where the client is creating and writing to a file, then
closing with a COMMIT(0,0) request, the server should be changed to
behave in a more efficient manner.

in other words, i think the client should optimize the number of
requests on the wire, and the server should optimize for using its CPU
and disks most efficiently.  i haven't looked closely at shantanu's
patch, but i'm a little leary of the change if it means more wire
operations are generated than before.


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
