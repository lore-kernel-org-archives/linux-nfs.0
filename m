From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: Unknown error 525 from getdents from a connection to
	an AIX nfs server
Date: Tue, 21 Jun 2005 16:04:50 -0400
Message-ID: <1119384290.10648.21.camel@lade.trondhjem.org>
References: <200506041341.11421.bartoschek@or.uni-bonn.de>
	 <200506211433.18308.bartoschek@or.uni-bonn.de>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DkozZ-0001tH-W2
	for nfs@lists.sourceforge.net; Tue, 21 Jun 2005 13:05:05 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DkozY-0002ea-E6
	for nfs@lists.sourceforge.net; Tue, 21 Jun 2005 13:05:05 -0700
To: Christoph Bartoschek <bartoschek@or.uni-bonn.de>
In-Reply-To: <200506211433.18308.bartoschek@or.uni-bonn.de>
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

ty den 21.06.2005 Klokka 14:33 (+0200) skreiv Christoph Bartoschek:
> Hi,
> 
> we have updated our NFS Server to AIX 5.2. Now the problems occur only on the 
> clients with 64bit processors.  Clients on 32bit machines run fine. (However, 
> maybe I made some mistakes when I checked the 32bit machines for the last 
> post).

Remind me please. Is this error appearing on the wire? i.e. do you see a
readdir request coming across and an error being returned when you use
tcpdump?

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
