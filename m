From: Bernd Schubert <bernd-schubert@web.de>
Subject: list of patches between 2.6.9 and 2.6.11-rc4
Date: Mon, 21 Feb 2005 23:35:25 +0100
Message-ID: <200502212335.25502.bernd-schubert@web.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D3M8j-0007ft-4q
	for nfs@lists.sourceforge.net; Mon, 21 Feb 2005 14:34:53 -0800
Received: from smtp06.web.de ([217.72.192.224])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.41)
	id 1D3M8h-0005nt-L3
	for nfs@lists.sourceforge.net; Mon, 21 Feb 2005 14:34:53 -0800
To: nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
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

Hello Trond,

sorry for my dumb question, but I don't know where to search. Is it possibl=
e=20
to somewhere find the NFS client patches that go into the kernel versions?

We are mounting /var from an initrd giving the 'nolock' option. I havn't=20
analyzed it in detail yet, but the filelocking code from ypbind gets some=20
strange results causing ypbind not starting up at all. It worked fine with=
=20
2.6.9, but not with 2.6.11-rc4.=20
Afer mounting /var again, when the system is already started up and=20
explicitely giving the 'lock' option, ypbind starts up fine.
I'm now interested in the kernel changes that cause the problems.=20

The nfs-server for /var is unfs3, but I really think thats a client problem=
=2E I=20
also so far couldn't find something of interest in an ethereal log between=
=20
the client and server on the unfs3 port.


Thanks,
 Bernd





=2D-=20
Bernd Schubert
Physikalisch Chemisches Institut / Theoretische Chemie
Universit=E4t Heidelberg
INF 229
69120 Heidelberg
e-mail: bernd.schubert@pci.uni-heidelberg.de


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
