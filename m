From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: [PATCH] resend: knfsd multiple UDP sockets
Date: Fri, 28 May 2004 15:14:10 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16566.51874.43089.537506@cse.unsw.edu.au>
References: <20040528042007.GA9014@sgi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux NFS Mailing List <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkX5-0006PK-PM
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:00:43 -0700
Received: from note.orchestra.cse.unsw.edu.au ([129.94.242.24] ident=root)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.30)
	id 1BUkX4-0002ob-R6
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 04:00:43 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.172.124]) (auth-user neilb) (ident-user Debian-exim)
	(for <gnb@sgi.com>) (for <nfs@lists.sourceforge.net>) By note With
	Smtp ; Fri, 28 May 2004 15:14:10 +1000
To: Greg Banks <gnb@sgi.com>
In-Reply-To: message from Greg Banks on Friday May 28
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

On Friday May 28, gnb@sgi.com wrote:
> G'day,
> 
> After poking around with my previously posted patch on various
> workloads and irq configurations, I'm convinced that the fairness
> issues I mentioned earlier are entirely due to interactions between the
> hardware, the tg3 driver, and the Linux network device infrastructure,
> rather than anything intrinsic in the patch.
> 
> Also, I've fixed the locking problem Trond identified.
> 
> So I'm submitting this for real.
> 

Thanks...

It looks good and your performance figures are certainly encouraging.

I have two concerns, that can possibly be allayed.

Firstly, the reply to any request is going to go out the socket that
the request came in on.  However some network configurations can have
requests arrive on one interface that need to be replied to on a
different interface(*).  Does setting sk_bound_dev_if cause packets sent
go out that interface (I'm not familiar enough with the networking
code to be sure)?  If it does, then this will cause problems in those
network configurations.

Secondly, while the need for multiple udp sockets is clear, it isn't
clear that they should be per-device.
Other options are per-CPU and per-thread.  Alternately there could
simply be a pool of free sockets (or a per-cpu pool).

Having multiple sockets that are not bound differently is not
currently possible without setting sk_reuse, and doing this allows
user programs to steal NFS requests.
However if we could create a socket that was bound to an address only
for sending and not for receiving, we could use a pool of such sockets
for sending.
This might be as easy as adding a "sk_norecv" field to struct sock,
and skipping the sk->sk_prot->get_port call in inet_bind if it is set.
Then all incoming requests would arrive on the one udp socket (there
is very little contention between incoming packets on the one socket),
and reply could go out one of the sk_norecv ports.

Does this make sense?  Would you be willing to try it?

NeilBrown

(*) Server S has two interface, A and B, on two subnets.
 Client C has an interface on a third subnet.  All three subnets
 are routed by a single routed R.
 S has a default route out A.
 C sends a request to interface B.  The reply has to go out interface
 A.
 (I have a network like this and had to fight with a glibc bug which
 forced RPC replies out the same interface that the request came
 from).


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
