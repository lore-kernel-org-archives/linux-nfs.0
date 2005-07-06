From: mehta kiran <kiranmehta1981@yahoo.com>
Subject: lockd _retries_ to  lock reclaim
Date: Wed, 6 Jul 2005 03:35:43 -0700 (PDT)
Message-ID: <20050706103543.35129.qmail@web51603.mail.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.91] (helo=sc8-sf-mx1-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dq7Fx-000573-V8
	for nfs@lists.sourceforge.net; Wed, 06 Jul 2005 03:35:53 -0700
Received: from web51603.mail.yahoo.com ([206.190.38.208])
	by sc8-sf-mx1-new.sourceforge.net with smtp (Exim 4.44)
	id 1Dq7Ft-0003AB-Ab
	for nfs@lists.sourceforge.net; Wed, 06 Jul 2005 03:35:54 -0700
To: nfs@lists.sourceforge.net
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

Hi ,=20
        I have observed the following on SuSE 9 sp2
        vcslinux25:~ # uname -a
        Linux vcslinux25 2.6.5-7.187-default #1 Tue =20
        Jun 21 14:03:10 UTC 2005 i686 i686 i386=20
        GNU/Linux
     =20

        Server notifies client.
        client tries to reclaim lock.
        But if servers ip goes down due to
        some reason , client gives error
        "failed to reclaim lock".
        Shouldn't lockd retry to reclaim lock.
        On RedHat  , lockd retries while on=20
        SuSE it doesnt.

        It seems that on SuSE 9 sp2 , client
        gets error EIO while on RHEL4 , client gets
        ETIMEDOUT and hence retries
       (Shouldnt rpc call return ETIMEDOUT even on=20
        SuSE?).
      =20

        Which is the correct behavior ?
        Or is the implementation dependent?

        Log messages on SuSE 9 sp2 client

Jun  8 07:43:36 vcslinux25 kernel: statd: NOTIFY     =20
 called
Jun  8 07:43:36 vcslinux25 kernel: lockd:
nlm_host_rebooted("10.212.99.95")
Jun  8 07:43:36 vcslinux25 kernel: lockd: rebind host
10.212.99.95
Jun  8 07:43:36 vcslinux25 kernel: NLM: reclaiming
locks for host 10.212.99.95lockd: get host
10.212.99.95
Jun  8 07:43:36 vcslinux25 kernel: lockd: release host
10.212.99.95
Jun  8 07:43:36 vcslinux25 kernel: svc: service
cc8c7400, releasing skb ccf15a80
Jun  8 07:43:36 vcslinux25 kernel: svc: socket
c7adbd00 sendto([c6162000 24... ], 24) =3D 24 (addr
b63d40a)
Jun  8 07:43:36 vcslinux25 kernel: svc: socket
cd60ba80 busy, not enqueued
Jun  8 07:43:36 vcslinux25 kernel: svc: server
cc8c7400 waiting for data (to =3D 2147483647)
Jun  8 07:43:36 vcslinux25 kernel: svc: socket
cd60ba80 dequeued, inuse=3D0
Jun  8 07:43:36 vcslinux25 kernel: svc: server
cc8c7400, socket c7adbd00, inuse=3D1
Jun  8 07:43:36 vcslinux25 kernel: svc: got len=3D-11
Jun  8 07:43:36 vcslinux25 kernel:
nlmsvc_retry_blocked(00000000, when=3D0)
Jun  8 07:43:36 vcslinux25 kernel: svc: server
cc8c7400 waiting for data (to =3D 2147483647)
Jun  8 07:43:36 vcslinux25 kernel: svc: socket
c7adbd00(inet cd60ba80), write_space busy=3D0
Jun  8 07:43:36 vcslinux25 kernel: lockd: call
procedure 2 on 10.212.99.95
Jun  8 07:43:36 vcslinux25 kernel: lockd:
nlm_bind_host(0ad4635f)
Jun  8 07:43:36 vcslinux25 kernel: RPC:  363 new task
procpid 29813
Jun  8 07:43:36 vcslinux25 kernel: RPC:  363 holding
UNIX cred c5b6e700
Jun  8 07:43:36 vcslinux25 kernel: RPC:  363
rpc_execute flgs 0
Jun  8 07:43:36 vcslinux25 kernel: RPC:  363
call_start lockd4 proc 2 (sync)
Jun  8 07:43:36 vcslinux25 kernel: RPC:  363
call_reserve
Jun  8 07:43:36 vcslinux25 kernel: RPC:  363 reserved
req c9048000 xid 6d7d04f0
Jun  8 07:43:36 vcslinux25 kernel: RPC:  363
call_reserveresult (status 0)
Jun  8 07:43:36 vcslinux25 kernel: RPC:  363
call_allocate (status 0)
Jun  8 07:43:36 vcslinux25 kernel: RPC:  363 call_bind
xprt c8b5c800 is connected
Jun  8 07:43:36 vcslinux25 kernel: RPC:  363
rpc_getport(10.212.99.95, 100021, 4, 6)
Jun  8 07:43:36 vcslinux25 kernel: RPC:      setting
up TCP transport...
Jun  8 07:43:36 vcslinux25 kernel: RPC:      created
transport c4432400 with 16 slots
Jun  8 07:43:36 vcslinux25 kernel: RPC:    =20
xprt_create_proto created xprt c4432400
Jun  8 07:43:36 vcslinux25 kernel: RPC: creating
portmap client for 10.212.99.95 (xprt c4432400)
Jun  8 07:43:36 vcslinux25 kernel: RPC: creating NULL
authenticator for client c4432200
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364 new task
procpid 29813
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364 allocated
task
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364 looking
up NULL cred
Jun  8 07:43:36 vcslinux25 kernel: RPC:  363
sleep_on(queue "childq" time 687120195)
Jun  8 07:43:36 vcslinux25 kernel: RPC:  363 added to
queue c037fdc0 "childq"
Jun  8 07:43:36 vcslinux25 kernel: RPC:  363 setting
alarm for 60000 ms
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364 added to
queue c037fd80 "schedq"
Jun  8 07:43:36 vcslinux25 kernel: RPC:  363 sync task
going to sleep
Jun  8 07:43:36 vcslinux25 kernel: RPC: switch to
rpciod
Jun  8 07:43:36 vcslinux25 kernel: RPC:    =20
rpc_schedule enter
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364 removed
from queue c037fd80 "schedq"
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364
rpc_execute flgs 289
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364
call_start portmap2 proc 3 (async)
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364
call_reserve
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364 reserved
req cbf62000 xid 5f62d483
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364
call_reserveresult (status 0)
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364
call_allocate (status 0)
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364 call_bind
xprt c4432400 is not connected
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364
call_connect status 0
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364
xprt_connect xprt c4432400 is not connected
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364
sleep_on(queue "xprt_pending" time 687120195)
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364 added to
queue c443248c "xprt_pending"
Jun  8 07:43:36 vcslinux25 kernel: RPC:  364 setting
alarm for 60000 ms
Jun  8 07:43:36 vcslinux25 kernel: RPC:    =20
disconnected transport c4432400
Jun  8 07:43:36 vcslinux25 kernel: RPC:    =20
xprt_create_socket(tcp 6)
Jun  8 07:43:36 vcslinux25 kernel: RPC: c4432400=20
connect status 115 connected 0 sock state 2
Jun  8 07:43:36 vcslinux25 kernel: RPC:    =20
rpc_schedule leave
Jun  8 07:43:36 vcslinux25 kernel: RPC: rpciod back to
sleep
Jun  8 07:44:00 vcslinux25 kernel: RPC:    =20
tcp_state_change client c4432400...
Jun  8 07:44:00 vcslinux25 kernel: RPC:      state 7
conn 0 dead 0 zapped 0
Jun  8 07:44:00 vcslinux25 kernel: RPC:    =20
disconnected transport c4432400
Jun  8 07:44:00 vcslinux25 kernel: RPC:  364
__rpc_wake_up_task (now 687144196 inh 0)
Jun  8 07:44:00 vcslinux25 kernel: RPC:  364 disabling
timer
Jun  8 07:44:00 vcslinux25 kernel: RPC:  364 removed
from queue c443248c "xprt_pending"
Jun  8 07:44:00 vcslinux25 kernel: RPC:  364 added to
queue c037fd80 "schedq"
Jun  8 07:44:00 vcslinux25 kernel: RPC:    =20
__rpc_wake_up_task done
Jun  8 07:44:00 vcslinux25 kernel: RPC: switch to
rpciod
Jun  8 07:44:00 vcslinux25 kernel: RPC:    =20
rpc_schedule enter
Jun  8 07:44:00 vcslinux25 kernel: RPC:  364 removed
from queue c037fd80 "schedq"
Jun  8 07:44:00 vcslinux25 kernel: RPC:  364
rpc_execute flgs 289
Jun  8 07:44:00 vcslinux25 kernel: RPC: error 5
connecting to server 10.212.99.95
Jun  8 07:44:00 vcslinux25 kernel: RPC:    =20
wake_up_next(c4432468 "xprt_resend")
Jun  8 07:44:00 vcslinux25 kernel: RPC:    =20
wake_up_next(c4432444 "xprt_sending")
Jun  8 07:44:00 vcslinux25 kernel: RPC:  364 deleting
timer
Jun  8 07:44:00 vcslinux25 kernel: RPC:  363
__rpc_wake_up_task (now 687144196 inh 0)
Jun  8 07:44:00 vcslinux25 kernel: RPC:  363 disabling
timer
Jun  8 07:44:00 vcslinux25 kernel: RPC:  363 removed
from queue c037fdc0 "childq"
Jun  8 07:44:00 vcslinux25 kernel: RPC:    =20
__rpc_wake_up_task done
Jun  8 07:44:00 vcslinux25 kernel: RPC:  364 exit() =3D
-5
Jun  8 07:44:00 vcslinux25 kernel: RPC:  364 release
task
Jun  8 07:44:00 vcslinux25 kernel: RPC:  364 disabling
timer
Jun  8 07:44:00 vcslinux25 kernel: RPC:  364 release
request cbf62000
Jun  8 07:44:00 vcslinux25 kernel: RPC:    =20
wake_up_next(c44324b0 "xprt_backlog")
Jun  8 07:44:00 vcslinux25 kernel: RPC:  364 releasing
NULL cred c20b5d80
Jun  8 07:44:00 vcslinux25 kernel: RPC:    =20
rpc_release_client(c4432200, 1)
Jun  8 07:44:00 vcslinux25 kernel: RPC: destroying
portmap client for 10.212.99.95
Jun  8 07:44:00 vcslinux25 kernel: RPC: destroying
NULL authenticator ce3e9900
Jun  8 07:44:00 vcslinux25 kernel: RPC:    =20
destroying transport c4432400
Jun  8 07:44:00 vcslinux25 kernel: RPC:    =20
disconnected transport c4432400
Jun  8 07:44:00 vcslinux25 kernel: RPC:  364 freeing
task
Jun  8 07:44:00 vcslinux25 kernel: RPC:    =20
rpc_schedule leave
Jun  8 07:44:00 vcslinux25 kernel: RPC: rpciod back to
sleep
Jun  8 07:44:01 vcslinux25 kernel: RPC:  363 sync task
resuming
Jun  8 07:44:01 vcslinux25 kernel: RPC:  363
pmap_getport_done(status -5, port 0)
Jun  8 07:44:01 vcslinux25 kernel: RPC:  363 deleting
timer
Jun  8 07:44:01 vcslinux25 kernel: RPC:  363 exit() =3D
-5
Jun  8 07:44:01 vcslinux25 kernel: RPC:  363 release
task
Jun  8 07:44:01 vcslinux25 kernel: RPC:  363 disabling
timer
Jun  8 07:44:01 vcslinux25 kernel: RPC:  363 release
request c9048000
Jun  8 07:44:01 vcslinux25 kernel: RPC:    =20
wake_up_next(c8b5c8b0 "xprt_backlog")
Jun  8 07:44:01 vcslinux25 kernel: RPC:  363 releasing
UNIX cred c5b6e700
Jun  8 07:44:01 vcslinux25 kernel: RPC:    =20
rpc_release_client(c8b5ca00, 1)
Jun  8 07:44:01 vcslinux25 kernel: lockd: rpc_call
returned error 5
Jun  8 07:44:01 vcslinux25 kernel: lockd: failed to
reclaim lock for pid 29812 (errno -5, status 0)
 =20

thanks,
 kiran       =20

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around=20
http://mail.yahoo.com=20


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=3D7477&alloc_id=3D16492&op=3Dclic=
k
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
