From: Neil Brown <neilb@cse.unsw.edu.au>
Subject: Re: more SMP issues
Date: Thu, 28 Mar 2002 15:05:42 +1100 (EST)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15522.38550.557032.473224@notabene.cse.unsw.edu.au>
References: <200203261934.NAA25602@popmail.austin.ibm.com>
	<15521.13735.293466.799706@notabene.cse.unsw.edu.au>
	<200203271649.KAA37894@popmail.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16qR8G-0007wM-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Mar 2002 20:03:24 -0800
Received: From notabene ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <habanero@us.ibm.com>) (for <nfs@lists.sourceforge.net>) By tone
	With Smtp ; Thu, 28 Mar 2002 15:03:10 +1100
To: Andrew Theurer <habanero@us.ibm.com>
In-Reply-To: message from Andrew Theurer on Wednesday March 27
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

On Wednesday March 27, habanero@us.ibm.com wrote:
> 
> Here is udp:
> 
> Mar 27 08:15:52 sambaperf kernel: svc: socket f6ec17c0 served by daemon 
> f4cd8e00
> Mar 27 08:15:52 sambaperf kernel: svc: got len=132
....
> 
> I also took one for tcp just to compare:
> 
> Mar 27 08:20:28 sambaperf kernel: svc: socket f4988cc0 busy, not enqueued
> Mar 27 08:20:28 sambaperf kernel: svc: socket f4a0a360 busy, not enqueued
> Mar 27 08:20:28 sambaperf kernel: svc: socket f714c360 sendto([f4e04000 
> 8324... ], 1, 8324) = 8324
....

Nothing odd here.... thanks.

> 
> I also setup another debug, where I prinkt'd at all the SK bit set and 
> clears, and a couple other areas.  In this test, I only sent one read request 
> from one client:
> 
> pid: 0 svc: socket f5b97e40(inet f4f29960), count=140, SK_BUSY=0<6> and 
> setting SK_DATA in svc_udp_data_ready
> pid: 0 testing SK_BUSY in svc_sock_enqueue
> pid: 0 setting SK_BUSY in svc_sock_enqueue
> pid: 1390 clearing SK_DATA in svc_udp_recvfrom
> pid: 1390 setting SK_DATA in svc_udp_recvfrom
> pid: 1390 clearing SK_BUSY in svc_sock_received
> pid: 1390 testing SK_BUSY in svc_sock_enqueue
> pid: 1390 setting SK_BUSY in svc_sock_enqueue
> pid: 1390 calling svc_process
> pid: 1390 testing SK_BUSY in svc_sock_enqueue
> pid: 1390 testing SK_BUSY in svc_sock_enqueue
> pid: 1387 clearing SK_DATA in svc_udp_recvfrom
> pid: 1387 clearing SK_BUSY in svc_sock_received
> svc: socket f5b97e40(inet f4f29960), write_space SK_BUSY=0 in svc_write_space
> svc: socket f5b97e40(inet f4f29960), write_space SK_BUSY=0 in svc_write_space
> svc: socket f5b97e40(inet f4f29960), write_space SK_BUSY=0 in svc_write_space
> 
> My only concern was that SK_BUSY was set, then svc_process() is called.  I 
> thought SK_BUSY should not be set during svc_process(). 

No, this is normal.
After taking a request off the socket, the process calls
svc_sock_enqueue incase there is another packet.  The socket gets
attached to some process and marked busy, until that process wakes up
and deals with the next packet.... but that gives me an idea....

> 
> > The fact that you seem to get more threads if you only ask for 2 is
> > really odd....
> 
> Yes, that really shocked me.  I tried it several times.  I tried 1 to 8 
> threads, and all but 2 had nfsd_busy of 1, 2 threads had nsfd_busy of 2 most 
> of the time, and throughput was up.  

Ok, here is a theory.
All your data is in cache, right?
So when NFSD gets a read request, it hurtles along processing it and
never has to block all the way until it is completed.  As this is done
in less than the scheduling interval, it never gets interrupted and no
other nfsd thread gets to run on that CPU until this one has finished
it's request.
This would give you a situation in which you never have more
concurrent nfsd's than you have processors.

But you are getting even worse than that:  You have only one active
thread on a quad processor machine.  I blithely blame this on the
scheduler.
Maybe all the nfsd threads are initially attached to the same
processor, and for some reason they never get migrated to another 
processor.   Is this a question for Ingo Molnar??

Maybe when you only have 2 nfsds, the dynamics are a bit different and
one thread gets migrated and you then get dual processor performance.

Possibly we could put some scheduler call in just after the wake_up()
in svcsock.c which says to go bother some other CPU???

Does that make any sense, or sound plausable?

> 
> I am going to setup SpecSFS for a comparison, but IMO I like this test 
> because it runs so quickly and exposes a potential problem.
> 

That's what I was running.... but I had a bug is another
under-development patch and it locked up chasing a circular list at
about 2000 Ops/Sec (That is an unpublished number. I didn't publish
it. You cannot say that I did).

NeilBrown



_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
