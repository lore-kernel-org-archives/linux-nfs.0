From: Andrei Maslennikov <andrei@caspur.it>
Subject: NFS performance issue - P3 vs P4
Date: Fri, 11 Oct 2002 19:43:43 +0000 (   )
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.3.95a.1021011121800.12919A-100000@kiwi.caspur.it>
Reply-To: Andrei Maslennikov <andrei@caspur.it>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from kiwi.caspur.it ([193.204.5.49])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 1805hL-0003nk-00
	for <nfs@lists.sourceforge.net>; Fri, 11 Oct 2002 12:43:47 -0700
Received: from localhost (andrei@localhost)
	by kiwi.caspur.it (8.11.6/8.11.6) with SMTP id g9BJhiP17248
	for <nfs@lists.sourceforge.net>; Fri, 11 Oct 2002 21:43:44 +0200
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
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>


We've ran into a funny problem with NFS performance and 
since a couple of days are trying to overcome it. We 
will be digging further in, but maybe somebody could give
us a valid advice..

     
               NetApp F760 (NFS server 1)

             /       |         |          \   
            /        |         |           \
        18 MB/s    18 MB/s    18 MB/s      18 MB/s 
           |         |         |            |
           |         |         |            |
Clients>> P3        P4       ALPHA         IBM
           |         |         |            |
           |         |         |            |
         34 MB/s   2 MB/s   22 MB/s      22 MB/s   
            \        |         |           /
             \       |         |          /
                      
            Linux NFS Server on P3 (server 2)


As you may see here, we are looking at the performance of two
different NFS servers. One is a 3-year old commercial NAS system
(Network Appliance Filer F760), another is a P3 machine
(biprocessor Pentium III at 1 Ghz).

Then, we have 4 NFS clients (one ALPHA quadriprocessor at 600
Mhz, one IBM quadriprocessor at 375 Mhz, one P3 biprocessor
at 1 Ghz and one P4 biprocessor at 2 Ghz). Alpha client is
running Tru 64 5.1, IBM client - AIX 5.1D. All Pentiums
including the P3 server run exactly the same version of OS:
Red Hat Linux 7.3 with all the recent patches. On clients, we
use RH kernel 2.4.18-10smp. And on server - 2.4.18 from
kernel.org + Alan Cox patch 3 + EVMS suport patches for
volume handling and snapshotting. 

All machines are sitting on the same switched non-blocking
Gigabit network. 

What we observe, is *very* strange. NetApp is uniformly
delivering 18 MB/sec write speed to all 4 different clients.
P3 server does visibly better for ALPHA, IBM and P3 clients
(in case of P3 client, we observe almost a factor of two in
performance, 34 MB/s compared with the 18 MB/sec of NetApp). 
However, when the same P3 server is used from P4 client, we 
see an enormous drop in performance. We can write basically 
only at 2 MB/s! 

We first suspected the network was responsible for this
behaviour. In fact, the retrans rate on P4 as seen with 
"nfsstat -r" between P4 client and P3 server was ridicolously 
high. However, when we checked the P3srv-P4cli link with ttcp, 
we have seen a perfect speed of memory-to-memory transfer of
more than 100 MB/s (both udp and tcp). Ftp disk-to-disk between
these two machines runs at more than 30 MB/s, exactly as one 
would expect. Server runs with 64 nfsd's, and we played a lot 
with timeo, rsize and wsize, nfsvers etc to arrive at most to 
5 MB/s. Never we got more than that.. 
 
At this point, we have checked the cables: used on
P4 client the cable that was connecting before the
extra-performant P3 client. Exactly the same behaviour. We
then added another Gigabit card of different make to the P4
client - same lousy performance. We then jumped to yet
another P4 machine with exactly the same hw and sw
configuration, and obtained the same identical result...

The worst point about it all is the fact that the same P4 client
nicely operates at 18 MB/s when NetApp is used. If this would be
a P4 client issue, than its performance should be equally bad for
both P3 and NetApp servers. And if it would be a P3 server issue,
then why the latter is able to deliver a good performance to 
ALPHA, IBM and P3 clients? And this is definitively *not* a 
hardware problem, as we are able to reproduce this behaviour on
another equivalent hardware.

What else we could look at? If anybody has any idea, please let
us know.

   
Thanks ahead - Andrei.




-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
