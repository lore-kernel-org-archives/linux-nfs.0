From: Andrew Theurer <habanero@us.ibm.com>
Subject: Re: more SMP issues
Date: Wed, 27 Mar 2002 10:37:41 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <200203271649.KAA37894@popmail.austin.ibm.com>
References: <200203261934.NAA25602@popmail.austin.ibm.com> <15521.13735.293466.799706@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net
Received: from mg03.austin.ibm.com ([192.35.232.20])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16qGcb-0008Ri-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Mar 2002 08:50:01 -0800
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <15521.13735.293466.799706@notabene.cse.unsw.edu.au>
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

> Its very odd.
>
> I'm doing some testing on 2.4.18 plus my patches, using UDP, and I'm
> definately getting more than 12 threads being used at times.  But this
> is a mixed load, not a read-only load.
>
> Could you
>
>  echo 256 > /proc/sys/sunrpc/rpc_debug ; sleep 5 ; echo 0 > 
> /proc/sys/sunrpc/rpc_debug
>
> while the udp reading is happening and see if lines mentioning
>    "no space"
> appear in the log.  That is about the only thing that I can think of.

Here is udp:

Mar 27 08:15:52 sambaperf kernel: svc: socket f6ec17c0 served by daemon 
f4cd8e00
Mar 27 08:15:52 sambaperf kernel: svc: got len=132
Mar 27 08:15:52 sambaperf kernel: svc: socket f6ec17c0 busy, not enqueued
Mar 27 08:15:52 sambaperf kernel: svc: socket f50fcda0(inet f6ec17c0), 
write_space busy=1
Mar 27 08:15:52 sambaperf kernel: svc: socket f6ec17c0 busy, not enqueued
Mar 27 08:15:52 sambaperf kernel: svc: socket f50fcda0(inet f6ec17c0), 
count=140, busy=1
Mar 27 08:15:52 sambaperf kernel: svc: socket f6ec17c0 busy, not enqueued
Mar 27 08:15:52 sambaperf kernel: svc: socket f6ec17c0 busy, not enqueued
Mar 27 08:15:52 sambaperf kernel: svc: service f4cf0a00, releasing skb 
f4909340
Mar 27 08:15:52 sambaperf kernel: svc: socket f50fcda0 sendto([f4cd4000 
8320... ], 1, 8320) = 8320

I also took one for tcp just to compare:

Mar 27 08:20:28 sambaperf kernel: svc: socket f4988cc0 busy, not enqueued
Mar 27 08:20:28 sambaperf kernel: svc: socket f4a0a360 busy, not enqueued
Mar 27 08:20:28 sambaperf kernel: svc: socket f714c360 sendto([f4e04000 
8324... ], 1, 8324) = 8324
Mar 27 08:20:28 sambaperf kernel: svc: socket f4a0a360 busy, not enqueued
Mar 27 08:20:28 sambaperf kernel: svc: server f436e600 waiting for data (to = 
30000)
Mar 27 08:20:28 sambaperf kernel: svc: socket f43159a0 busy, not enqueued
Mar 27 08:20:28 sambaperf kernel: svc: server f439b800 waiting for data (to = 
30000)
Mar 27 08:20:28 sambaperf kernel: svc: socket f4325040 TCP data ready (svsk 
f446e120)
Mar 27 08:20:28 sambaperf kernel: svc: socket f4325040 busy, not enqueued
Mar 27 08:20:29 sambaperf kernel: svc: server f502d400, socket f714c360, 
inuse=1

I also setup another debug, where I prinkt'd at all the SK bit set and 
clears, and a couple other areas.  In this test, I only sent one read request 
from one client:

pid: 0 svc: socket f5b97e40(inet f4f29960), count=140, SK_BUSY=0<6> and 
setting SK_DATA in svc_udp_data_ready
pid: 0 testing SK_BUSY in svc_sock_enqueue
pid: 0 setting SK_BUSY in svc_sock_enqueue
pid: 1390 clearing SK_DATA in svc_udp_recvfrom
pid: 1390 setting SK_DATA in svc_udp_recvfrom
pid: 1390 clearing SK_BUSY in svc_sock_received
pid: 1390 testing SK_BUSY in svc_sock_enqueue
pid: 1390 setting SK_BUSY in svc_sock_enqueue
pid: 1390 calling svc_process
pid: 1390 testing SK_BUSY in svc_sock_enqueue
pid: 1390 testing SK_BUSY in svc_sock_enqueue
pid: 1387 clearing SK_DATA in svc_udp_recvfrom
pid: 1387 clearing SK_BUSY in svc_sock_received
svc: socket f5b97e40(inet f4f29960), write_space SK_BUSY=0 in svc_write_space
svc: socket f5b97e40(inet f4f29960), write_space SK_BUSY=0 in svc_write_space
svc: socket f5b97e40(inet f4f29960), write_space SK_BUSY=0 in svc_write_space

My only concern was that SK_BUSY was set, then svc_process() is called.  I 
thought SK_BUSY should not be set during svc_process(). 

> The fact that you seem to get more threads if you only ask for 2 is
> really odd....

Yes, that really shocked me.  I tried it several times.  I tried 1 to 8 
threads, and all but 2 had nfsd_busy of 1, 2 threads had nsfd_busy of 2 most 
of the time, and throughput was up.  

I am going to setup SpecSFS for a comparison, but IMO I like this test 
because it runs so quickly and exposes a potential problem.

Thanks for your help,

-Andrew

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
