From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: async vs. sync
Date: Mon, 22 Nov 2004 10:31:07 -0800
Message-ID: <482A3FA0050D21419C269D13989C611307CF4B53@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>, <mci-unix@int-evry.fr>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWIz3-00014t-R9
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 10:32:17 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CWIz2-0004hQ-GF
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 10:32:17 -0800
To: "Roger Heflin" <rheflin@atipa.com>,
	"jehan.procaccia" <jehan.procaccia@int-evry.fr>
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

> If you put sync in both locations then your NFS disk is fully=20
> synced and=20
> the application won't even start another write until the last=20
> one is confirmed
> finished and on the actual disk.   With async on the client=20
> end the next
> write=20
> will start before the client has received an ack from the=20
> server, and this will be reasonably fast.
>=20
> So basically:
>=20
> exports          mount
> sync             sync      -> really safe and really slow
> sync             async     -> Safe and fast
> async            either    -> unsafe and fast.
>=20
> Running async exports and async mount did not appear (under=20
> my testing) to be faster under a sustained load than did sync=20
> exports and async mount. When the initial test was started=20
> async/async was faster but that quick changed once the buffer=20
> cache filled up.

the "async" setting on the client side is the default.  using the "sync"
mount option on the client side will be slow no matter what.

the recommended settings are:

1. don't use the "sync" mount option on the client unless your
application requires it

2. always use the "sync" export option (with newer nfs-utils, this is
the default).


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
