From: Bogdan Costescu <bogdan.costescu@iwr.uni-heidelberg.de>
Subject: Re: nfs performance: read only/gigE/nolock/1Tb per day
Date: Tue, 23 Apr 2002 17:14:31 +0200 (CEST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0204231502320.31993-100000@kenzo.iwr.uni-heidelberg.de>
References: <shsu1q2d7h4.fsf@charged.uio.no>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: nfs@lists.sourceforge.net, "Lever, Charles" <Charles.Lever@netapp.com>,
   "'jason andrade'" <jason@dstc.edu.au>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.iwr.uni-heidelberg.de ([129.206.104.30])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 170209-0001jJ-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Apr 2002 08:14:41 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <shsu1q2d7h4.fsf@charged.uio.no>
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>

On 23 Apr 2002, Trond Myklebust wrote:

> So what would an avalanche of ICMP Time Exceeded messages usually
> indicate as far as the driver/card is concerned?

Many and nothing 8-) As you say, this message is issued when the datagram 
couldn't be reassembled. There can be many low-level (driver/card/switch) 
causes why a packet doesn't make it in time to the destination, these are 
those that I can think of:

1. the server can't send the packet
  1.1 it's slower in producing packets than the NIC can handle -> Tx underrun
	usually associated with bus (PCI) problems.
  1.2 it produces too many packets (usually small ones and for datagram 
	protocols) and the NIC can't send them as fast -> Tx queue full, 
	in extreme cases (5 seconds in most drivers in 2.4 kernels) a Tx 
	timeout occurs.
  1.3 (actually could be included in the previous one) the NIC can't send 
	packets because of network congestion, usually happens on 
	half-duplex links (and mostly with hubs) because of collisions -> 
	Tx queue full, then maybe Tx timeout. Some cards/drivers can
	continue to try sending the packet indefinitely, some can just 
	drop the packet, some stall the tramission path after some number 
	of collisions and resetting it can take some time.
  1.4 link speed mismatch between NIC and hub/switch -> packets are 
	randomly dropped, there are frame errors, etc.
  1.5 the server has interrupt problems (APIC errors) and Tx interrupts 
	can be missed, such that the Tx queue is not emptied in time 
	(with interrupt mitigation)-> Tx timeout.
2. the hub/switch doesn't send the packet
  2.1 dual speed hub/switches have to buffer the packet(s) coming from 
	the fast ports and send them with lower speeds; in some cases this 
	buffer can be filled and packets are dropped.
  2.2 switches that have to deal with oversized (Jumbo) frames and split 
	them in normal (max. 1500 bytes payload) packets. Depending on how 
	well the splitting is handled (usually directly proportional 
	with how much the switch costs), packets can be dropped.
  2.3 switches under broadcast storms act just like hubs, packets can be 
	dropped.
3. the client can't receive the packet
  3.1 the client is too loaded or there are bus (PCI) problems and 
	the CPU cannot process packets as fast as they arrive -> Rx 
	overruns. As soon as the Rx ring is full, packets are dropped by 
	the NIC. If this happens only occasionaly, a larger Rx ring helps 
	taking the peaks.
  3.2 the client has interrupt problems (APIC errors) and it uses 
	Rx interrupt mitigation, such that a missed interrupt doesn't 
	start the processing of the packets. It's less likely than the Tx 
	interrupt mitigation case, because there is usually also a timer 
	based interrupt (in 2.4 only hardware support, in 2.5 also 
	software support from NAPI).
  3.3 the client has interrupt problems which manifest as some device 
	(other than the NIC) keeping interrupts disabled for too long (IDE 
	is one such example). The NIC generates the interrupt, but the 
	driver receives it with delay, such that the Rx ring can be 
	already full and Rx overruns occur. This situation is usually 
	associated with the "Too much work in interrupt" message, as the 
	driver has to process the Rx ring plus maybe some Tx interrupts, 
	media related interrupts, statistics interrupts, etc. (although 
	usually the Rx processing produces the highest number of loops, 
	that's why I included it here and not on the server/Tx side).
  3.4 link speed mismatch between NIC and hub/switch (see 1.4)
4. different fragments take different times to travel
  4.1 a router/switch with higher layer processing somewhere in the middle 
	might delay/drop packets
  4.2 even for computers connected to the same switch, it might happen 
	with channel bonding

Of course, the roles of server and client are here depicted only as 
transmitter and receiver respectively. In a bidirectional protocol, the 
roles alternate.

Again I have to state the obvious: the above situations can happen alone 
or associated. When they are associated it's much harder to cure all of 
them, as some people say plainly "it just doesn't work" or give up too 
soon in solving them (f.e. "I fixed the link speed autonegotiation 
problem, but I still get dropped packets" which can be related to some 
congestion).

> In the avalanching case that I've sometimes observed, then it looks as
> if *no* datagrams are getting rebuilt.

How big are the datagrams compared with the MTU ? With 32K datagrams over 
Ethernet, you're talking about roughly a full Rx ring worth of packets (32 
is common for the Rx ring size)...

> IOW: the client is just sitting there sending off ICMP messages, and
> never reading the reply.

Does the other side sees these messages ? If so, are there any response 
messages sent out (but which don't make it back to the client) ?

> Changing card/driver did not help in the
> cases I observed, but shutting down the network, and then bringing it
> up again sometimes did. Any suggestions?

Down/up was on the sending or receiving/reassembling side ?
Shutting down an interface should clear all buffers/queues associated with 
it, so a restart gets a "clean" state. For reassembling, it probably 
means droping all incomplete datagrams, but I'm not 100% sure, it may get 
more complicated when packets can take different ways between sender and 
receiver.

-- 
Bogdan Costescu

IWR - Interdisziplinaeres Zentrum fuer Wissenschaftliches Rechnen
Universitaet Heidelberg, INF 368, D-69120 Heidelberg, GERMANY
Telephone: +49 6221 54 8869, Telefax: +49 6221 54 8868
E-mail: Bogdan.Costescu@IWR.Uni-Heidelberg.De






_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
