From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] resend: knfsd multiple UDP sockets
Date: Fri, 28 May 2004 17:42:32 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040528074232.GC9014@sgi.com>
References: <20040528042007.GA9014@sgi.com> <16566.51874.43089.537506@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BTc0o-00046x-8e
	for nfs@lists.sourceforge.net; Fri, 28 May 2004 00:42:42 -0700
Received: from mtvcafw.sgi.com ([192.48.171.6] helo=omx3.sgi.com)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BTc0n-0002NG-OO
	for nfs@lists.sourceforge.net; Fri, 28 May 2004 00:42:41 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16566.51874.43089.537506@cse.unsw.edu.au>
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

On Fri, May 28, 2004 at 03:14:10PM +1000, Neil Brown wrote:
> I have two concerns, that can possibly be allayed.
> 
> Firstly, the reply to any request is going to go out the socket that
> the request came in on.  However some network configurations can have
> requests arrive on one interface that need to be replied to on a
> different interface(*).  Does setting sk_bound_dev_if cause packets sent
> go out that interface (I'm not familiar enough with the networking
> code to be sure)?  If it does, then this will cause problems in those
> network configurations.

As near as I can tell from inspecting the (amazingly convoluted)
routing code and without running a test, the output routing algorithm
is short circuited when the socket is bound to a device, and will
send the packet out the bound interface regardless.  This comment
by Alexei K in ip_route_output_slow() explains:

> [...] When [output interface] is specified, routing
> tables are looked up with only one purpose:
> to catch if destination is gatewayed, rather than
> direct. 

So, yes we could have a problem if the routing is asymmetric.

A similar issue (which I haven't tested either) is what happens
with virtual interfaces like tunnels or bonding.

> Secondly, while the need for multiple udp sockets is clear,

Agreed.

> it isn't
> clear that they should be per-device.
> Other options are per-CPU and per-thread.  Alternately there could
> simply be a pool of free sockets (or a per-cpu pool).

Ok, there are a number of separate issue here.

Firstly, my performance numbers show that the current serialisation of
svc_sendto() gives about 1.5 NICs worth of performance per socket, so
whatever method governs the number of sockets it needs to ensure that
the number of sockets grows at least as fast as the number of NICs.
On at least some of the SGI hardware the number of NICs can grow
faster than the number of CPUs.  For example, the minimal Altix
3000 has 4 CPUs and can have 10 NICs.  Similarly, a good block for
building scalable NFS servers is an Altix 350 with 2 CPUs and 4 NICs
(we can't do this yet due to tg3 driver limitations).  So this makes
per-CPU sockets unattractive.

Secondly, for the traffic levels I'm trying to reach I need lots of
nfsd threads.  I haven't done the testing to find the exact number,
but it's somewhere between above 32.  I run with 128 threads to make
sure.  If we had per-thread sockets that would be a *lot* of sockets.
Under many loads an nfsd thread spends most of its time waiting for
disk IO, and having its own socket would just be wasteful.

Thirdly, where there are enough CPUs I see significant performance
advantage when each NIC directs irqs to a separate dedicated CPU.
In this case having one socket per NIC will mean all the cachelines
for that socket will tend to stay on the interrupt CPU (currently this
doesn't happen because of the way the tg3 driver handles interrupts,
but that will change).

What all of the above means is that I think having one socket per
NIC is very close to the right scaling ratio.

What I'm not sure about on is the precise way in which multiple
sockets should be achieved.  Using device-bound sockets just seemed
like a really easy way (read: no changes to the network stack) to get
exactly the right scaling.  Having a global (or per NUMA node, say)
pool of sockets which scaled by the number of NICs would be fine too,
assuming it could be made to work and handle the routing corner cases.

> Having multiple sockets that are not bound differently is not
> currently possible without setting sk_reuse, and doing this allows
> user programs to steal NFS requests.

Yes, this was another good thing about using device-bound sockets,
it doesn't open that security hole.

> However if we could create a socket that was bound to an address only
> for sending and not for receiving, we could use a pool of such sockets
> for sending.

Interesting idea.  Alternatively, we could use the single UDP socket
for receive as now, and a pool of connected UDP sockets for sending.
That should work without needing to modify the network stack.

> This might be as easy as adding a "sk_norecv" field to struct sock,
> and skipping the sk->sk_prot->get_port call in inet_bind if it is set.
> Then all incoming requests would arrive on the one udp socket (there
> is very little contention between incoming packets on the one socket),

Sure, the limit is the send path.

> and reply could go out one of the sk_norecv ports.

Aha.

> Does this make sense?  Would you be willing to try it?

I think it's an intriguing idea and I'll try it as soon as I can.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
I don't speak for SGI.


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
