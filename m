From: Dave Airlie <airlied@linux.ie>
Subject: Issue with RPC buffer allocation..
Date: Wed, 29 Jan 2003 02:48:45 +0000 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0301290244440.16696-100000@skynet>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <nfs-admin@lists.sourceforge.net>
To: NFS@lists.sourceforge.net
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


Take a look at the log below, taken from one of my systems, running 2.4.20
+ some patches by me - is the behaviour below possible? my patches do two
things, lock in all memory pages using VM_LOCKED for user space apps, and
CRC the pages of every image loaded in .. and I've disabled any threads my
code runs, and the other code seems trivial...

task 676 gets allocated a buffer at c11f6000, and hits congestion and gets
put on a queue
task 677 get allocated the same buffer? even though 676 should have it ..

Dave.


RPC:  675 new task procpid 21
RPC:  675 rpc_execute flgs 1
RPC:  675 reserved req c7e51588 xid 7cc932a2
RPC:  675 xprt_reserve returns 0
RPC:      allocated buffer c7e09000      498
RPC:  675 xprt_transmit c7e09000(7cc932a2)
RPC:  675 xprt_cwnd_limited cong = 0 cwnd = 320
RPC:      xprt_sendmsg(120) = 120
RPC:  675 xmit complete
RPC:  675 sleep_on(queue "xprt_pending" time 4787)
RPC:  675 added to queue c7e5105c "xprt_pending"
RPC:  675 setting alarm for 270 ms
RPC:      wake_up_next(c7e51050 "xprt_resend")
RPC:      wake_up_next(c7e51044 "xprt_sending")
RPC:  676 new task procpid 21
RPC:  676 rpc_execute flgs 1
RPC:  676 reserved req c7e51078 xid 7cc932a3
RPC:  676 xprt_reserve returns 0
RPC:      allocated buffer c11f6000      498
RPC:  676 xprt_transmit c11f6000(7cc932a3)
RPC:  676 xprt_cwnd_limited cong = 256 cwnd = 320
RPC:      xprt_sendmsg(120) = 120
RPC:      udp_data_ready...
RPC:      udp_data_ready client c7e51000
RPC:  676 received reply
RPC:  676 xmit complete
RPC:  676 sleep_on(queue "xprt_pending" time 4799)
RPC:  676 added to queue c7e5105c "xprt_pending"
RPC:  676 setting alarm for 270 ms
RPC:      wake_up_next(c7e51050 "xprt_resend")
RPC:  677 new task procpid 21
RPC:  677 rpc_execute flgs 1
RPC:  677 reserved req c7e51618 xid 7cc932a4
RPC:  677 xprt_reserve returns 0
RPC:      allocated buffer c11f6000      498
RPC:  677 xprt_transmit c11f6000(7cc932a4)
RPC:  677 xprt_cwnd_limited cong = 512 cwnd = 320
RPC:  677 TCP write queue full
RPC:  677 sleep_on(queue "xprt_sending" time 4808)
RPC:  677 added to queue c7e51044 "xprt_sending"

-- 
David Airlie, Software Engineer
http://www.skynet.ie/~airlied / airlied@skynet.ie
pam_smb / Linux DecStation / Linux VAX / ILUG person




-------------------------------------------------------
This SF.NET email is sponsored by:
SourceForge Enterprise Edition + IBM + LinuxWorld = Something 2 See!
http://www.vasoftware.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
