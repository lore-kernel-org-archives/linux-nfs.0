From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH][RFC] Multiple UDP sockets for knfsd
Date: Sun, 16 May 2004 23:56:44 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040516135644.GB24784@sgi.com>
References: <40A42DB8.7B9C8152@melbourne.sgi.com> <1084566110.4237.66.camel@lade.trondhjem.org> <20040515063854.GB14983@sgi.com> <1084641723.3490.13.camel@lade.trondhjem.org> <16550.39071.745015.438121@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
        Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPM8X-0000ya-6P
	for nfs@lists.sourceforge.net; Sun, 16 May 2004 06:57:05 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx3.sgi.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.30)
	id 1BPM8V-0003a0-Fb
	for nfs@lists.sourceforge.net; Sun, 16 May 2004 06:57:03 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16550.39071.745015.438121@cse.unsw.edu.au>
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




On Sun, May 16, 2004 at 08:24:31AM +1000, Neil Brown wrote:
> On Saturday May 15, trond.myklebust@fys.uio.no wrote:
> > So what exactly *is* this bottleneck? As far as we're concerned, a
> > socket is basically just a buffer and a couple of locks.
> 
> It is almost certainly svsk->sk_sem.  We hold this while calling
> sock->ops->sendpage  on each individual page of the reply - we don't
> want them mixed up with some other reply.

Yes, svsk->sk_sem is the culprit.

The test is not CPU limited, so the limit is probably a sleeping lock.
Profiling by context switch shows (butterfly edited to reduce clutter):

-----------------------------------------------
...
                0.00 15369.48   15362/55422       schedule_timeout [14]
                0.00 16902.23   16894/55422       _down [12]
                0.00 22457.94   22447/55422       cpu_idle [9]
[5]    100.0    0.00 55449.00   55422         schedule [5]
...
-----------------------------------------------
...
                0.00 16901.23   16893/16894       svc_send [13]
[12]    30.5    0.00 16902.23   16894         _down [12] (actually __down)
                0.00 16902.23   16894/55422       schedule [5]
...
-----------------------------------------------
...
                0.00 15204.40   15197/15362       svc_recv [15]
[14]    27.7    0.00 15369.48   15362         schedule_timeout [14]
                0.00 15369.48   15362/55422       schedule [5]
...
-----------------------------------------------
                0.00 16901.23   16891/16891       svc_process [11]
[13]    30.5    0.00 16901.23   16891         svc_send [13]
                0.00 16901.23   16893/16894       _down [12]
-----------------------------------------------
                0.00 16983.27   16972/16972       nfsd [8]
[11]    30.6    0.00 16983.27   16972         svc_process [11]
                0.00 16901.23   16891/16891       svc_send [13]
                0.00   82.04      81/81          nfsd_dispatch [35]
-----------------------------------------------

This shows that

*  40.5% of context switches are from CPUs going out of the idle
   loop (presumably because an nfsd has become runnable).
*  27.4% of context switches are from nfsd's going idle in svc_recv()
*  30.5% of context switches are from nfsd's calling _down() in
   svc_send() which sending replies.  There's only one call to
   __down() in svc_send, from the down() inline:

int
svc_send(struct svc_rqst *rqstp)
{
        struct svc_sock *svsk;
        int             len;
        struct xdr_buf  *xb;
[...]
        /* Grab svsk->sk_sem to serialize outgoing data. */
        down(&svsk->sk_sem);          <----------
        if (test_bit(SK_DEAD, &svsk->sk_flags))
                len = -ENOTCONN;
        else
                len = svsk->sk_sendto(rqstp);
        up(&svsk->sk_sem);
        svc_sock_release(rqstp);
[...]
}

> Remember that the test here involves lots of large READ requests.
> Each will have a few pages (this is an ia64 with large pages, so there
> will probably be only one or two pages or page-fragments of data) what
> will need to be fragmented into multiple UDP packets.

Other profiling and tracing code has shown the following behaviour.
The READs are 32K, with IRIX clients which align their requests to
32K so these comprise exactly 2 x 16K pages.  MTU is standard 1500
so each READ reply is fragmented into 23 frames, which is seen by
the driver as non-linear skbs with headers and 1 or 2 page-frags.
In total each READ reply takes 21*2+2*3 = 48 send ring descriptors,
of the 512 available in the NIC.  The send rate is sufficiently
low that the send ring never gets close to filling, so sent packets
are never queued in software and each call to svc_udp_sendto() runs
through the IP fragmentation code, allocates 23 small skbs, and drops
straight down into the driver to fill in send ring descriptors.

So almost the entire send path is serialised on svsk->sk_sem, which
is why we need more than one UDP socket.

> On Saturday May 15, trond.myklebust@fys.uio.no wrote:
> IOW, are you seeing actual lock contention here, or could we just obtain
> the same effect by bumping the send or receive buffer size on the
> existing UDP socket?

Bumping up the socket send and receive spaces has negligible effect.
I tested this by tweaking svcsock.c to add a rational multiplier into
the code which sets the spaces, and ran a 32K UDP READ test (3 gige
NICs, 6 clients, 128 nfsd's, single UDP socket).  These numbers are
the average of 5 runs:

mult	  space		throughput
         (bytes)	(MB/s)
----	--------	-----
1/8	  553344	147.2
1/4	 1106688 	145.0
1/2	 2213376 	145.0
1	 4426752 	140.1  <---- default case
2	 8853504 	141.1
4	17707008	140.7
8	35414016	141.4

Note that by using 128 threads I've already pushed the socket spaces
beyond the point of diminishing returns with a single UDP socket.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: SourceForge.net Broadband
Sign-up now for SourceForge Broadband and get the fastest
6.0/768 connection for only $19.95/mo for the first 3 months!
http://ads.osdn.com/?ad_id=2562&alloc_id=6184&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
