From: Olaf Kirch <okir@suse.de>
Subject: Timeouts and congestion windows
Date: Fri, 19 Sep 2003 10:33:20 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20030919083320.GP24464@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1A0Ghh-0002Re-00
	for <nfs@lists.sourceforge.net>; Fri, 19 Sep 2003 01:33:25 -0700
Received: from ns.suse.de ([195.135.220.2] helo=Cantor.suse.de)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.22)
	id 1A0Ghg-0005wj-Ej
	for nfs@lists.sourceforge.net; Fri, 19 Sep 2003 01:33:24 -0700
Received: from Hermes.suse.de (Hermes.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by Cantor.suse.de (Postfix) with ESMTP id BD92B16279F3
	for <nfs@lists.sourceforge.net>; Fri, 19 Sep 2003 10:33:20 +0200 (CEST)
To: nfs@lists.sourceforge.net
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

Hi,

I recently had to debug a problem where NFS installs of a new box
would stall after copying a couple of RPMs, with lots of "NFS
server not respondig/server OK" messages in the syslog.

The kernel I was looking at was 2.4.21 plus the NFS patches from 2.4.22.
The NFS server is a reasonably sized machine, and serves the entire R&D
department as install server.

It turned out the problem was in the RTT estimating code. As long as
everything was fine, the READs were being served promptly, with RTT times
of 1 ms or less. So the RTT estimator for READ would return a timeout
value of .101 seconds (the client kernel used HZ=1000).

Then a spike in the server and/or network load would send the round-trip
times to much higher values (.5 seconds and more) and I would see
things like

	transmit request
	retransmit request
	retransmit request
	retransmit request
	retransmit request
	retransmit request
	receive response
	receive response
	receive response
	receive response
	receive response

In several cases, the response was even ignored because it was received
inbetween the xprt_timer timing out the request, and rpciod waking
up and retransmitting it (could this be fixed by making xprt_complete_rqst
clear task->tk_status? I didn't really look into this part of the problem).

Obviously, this increases the network load even more. But the really bad
thing is that because the request was retransmitted, the RTT estimate
wasn't updated, so it kept predicting these .101 sec timeouts, and it
didn't get out of that trap until the server load went down.

I fixed this rather crudely by always updating the RTT estimate with
nretrans * rtt. A better approach would be to use the time delta between
the first transmit and the receipt of a response.

Then I noticed a second problem, which was that the congestion window
would oscillate quite wildly. It would go up to say 2000 or 3000 within
10-20 seconds, and than collapse down to 256 again. The problem
here, I believe, is two-fold. One is that if you have a spike in network
load, and lose say 5 packets, you get 5 timeouts and the cwnd is shrunk
by a factor 2^5. The second is that the window is going up too quickly
(but that's more of a gut feeling).

Printing the cwnd would give sort of a saw-tooth curve, and, what's
worse, doing that on two clients would show these saw-tooths were almost
synchronized.

I addressed that by making sure that once you update the cwnd, you're
not allowed to touch it for a certain time (0.5 sec when increasing the
cwnd, 1 sec when decreasing it) This smoothed out the curve quite a bit.
It also reacts fairly well to spikes in the network load - rather than
dropping all the way down to 256, it now goes back to half the value,
and stays there.

A third modification I made was to not print "server not responding"
messages for async RPC tasks :)

Olaf
-- 
Olaf Kirch     |  Anyone who has had to work with X.509 has probably
okir@suse.de   |  experienced what can best be described as
---------------+  ISO water torture. -- Peter Gutmann


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
