From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: 2.6.x client locking bug upon server reboot (2)
Date: Fri, 2 Mar 2007 21:15:24 +0100
Message-ID: <20070302201524.GA14781@janus>
References: <20070226141517.GA22552@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HNEA1-0000Yt-EO
	for nfs@lists.sourceforge.net; Fri, 02 Mar 2007 12:15:31 -0800
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HNEA2-0002rB-0K
	for nfs@lists.sourceforge.net; Fri, 02 Mar 2007 12:15:27 -0800
In-Reply-To: <20070226141517.GA22552@janus>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, Feb 26, 2007 at 03:15:17PM +0100, Frank van Maarseveen wrote:
> 2.6.19.3, NFS V3, portmap V2, stat V1, nlm, all UDP

nlm V4 

> 
> one server, three clients:
> 
> client1 has the lock
> client2 wants the lock (fcntl blocks)
> client3 will try to lock right after server has rebooted and started everything
> 
> On the server, /etc/rc2.d/S06xxxx is created to start a
> 
> 	tcpdump -i eth0 -p -w /tmp/log -s 1500 >/dev/null 2>&1 &
> 
> upon the next reboot right after eth0 becomes up.
> 
> I type alt-sysrq-b on the server after a few "sync" commands. After >5
> minutes client1 releases the lock and client3 obtains the lock. A few
> seconds later client3 releases the lock.
> 
> 	nothing happens
> 
> client2 did not try to obtain a lock anyhow since server reboot. Instead,
> it hangs in rpc_wait_bit_interruptible(), only kill -9 could kill it.

I tried something like this again but now using 2.6.20.1 + nfs-all
patch from Trond for 2.6.20 on server and two clients

	The results are disturbing

2 clients try to lock the same file on the server. After things
settle down the server is rebooted in a crashy fashion:

	echo b >/proc/sysrq-trigger

The NFS client which was still waiting in fcntl to obtain the lock now
returns an error to userspace:

	lck: fcntl: Input/output error

Note that these are NFSv3 hard UDP mounts. EIO should not happen for this IMO.


wireshark trace done on the failing client:
No.     Time        Source Destination    Protocol Info
     34 3.611153    client server         NLM      V4 LOCK Call (Reply In 35) FH:0x73a8a272 svid:2 pos:0-0
     35 3.611372    server client         NLM      V4 LOCK Reply (Call In 34) NLM_BLOCKED
    206 33.601700   client server         Portmap  V2 GETPORT Call NLM(100021) V:4 UDP
    215 38.600612   client server         Portmap  [RPC retransmission of #206]V2 GETPORT Call NLM(100021) V:4 UDP
    392 83.586328   client server         Portmap  V2 GETPORT Call (Reply In 393) NLM(100021) V:4 UDP
    393 83.597514   server client         Portmap  V2 GETPORT Reply (Call In 392) Port:32768
    394 83.597609   client server         NLM      V4 CANCEL Call (Reply In 395) FH:0x73a8a272 svid:2 pos:0-0
    396 83.597847   client server         NLM      [RPC retransmission of #394]V4 CANCEL Call (Reply In 395) FH:0x73a8a272 svid:2 pos:0-0
    398 83.597994   client server         NLM      [RPC retransmission of #394]V4 CANCEL Call (Reply In 395) FH:0x73a8a272 svid:2 pos:0-0
    452 92.524680   server client         Portmap  V2 GETPORT Call (Reply In 453) STAT(100024) V:1 UDP
    453 92.525074   client server         Portmap  V2 GETPORT Reply (Call In 452) Port:32771
    454 92.527572   server client         STAT     V1 NOTIFY Call (Reply In 457)
    457 92.528957   client server         STAT     V1 NOTIFY Reply (Call In 454)
    517 113.588958  client server         Portmap  V2 GETPORT Call (Reply In 518) NLM(100021) V:4 UDP
    518 113.589382  server client         Portmap  V2 GETPORT Reply (Call In 517) Port:32768
    519 113.589466  client server         NLM      V4 CANCEL Call (Reply In 520) FH:0x73a8a272 svid:2 pos:0-0

-- 
Frank

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
