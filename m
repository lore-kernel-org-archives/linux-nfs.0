From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: RE: NFS/UDP slow read, lost fragments
Date: Thu, 25 Sep 2003 13:11:35 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C6113D06D31@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A2cTB-0006iV-00
	for <nfs@lists.sourceforge.net>; Thu, 25 Sep 2003 13:12:09 -0700
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.22)
	id 1A2cTA-0004ES-2U
	for nfs@lists.sourceforge.net; Thu, 25 Sep 2003 13:12:08 -0700
To: "Robert L. Millner" <rmillner@transmeta.com>
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

hi robert-

if packets are being lost in server replies, then i
don't think this is strictly a client problem.

the newer clients may be more likely to overload a server
or network by sending more requests than can be buffered.
look into network cleanliness, and contact your local
NetApp SE for help in getting diagnostic info from your
filer.

especially because this problem goes away with TCP, i
would suspect a networking problem first.

> -----Original Message-----
> From: Robert L. Millner [mailto:rmillner@transmeta.com]=20
> Sent: Thursday, September 25, 2003 2:00 PM
> To: nfs@lists.sourceforge.net
> Subject: [NFS] NFS/UDP slow read, lost fragments
>=20
>=20
> Hello,
>=20
> The problem I am seeing is similar to what was posted by=20
> Larry Sendlosky
> on Jun 27, "2.4.20-pre3 -> 2.4.21 : nfs client read=20
> performance broken"
> though I have not done as through a drill-down into the nature of the
> problem.
>=20
> Somewhere between 2.4.19 and 2.4.20, NFS/UDP read performance began to
> suck because of a large number of request retransmits.  From=20
> tcpdump, the
> retransmits are for read transactions which return data in a=20
> reasonable
> time frame but are missing one or more fragments of the return packet.
>=20
> The client is a PIII 550, dual CPU, 1GB RAM, eepro100 (tested=20
> with both
> the e100 and eepro drivers) running a variety of kernels from=20
> the stock
> Red Hat 7.3 (2.4.20-20.7 which exhibits the problem), and from stock
> 2.4.18 through 2.4.22.  2.4.20 and above exhibit this problem.
>=20
> The server is a Network Appliance F820 running ONTAP 6.2.2.  Tests are
> conducted when the F820 is not under a noticeable load.
>=20
> >From the difference in behavior between kernel revisions and=20
> by tcpdump,=20
> it is believed that the fragments are transmitted by the server.
>=20
> The timings for different IO sizes for NFSv3 reads of a 70MB file:
>=20
> Configuration             Seconds Real Time
> -------------------------------------------
> UDP, 32k                       1080
> UDP,  8k                        420
> UDP,  4k                        210
> UDP,  1k                         40
>=20
> TCP, 32k                          6.4
>=20
>=20
> The NFSv2/UDP timings for 8k, 4k and 1k are almost identical to the
> NFSv3/UDP timings.
>=20
> The same test with 2.4.18 yields read times for around 6.3=20
> seconds for 32k
> and 8k NFSv2 and NFSv3 over UDP.
>=20
> Setting rmem_max, rmem_default, wmem_max and wmem_default to=20
> either 524284=20
> or 262142 make no difference.
>=20
> Setting netdev_max_backlog to 1200 (from 300) makes no difference.
>=20
> Setting ipfrag_high_thresh to up to 4194304 makes no difference.
>=20
>=20
> We have a mix of clients and servers, not all of which=20
> support NFS/TCP yet
> so we can't globally set tcp in the automounter maps for our=20
> netapp mounts
> or as "localoptions" in the autofs init script.  The mount=20
> patch submitted
> by Steve Dickson on Aug 6, "NFS Mount Patch:  Making NFS over TCP the
> default" is probably the immediate workaround that will at=20
> least make the
> mounts that really matter to us work well again.  I'll test that next.
>=20
>=20
> Is this a known problem?  Is there a patch already out there or in the
> works that fixes this?  What other data would help drill into this
> problem?
>=20
>=20
> 	Rob
>=20
>=20
>=20
> -------------------------------------------------------
> This sf.net email is sponsored by:ThinkGeek
> Welcome to geek heaven.
> http://thinkgeek.com/sf
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
