From: "Didier CONTIS" <didier@ece.gatech.edu>
Subject: RE: Pb of optimization for a Cluster under Gigabit
Date: Wed, 7 Apr 2004 16:38:20 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200404072038.i37KcKgE008514@mail.ece.gatech.edu>
References: <Pine.LNX.4.44.0404071339080.25211-100000@kenzo.iwr.uni-heidelberg.de>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BBJpN-0004xD-JO
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 13:39:17 -0700
Received: from mail.ece.gatech.edu ([199.77.227.200])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.30)
	id 1BBJpN-0006iQ-AX
	for nfs@lists.sourceforge.net; Wed, 07 Apr 2004 13:39:17 -0700
Received: from localhost (bigzilla.ece.gatech.edu [130.207.225.103])
	by mail.ece.gatech.edu (8.12.10/8.12.10) with ESMTP id i37KdEat008632
	for <nfs@lists.sourceforge.net>; Wed, 7 Apr 2004 16:39:14 -0400 (EDT)
Received: from mail.ece.gatech.edu ([199.77.227.200])
 by localhost (bigzilla.ece.gatech.edu [130.207.225.103]) (amavisd-new, port 10024)
 with LMTP id 20788-06 for <nfs@lists.sourceforge.net>;
 Wed,  7 Apr 2004 16:39:00 -0400 (EDT)
Received: from darkwolf (darkwolf.ee.gatech.edu [130.207.226.19])
	(authenticated bits=0)
	by mail.ece.gatech.edu (8.12.10/8.12.10) with ESMTP id i37KcKgE008514
	(version=TLSv1/SSLv3 cipher=RC4-MD5 bits=128 verify=NOT)
	for <nfs@lists.sourceforge.net>; Wed, 7 Apr 2004 16:38:20 -0400 (EDT)
To: <nfs@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.44.0404071339080.25211-100000@kenzo.iwr.uni-heidelberg.de>
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

 

>If the network cards and switch allow it, you could try first using 
>Jumbo (9k) Ethernet frames; in such a setup, the 8k NFS packets would 
>most likely travel unfragmented between server and clients.

While most of 90% of the hardware supports it, I have some legacy hardware
(nodes and switch) still running at 100Mbit connected to the stack of 3750.

Thanks - Didier.



-------------------------------------------------------
This SF.Net email is sponsored by: IBM Linux Tutorials
Free Linux tutorial presented by Daniel Robbins, President and CEO of
GenToo technologies. Learn everything from fundamentals to system
administration.http://ads.osdn.com/?ad_id=1470&alloc_id=3638&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
