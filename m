From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: Intermittent RHE3-u3 client mount failures to Netapp fileserver
Date: Wed, 15 Dec 2004 08:19:16 -0800
Message-ID: <482A3FA0050D21419C269D13989C61130853955E@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cebs7-0006zf-Pg
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 08:19:27 -0800
Received: from mx1.netapp.com ([216.240.18.38])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1Cebs6-0006nm-IA
	for nfs@lists.sourceforge.net; Wed, 15 Dec 2004 08:19:27 -0800
To: "David Meleedy" <david.meleedy@analog.com>
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

> I have been trying to troubleshoot this problem on Redhat Enterprise 3
> WS update 3, both iX86 and amd64 versions.  I have already sent this
> to the automounter mailing list, and I suspect they don't have a
> solution because it is more nfs related.
>=20
> The problem is that intermittently, a previously mounted=20
> directory that
> had been mounted with the automounter, and then unmounted becomes
> unavailable.  The amount of time of unavailability seems to be related
> to the --timeout=3D60 option specified to the automount program.
>=20
> I don't believe the routing equipment is at fault because using the
> same network ports, we have had Redhat 8 clients working just fine.

what's running on port 98 on your RHEL 3.0 boxes?  (netstat)

and check the hardware too.  we had an IPMI hardware implementation from
Intel at one point that took a port without notifying the operating
system, and that caused similar failures.

vers=3D2 and nolock are probably not necessary, and will likely cause =
more
problems than they solve.


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
