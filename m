From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: async vs. sync
Date: Mon, 22 Nov 2004 19:53:17 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130435EBD8@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWRk7-000699-0X
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 19:53:27 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CWRk2-0007jO-U6
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 19:53:27 -0800
To: "Dan Stromberg" <strombrg@dcs.nac.uci.edu>
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

> > not to mention "soft" mounts are also truly the spawn of satan.
>=20
> Unless your filesystem is also readonly...

unfortunately that is a myth.  even a readonly file system can fall
victim to the evils of soft mounts, i'm told.

the cached version of the file on the client can become corrupted if the
file is changing remotely and one or more cache-refresh reads times out.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
