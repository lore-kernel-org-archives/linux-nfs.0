From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: 2.6.19.3 client locking bug upon server reboot
Date: Mon, 26 Feb 2007 15:15:17 +0100
Message-ID: <20070226141517.GA22552@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HLgdM-0004gP-SX
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 06:15:21 -0800
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HLgdN-00070f-EX
	for nfs@lists.sourceforge.net; Mon, 26 Feb 2007 06:15:23 -0800
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

2.6.19.3, NFS V3, portmap V2, stat V1, nlm, all UDP

one server, three clients:

client1 has the lock
client2 wants the lock (fcntl blocks)
client3 will try to lock right after server has rebooted and started everything

On the server, /etc/rc2.d/S06xxxx is created to start a

	tcpdump -i eth0 -p -w /tmp/log -s 1500 >/dev/null 2>&1 &

upon the next reboot right after eth0 becomes up.

I type alt-sysrq-b on the server after a few "sync" commands. After >5
minutes client1 releases the lock and client3 obtains the lock. A few
seconds later client3 releases the lock.

	nothing happens

client2 did not try to obtain a lock anyhow since server reboot. Instead,
it hangs in rpc_wait_bit_interruptible(), only kill -9 could kill it.

The log written by tcpdump has been analyzed afterwards using wireshark
(t=<time since start>):

t=10	server->(all 3 clients): portmap getport STAT, all clients reply
	server->(all 3 clients): STAT notify, all clients reply
	client1->server: portmap getport NLM, server replies
	client1->server: NLM lock, server replies.

t=15	client3->server: portmap getport NLM, server replies
	client3->server: NLM lock, server says: NLM_DENIED_GRACE_PERIOD
t=20	client3->server: NLM lock, server says: NLM_DENIED_GRACE_PERIOD
t=25	client3->server: NLM lock, server says: NLM_DENIED_GRACE_PERIOD
t=30	client3->server: NLM lock, server says: NLM_DENIED_GRACE_PERIOD
t=35	client3->server: NLM lock, server says: NLM_DENIED_GRACE_PERIOD
t=40	client3->server: NLM lock, server says: NLM_DENIED_GRACE_PERIOD
t=45	client3->server: NLM lock, server says: NLM_DENIED_GRACE_PERIOD
t=50	client3->server: NLM lock, server says: NLM_DENIED_GRACE_PERIOD
t=55	client3->server: NLM lock, server says: NLM_BLOCKED
t=85	client3->server: portmap getport NLM, server replies

t=115	client3->server: NLM lock, server says: NLM_BLOCKED

[...]

t=383	client1->server: portmap getport NLM, server replies
	client1->server: NLM unlock, server replies
	server->client3: portmap getport NLM, client replies
	server->client3: NLM NULL, client replies
	server->client3: NLM GRANTED_MSG
	client3->server: portmap getport NLM, server replies
	client3->server: NLM NULL, server replies.
	client3->server: NLM GRANTED_RES, server replies.
	client3->server: reply for NLM GRANTED_MSG

t=390	client3->server: portmap getport NLM, server replies
	client3->server: NLM unlock, server replies.

Notice the absence of any client2 traffic for t>10. There is no
interesting traffic around t=10 whatsoever for client2 other than what
has been mentioned. This bug is probably reproducable without the third
client but anyway, the above is what happened during the test.

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
