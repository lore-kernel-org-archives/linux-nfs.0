From: Andrew Brooks <arb@sat.dundee.ac.uk>
Subject: Enable NFS over TCP
Date: Thu, 07 Apr 2005 16:17:15 +0100
Message-ID: <42554EFB.9E4@sat.dundee.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DJYl1-0001sx-R8
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 08:17:23 -0700
Received: from cerise.sat.dundee.ac.uk ([134.36.22.46] helo=sat.dundee.ac.uk)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.41)
	id 1DJYl1-00077a-9i
	for nfs@lists.sourceforge.net; Thu, 07 Apr 2005 08:17:23 -0700
Received: from modis (modis [134.36.22.44])
	by sat.dundee.ac.uk (8.12.10/8.12.10) with SMTP id j37FHFth020533
	for <nfs@lists.sourceforge.net>; Thu, 7 Apr 2005 16:17:16 +0100 (BST)
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

Hi,

Sorry to bring up this old chestnut but I can't get my server to
advertise the TCP service; rpcinfo shows only udp and mount -o tcp
reports "nfs server reported service unavailable: Address already
in use".

I've rebuilt the kernel 2.4.26 with all NFS patches and both ticked:
CONFIG_EXPERIMENTAL and CONFIG_NFSD_TCP.

nfs-utils 1.0.7 has been installed (on the server at least).

/etc/init.d/nfs and /etc/sysconfig/nfs look ok.

Now I'm out of ideas!

Thanks,

Andrew


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
