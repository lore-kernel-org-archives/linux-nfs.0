From: Peter Schneider-Kamp <psk@informatik.rwth-aachen.de>
Subject: how much CPU/RAM does NFS need?
Date: Mon, 28 Nov 2005 14:48:04 +0100
Message-ID: <438B0A94.8090201@informatik.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EgjMV-0001yx-CR
	for nfs@lists.sourceforge.net; Mon, 28 Nov 2005 05:48:07 -0800
Received: from ms-1.rz.rwth-aachen.de ([134.130.3.130] helo=ms-dienst.rz.rwth-aachen.de)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1EgjMT-0006zM-Us
	for nfs@lists.sourceforge.net; Mon, 28 Nov 2005 05:48:07 -0800
Received: from r220-1 (r220-1.rz.RWTH-Aachen.DE [134.130.3.31])
 by ms-dienst.rz.rwth-aachen.de
 (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTP id <0IQO00H1C3O0EL@ms-dienst.rz.rwth-aachen.de> for
 nfs@lists.sourceforge.net; Mon, 28 Nov 2005 14:48:00 +0100 (MET)
To: nfs@lists.sourceforge.net
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

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi,

we are about to purchase a file server for a 3,2 TerraByte disk array
which has 2 GBit/s fibre channel connections. The server will
have a PCI-X 133MHz fibre channel controller and a PCI-X 133MHz fibre
ethernet card.

How much CPU do we need to serve approx. 1 GBit/s of NFS from the
disk array to the network? The server will be dedicated, i.e., there
will be no other applications running on it.

And, similarly, how many GBytes of RAM are useful for buffering?

Kind regards,
Peter
- --
Peter Schneider-Kamp   mailto:psk@informatik.rwth-aachen.de
LuFG Informatik II     http://www-i2.informatik.rwth-aachen.de/~nowonder
RWTH Aachen            phone: ++49 241 80-21211
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFDiwqU3VbrCXkKHhwRAtpyAKC3QAeIG+7DSdOJ3ViO+Pef4IVdiACgrkc1
1l9VypP8I2ZCOyOpLptvhXY=
=AERV
-----END PGP SIGNATURE-----



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
