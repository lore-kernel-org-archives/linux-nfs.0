From: "Lever, Charles" <Charles.Lever@netapp.com>
Subject: global kernel lock contention
Date: Thu, 26 Feb 2004 22:14:08 -0800
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <482A3FA0050D21419C269D13989C611302B07B94@lavender-fe.eng.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1AwbIa-0001zB-7j
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 22:16:36 -0800
Received: from mx01.netapp.com ([198.95.226.53])
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1AwbGL-0006p7-PL
	for nfs@lists.sourceforge.net; Thu, 26 Feb 2004 22:14:17 -0800
Received: from hawk.corp.netapp.com (hawk [10.57.156.122])
	by mx01.netapp.com (8.12.10/8.12.10/NTAP-1.4) with ESMTP id i1R6ECJC015232
	for <nfs@lists.sourceforge.net>; Thu, 26 Feb 2004 22:14:12 -0800 (PST)
Received: from svlexc01.hq.netapp.com (svlexc01.corp.netapp.com [10.10.22.171])
	by hawk.corp.netapp.com (8.12.9/8.12.9/NTAP-1.5) with ESMTP id i1R6EBDU012719
	for <nfs@lists.sourceforge.net>; Thu, 26 Feb 2004 22:14:11 -0800 (PST)
To: <nfs@lists.sourceforge.net>
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

we've been wondering how bad the BKL contention problem
is in the Linux NFS/RPC client, so we've done some kernel
execution profiling during a TPC-C benchmark on a 2.5GHz
(four physical, eight logical processors) Linux client
with 8GB of memory.  the database files are stored on
a filer of recent vintage attached via GbE and accessed
over NFS.

the database is using NFS O_DIRECT to access its files,
so the only data copy involved is from the socket layer
into the user's buffer.

three spin locks were hot in our runs -- the BKL, the
xprt->sock_lock, and the rpc_queue_lock.  these were
all in the top 20.  (the BKL is hot even on single
threaded workloads running on dual processor systems,
it turns out).

so i set out to discover why the BKL is so contended.

after playing around with oprofile for a while, i found
that several RPC scheduler functions were fairly hot.
to find out more, i instrumented these with counters to
see how often they were called per RPC request.  i
discovered that rpc_sleep_on, rpc_add_wait_queue,
and rpc_remove_wait_queue are called several times per
RPC request.  but the real surprise is that the
rpc_queue_lock is taken on average between 15 and 18
times per RPC request, independent of request size or
network protocol (udp or tcp).

this particular spin lock also locks out bottom halves.
so when it is released, bottom halves run again.  in
the case of the RPC client, the bottom half appears to
do the data copy from socket buffer to page cache or
to the user's buffer.  this means we're single threading
data copies from our transport sockets, and on heavy NFS
workloads, other processors could be spinning waiting to
do work while one processor is busy copying data.

as a fun experiment, i took the BKL out of the direct I/O
path in the NFS client (professional driver on a closed
course; do not attempt).  i tried an eight thread random
32KB read workload against sparse files on my filer, and got
almost full wire speed (about 95MB/s over GbE, which is
about as fast as my NIC will go; the filer and the client
both had CPU to spare).  i think this is because the data
copies could run concurrently on the client.

so basically we have the same problem in today's RPC client
that the network layer had in early 2.3.

unfortunately if i kicked the thread count up to 16, i was
able to deadlock my client with the random read workload.
we kind of expected this, and i still need to find out what
is causing it.


-------------------------------------------------------
SF.Net is sponsored by: Speed Start Your Linux Apps Now.
Build and deploy apps & Web services for Linux with
a free DVD software kit from IBM. Click Now!
http://ads.osdn.com/?ad_id=1356&alloc_id=3438&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
