From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: lockd regression in 2.6.22.9,
	2.6.23-rc8 (CONFIG_SUNRPC_BIND34)
Date: Mon, 1 Oct 2007 10:35:25 +0200
Message-ID: <20071001083525.GA21112@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcGkQ-0001bk-7S
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 01:35:26 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IcGkT-0000Wi-7w
	for nfs@lists.sourceforge.net; Mon, 01 Oct 2007 01:35:29 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

2.6.21 is ok, 2.6.22.9 and 2.6.23-rc8 NLM no longer works with a
OSF/1 tru64 client when CONFIG_SUNRPC_BIND34 is set

When the client tries to lock a file the server starts complaining:

	lockd: couldn't create RPC handle for <clientname>

and the lock is never granted (waits forever). Wireshark shows the
following NLM/portmap traffic (172.17.2.13=client, 172.17.1.48=server):

    160 47.192068   172.17.2.13           172.17.1.48           Portmap  V2 GETPORT Call (Reply In 161) NLM(100021) V:4 UDP
    161 47.192366   172.17.1.48           172.17.2.13           Portmap  V2 GETPORT Reply (Call In 160) Port:32768
    162 47.196111   172.17.2.13           172.17.1.48           NLM      V4 LOCK_MSG Call (Reply In 165) FH:0xc26a9c32 svid:108548 pos:0-0
    163 47.196212   172.17.1.48           172.17.2.13           Portmap  V4 GETVERSADDR Call (Reply In 164)
    164 47.197259   172.17.2.13           172.17.1.48           Portmap  V4 GETVERSADDR Reply (Call In 163)
    165 47.197322   172.17.1.48           172.17.2.13           NLM      V4 LOCK_MSG Reply (Call In 162)

echo 2 >/proc/sys/sunrpc/rpc_debug output:

RPC:       creating lockd client for <clientname> (xprt f73b1800)
RPC:       creating lockd client for <clientname> (xprt f73b1800)
RPC: 61422 call_start lockd4 proc 0 (sync)
RPC: 61422 call_reserve (status 0)
RPC: 61422 call_reserveresult (status 0)
RPC: 61422 call_allocate (status 0)
RPC: 61422 call_bind (status 0)
RPC:       creating rpcbind client for <clientname> (xprt dff99400)
RPC:       creating rpcbind client for <clientname> (xprt dff99400)
RPC: 61423 call_start rpcbind4 proc 9 (async)
RPC: 61423 call_reserve (status 0)
RPC: 61423 call_reserveresult (status 0)
RPC: 61423 call_allocate (status 0)
RPC: 61423 call_bind (status 0)
RPC: 61423 call_connect xprt dff99400 is not connected
RPC: 61423 call_connect_status (status 0)
RPC: 61423 call_transmit (status 0)
RPC: 61423 call_encode (status 0)
RPC: 61423 call_status (status 24)
RPC: 61423 call_decode (status 24)
RPC: 61423 call_verify: program 100000 is unsupported by server <clientname>
RPC:       rpc_release_client(c78de200, 1)
RPC:       destroying rpcbind client for <clientname>
RPC: 61422 remote rpcbind service unavailable
RPC:       rpc_release_client(ed189d00, 1)
RPC:       shutting down lockd client for <clientname>, tasks=0
RPC:       destroying lockd client for <clientname>
lockd: couldn't create RPC handle for <clientname>

GETVERSADDR call data:
0000  00 10 64 30 be 3e 00 13 72 12 39 3f 08 00 45 00   ..d0.>..r.9?..E.
0010  00 88 00 00 40 00 40 11 df 05 ac 11 01 30 ac 11   ....@.@......0..
0020  02 0d 80 04 00 6f 00 74 5b e5 41 ab e9 27 00 00   .....o.t[.A..'..
0030  00 00 00 00 00 02 00 01 86 a0 00 00 00 04 00 00   ................
0040  00 09 00 00 00 01 00 00 00 1c 00 05 2e 58 00 00   .............X..
0050  00 05 6c 69 74 74 6f 00 00 00 00 00 ff fe 00 00   ..litto.........
0060  ff fe 00 00 00 00 00 00 00 00 00 00 00 00 00 01   ................
0070  86 b5 00 00 00 04 00 00 00 03 75 64 70 00 00 00   ..........udp... (*)
0080  00 0b 31 37 32 2e 31 37 2e 32 2e 31 33 00 00 00   ..172.17.2.13...
0090  00 04 72 70 63 62                                 ..rpcb

GETVERSADDR reply data:
0000  00 13 72 12 39 3f 00 10 64 30 be 3e 08 00 45 00   ..r.9?..d0.>..E.
0010  00 34 49 9c 00 00 3c 11 d9 bd ac 11 02 0d ac 11   .4I...<.........
0020  01 30 00 6f 80 04 00 20 f9 05 41 ab e9 27 00 00   .0.o... ..A..'..
0030  00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0040  00 01                                             ..

LOCK_MSG reply data:
0000  00 10 64 30 be 3e 00 13 72 12 39 3f 08 00 45 00   ..d0.>..r.9?..E.
0010  00 34 00 00 40 00 40 11 df 59 ac 11 01 30 ac 11   .4..@.@..Y...0..
0020  02 0d 80 00 03 09 00 20 5b 91 b4 8e 46 02 00 00   ....... [...F...
0030  00 01 00 00 00 00 00 00 00 00 00 00 00 00 00 00   ................
0040  00 05                                             ..

Every 5 seconds the 6 packet dialog repeats itself.
Disabling CONFIG_SUNRPC_BIND34 avoids the issue.

(*) hex 01 86 b5 is 100021 which is NLM_PROGRAM.


-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
