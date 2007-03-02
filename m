From: NeilBrown <neilb@suse.de>
Subject: [PATCH 002 of 3] knfsd: Avoid checksum checks when collecting
	metadata for a UDP packet.
Date: Fri, 2 Mar 2007 15:28:30 +1100
Message-ID: <1070302042830.5777@suse.de>
References: <20070302151748.5226.patches@notabene>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HMzOi-0002IY-N3
	for nfs@lists.sourceforge.net; Thu, 01 Mar 2007 20:29:37 -0800
Received: from cantor.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1HMzOk-0000N9-8o
	for nfs@lists.sourceforge.net; Thu, 01 Mar 2007 20:29:38 -0800
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


When recv_msg is called with a size of 0 and MSG_PEEK (and
sunrpc/svcsock.c does), it is clear that we only interested in
metadata (from/to addresses) and not the data, so don't do any
checksum checking at this point.  Leave that until the data is
requested.

Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/ipv4/udp.c |    3 +++
 ./net/ipv6/udp.c |    4 ++++
 2 files changed, 7 insertions(+)

diff .prev/net/ipv4/udp.c ./net/ipv4/udp.c
--- .prev/net/ipv4/udp.c	2007-03-02 14:20:13.000000000 +1100
+++ ./net/ipv4/udp.c	2007-03-02 15:13:50.000000000 +1100
@@ -846,6 +846,9 @@ try_again:
 			goto csum_copy_err;
 		copy_only = 1;
 	}
+	if (len == 0 &&  (flags & MSG_PEEK))
+		/* avoid checksum concerns when just getting metadata */
+		copy_only = 1;
 
 	if (copy_only)
 		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),

diff .prev/net/ipv6/udp.c ./net/ipv6/udp.c
--- .prev/net/ipv6/udp.c	2007-03-02 14:20:13.000000000 +1100
+++ ./net/ipv6/udp.c	2007-03-02 15:13:50.000000000 +1100
@@ -151,6 +151,10 @@ try_again:
 		copy_only = 1;
 	}
 
+	if (len == 0 &&  (flags & MSG_PEEK))
+		/* avoid checksum concerns when just getting metadata */
+		copy_only = 1;
+
 	if (copy_only)
 		err = skb_copy_datagram_iovec(skb, sizeof(struct udphdr),
 					      msg->msg_iov, copied       );

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
