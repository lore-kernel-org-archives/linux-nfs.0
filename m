From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: async vs. sync
Date: Tue, 16 Nov 2004 08:15:58 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130435EB6A@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CU604-0007zS-JW
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 08:16:12 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1CU603-0003Yj-8G
	for nfs@lists.sourceforge.net; Tue, 16 Nov 2004 08:16:12 -0800
To: "Olaf Kirch" <okir@suse.de>
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

is the effect of the "sync" export option limited to NFSv3 COMMIT, or is
it limited to both NFSv3 COMMIT and NFSv3 FILE_SYNC/DATA_SYNC WRITE?

what are the effects on NFSv4 writes and commits?

> -----Original Message-----
> From: Olaf Kirch [mailto:okir@suse.de]
> Sent: Wednesday, July 28, 2004 4:57 AM
> To: Bernd Schubert
> Cc: nfs@lists.sourceforge.net
> Subject: Re: [NFS] async vs. sync
>=20
>=20
> Hi,
>=20
> the way the sync export option affects NFSv3 writes is
> limited to COMMITs, so if you see a slow-down here it must be=20
> bottle-necking in that part of the code.


-------------------------------------------------------
This SF.Net email is sponsored by: InterSystems CACHE
FREE OODBMS DOWNLOAD - A multidimensional database that combines
robust object and relational technologies, making it a perfect match
for Java, C++,COM, XML, ODBC and JDBC. www.intersystems.com/match8
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
