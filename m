From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Error 512
Date: Thu, 15 Dec 2005 15:39:16 -0500
Message-ID: <1134679156.7956.26.camel@lade.trondhjem.org>
References: <Pine.LNX.4.62.0512141521150.5180@chaos.egr.duke.edu>
	 <1134601986.13707.12.camel@lade.trondhjem.org>
	 <Pine.LNX.4.62.0512142052290.6445@chaos.egr.duke.edu>
	 <1134612343.13707.20.camel@lade.trondhjem.org>
	 <Pine.LNX.4.62.0512151405060.5180@chaos.egr.duke.edu>
	 <1134675422.7956.12.camel@lade.trondhjem.org>
	 <Pine.LNX.4.62.0512151439420.5180@chaos.egr.duke.edu>
	 <1134677100.7956.19.camel@lade.trondhjem.org>
	 <Pine.LNX.4.62.0512151521140.5180@chaos.egr.duke.edu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Emzsz-0005NX-Pl
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 12:39:33 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Emzsy-0000sc-5r
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 12:39:33 -0800
To: Joshua Baker-LePain <jlb17@duke.edu>
In-Reply-To: <Pine.LNX.4.62.0512151521140.5180@chaos.egr.duke.edu>
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

On Thu, 2005-12-15 at 15:22 -0500, Joshua Baker-LePain wrote:
> > What versions of Linux are you running on these machines?
> 
> Everything is fully up-to-date centos-4 (kernel 2.6.9-22.0.1.ELsmp).

As far as I can see, the problem is that every time the server responds
to the client's request for a connection, the client fails to ACK that
response. Unless something is really broken deep down in the TCP layer,
then the most likely explanation is a firewall setup that is blocking
that traffic.

Any IPtable/firewall enabled that might prevent the TCP 3-way handshake
from completing? Or any weird filtering at the switch?

Cheers,
  Trond



-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
