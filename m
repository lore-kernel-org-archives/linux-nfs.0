From: Joshua Baker-LePain <jlb17@duke.edu>
Subject: Re: Error 512
Date: Thu, 15 Dec 2005 15:58:15 -0500 (EST)
Message-ID: <Pine.LNX.4.62.0512151547200.5180@chaos.egr.duke.edu>
References: <Pine.LNX.4.62.0512141521150.5180@chaos.egr.duke.edu>
 <1134601986.13707.12.camel@lade.trondhjem.org>
 <Pine.LNX.4.62.0512142052290.6445@chaos.egr.duke.edu>
 <1134612343.13707.20.camel@lade.trondhjem.org>
 <Pine.LNX.4.62.0512151405060.5180@chaos.egr.duke.edu>
 <1134675422.7956.12.camel@lade.trondhjem.org>  <Pine.LNX.4.62.0512151439420.5180@chaos.egr.duke.edu>
  <1134677100.7956.19.camel@lade.trondhjem.org>
 <Pine.LNX.4.62.0512151521140.5180@chaos.egr.duke.edu>
 <1134679156.7956.26.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1En0BF-0006dh-AE
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 12:58:25 -0800
Received: from chaos.egr.duke.edu ([152.3.195.82])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1En0BE-0001vi-5c
	for nfs@lists.sourceforge.net; Thu, 15 Dec 2005 12:58:25 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1134679156.7956.26.camel@lade.trondhjem.org>
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

On Thu, 15 Dec 2005 at 3:39pm, Trond Myklebust wrote

> On Thu, 2005-12-15 at 15:22 -0500, Joshua Baker-LePain wrote:
>>> What versions of Linux are you running on these machines?
>>
>> Everything is fully up-to-date centos-4 (kernel 2.6.9-22.0.1.ELsmp).
>
> As far as I can see, the problem is that every time the server responds
> to the client's request for a connection, the client fails to ACK that
> response. Unless something is really broken deep down in the TCP layer,
> then the most likely explanation is a firewall setup that is blocking
> that traffic.
>
> Any IPtable/firewall enabled that might prevent the TCP 3-way handshake
> from completing? Or any weird filtering at the switch?

I think -- I'm hopeful -- that you just nailed it.  At least, I disabled 
iptables on the client, and the mounts all came back shortly thereafter.

For several OS revisions, I've used a rule like the following on all 
client machines:

-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

In retrospect, it's only recently, in moving towards NFS over TCP, that 
I've begun having this randomly-hanging-mounts problem.  I'm thinking 
it's possible that that rule was timing out.  I'll add rules to all 
clients explicitly allowing traffic from the servers (the servers already 
have such rules), and hopefully this'll be the last you here from on this 
topic.  I *really* appreciate all your help in tracking this down.

-- 
Joshua Baker-LePain
Department of Biomedical Engineering
Duke University


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
