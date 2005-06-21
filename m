From: Christoph Bartoschek <bartoschek@or.uni-bonn.de>
Subject: Re: Unknown error 525 from getdents from a connection to an AIX nfs server
Date: Tue, 21 Jun 2005 14:33:18 +0200
Message-ID: <200506211433.18308.bartoschek@or.uni-bonn.de>
References: <200506041341.11421.bartoschek@or.uni-bonn.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DkolG-0000t8-5n
	for nfs@lists.sourceforge.net; Tue, 21 Jun 2005 12:50:18 -0700
Received: from externalmx-1.sourceforge.net ([12.152.184.25])
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Dknu4-0002Qp-PG
	for nfs@lists.sourceforge.net; Tue, 21 Jun 2005 11:55:21 -0700
Received: from [131.220.141.99] (helo=brical.or.uni-bonn.de)
	by externalmx-1.sourceforge.net with esmtp (Exim 4.41)
	id 1DkiNC-0002zg-PB
	for nfs@lists.sourceforge.net; Tue, 21 Jun 2005 06:01:05 -0700
Received: from wse04.or.uni-bonn.de (unknown [131.220.141.100])
	by brical.or.uni-bonn.de (Postfix) with ESMTP id 678D6AC02
	for <nfs@lists.sourceforge.net>; Tue, 21 Jun 2005 14:42:29 +0200 (CEST)
Received: from certa.vlsi.uni-bonn.de (certa-en0.vlsi.uni-bonn.de [192.168.143.187])
	by wse04.or.uni-bonn.de (Postfix) with ESMTP id 24EA9E95C
	for <nfs@lists.sourceforge.net>; Tue, 21 Jun 2005 14:29:37 +0200 (CEST)
To: nfs@lists.sourceforge.net
In-Reply-To: <200506041341.11421.bartoschek@or.uni-bonn.de>
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

we have updated our NFS Server to AIX 5.2. Now the problems occur only on the 
clients with 64bit processors.  Clients on 32bit machines run fine. (However, 
maybe I made some mistakes when I checked the 32bit machines for the last 
post).

Are there any issues known for the 64bit Version of the NFS Client?

Christoph Bartoschek


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
