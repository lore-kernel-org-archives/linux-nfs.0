From: Dave Airlie <airlied@linux.ie>
Subject: TCP write queue full message..
Date: Tue, 28 Jan 2003 06:09:40 +0000 (GMT)
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <Pine.LNX.4.44.0301280600080.2079-100000@skynet>
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


Hi,
	I'm doing some development on a 2.4.20 kernel and am trying to
decide if some changes I've made to the kernel are causing my problems or
whether that have simply uncovered an issue that isn't normally seen..

my changes are in order to CRC executables and shared libs running on my
system so if something corrupts at runtime I can reboot (there is a good
reason :-).. so when an executable  is mmaped by the dynamic linker I
hook my code which runs a CRC on the pages in the image before the mmap
finishes...

However I'm running my test system over an NFS root and when I run a
certain configuration (my kernel, test program with debugging enabled and
linked to about 9/10 shared libs), I start to get NFS timeouts and
hangups..

I've traced this to my NFS client (the guy running my modified kernel)
sending junk out in an RPC request from the Program version field onwards,
so a bit of tracing with /proc/sys/sunrpc/rpc_debug and nfs_debug has led
me to get the following..

RPC:      xprt_sendmsg(120) = 120
RPC:      udp_data_ready...
RPC:      udp_data_ready client c7e51000
RPC:  663 received reply
RPC:      packet data:
0x0000 9682416a 00000001 00000000 00000000 00000000 00000000 00000000
00000001
0x0020 000081ed 00000001 00000000 00000000 0004885e 00001000 ffffffff
00000250
0x0040 00000304 000d7663 3e361a41 00000000 3e13846e 00000000 3e13846e
00000000
0x0060 00001000 89442408 e84b79ff ff8b5dfc 89ec5dc3 5589e583 ec188975
fc31d28b
RPC:      cong 768, cwnd was 513, now 256
RPC:  662 xprt_timer (pending request)
RPC:  663 xmit complete
RPC:  664 reserved req c7e51588 xid 6a418297
RPC:  664 xprt_reserve returns 0
RPC:  664 xprt_transmit(6a418297)
RPC:  664 xprt_cwnd_limited cong = 768 cwnd = 256
RPC:  664 TCP write queue full

Now I'm running over UDP so I cannot understand where the TCP write queue
full is coming from, (is the message just in-correct or should I never see
it with UDP?? ).. the packet goes out on the wire over UDP and ethereal
sees the corrupt RPC request...

Now I know it could be my own code but I've gone over it a few times now,
and I will continue to do so .. but I'm just wondering if anyone has any
ideas ..

Dave.

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
