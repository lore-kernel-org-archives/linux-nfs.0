From: "Heflin, Roger A." <Roger.A.Heflin@conoco.com>
Subject: Re: nfs performance: read only/gigE/nolock/1Tb per day
Date: Mon, 22 Apr 2002 16:45:58 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <49CA7FE2A83A33459A2CD27E99E90EFB0BAE74@poexmb1.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail2.conoco.com ([12.31.208.227])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16zldK-00075u-00
	for <nfs@lists.sourceforge.net>; Mon, 22 Apr 2002 14:46:02 -0700
To: <nfs@lists.sourceforge.net>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>



> Date: Mon, 22 Apr 2002 20:52:23 +0200 (CEST)
> From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
> To: nfs@lists.sourceforge.net
> cc: "Lever, Charles" <Charles.Lever@netapp.com>,
>    "'jason andrade'" <jason@dstc.edu.au>
> Subject: Re: [NFS] nfs performance: read only/gigE/nolock/1Tb per day
>=20
> On 22 Apr 2002, Trond Myklebust wrote:
>=20
> > What might perhaps be happening is that the cards are somehow =
getting
> > messed up due to data flooding. Have you tried playing around with
> > driver parameters such as 'max_interrupt_work', 'max_rx_desc' and/or
> > other interrupt-related variables? (see 'modinfo -p <module>' for =
the
> > list of supported paramenters)
>=20
> In case of network problems, some more info can be obtained from=20
> /proc/net/; f.e. /proc/net/dev can give some ideea about low level=20
> (driver) problems, where the most interesting might be "Rx overruns"
> (the computer can't process packets as fast as they arrive and has to =
drop=20
> them as soon as the Rx ring becomes full - if your network driver has =
such=20
> parameter like "max_rx_desc" it should be increased). I don't know how =
to=20
> interpret all the data that is there, but either using the source or=20
> asking the Linux network developers at netdev@oss.sgi.com might help.
>=20
> "max_interrupt_work" should not be modified unless a message like =
"ethx:=20
> Too much work in interrupt!" is logged by the kernel. In some cases,=20
> increasing "max_interrupt_work" without also increasing the Rx ring =
size=20
> would not help.
>=20
	I would suggest using "netstat -s" as things are a bit easier to read,
	and most things that you will need to make sure aren't rising are
	there (maybe all).   Errors, timeouts, invalids, and fails rising too =
quickly
	are signs of problems with the underlying network, and packets are
	getting misplaced.  I have found that if you lose even a small percent
	of the packets you will take a large speed hit, and it will be quite a =
bit
	worse with UDP vs. TCP, and the larger the UDP packet size the worse
	it will be as you need to retransmit the entire packet with UDP.

				Roger =20

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
