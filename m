From: Steve Dickson <SteveD@RedHat.com>
Subject: [PATCH] Timeouts gone wild on ia64
Date: Fri, 09 May 2003 08:41:30 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3EBBA1FA.3090301@RedHat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080101010905080005040507"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from host-64-179-20-100.man.choiceone.net ([64.179.20.100] helo=Odyssey.Home.4Dicksons.Org)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 19E7Cc-0004EZ-00
	for <nfs@lists.sourceforge.net>; Fri, 09 May 2003 05:42:18 -0700
Received: from RedHat.com (Grendel.Home.4Dicksons.Org [192.168.62.4])
	by Odyssey.Home.4Dicksons.Org (8.11.6/8.11.0) with ESMTP id h49CfA026297
	for <nfs@lists.sourceforge.net>; Fri, 9 May 2003 08:41:40 -0400 (EDT)
	(envelope-from SteveD@RedHat.com)
To: nfs@lists.sourceforge.net
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

This is a multi-part message in MIME format.
--------------080101010905080005040507
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Here is a patch that greatly reduces that number of
timeout (and EIO errors with soft mounts) that
occur when a fast client is talking to a slow server.
 
We were noticing a large number of EIO errors when
a ia64 client was talking to a x86 server with
soft mounts (ala autofs)....

True, EIO errors should be expect with soft mounts but
it turns out that thousands of timeouts were occurring on
a ia64 client compared to 50 to 60 timeouts with
a x86 client when talking to the same slow server and
generating the same traffic.

What this patch does is make the minimal Round Trip
time value relative to HZ. So When HZ is greater (as
in the case of ia64) the minimal value goes up.
 
Comments?

SteveD.


--------------080101010905080005040507
Content-Type: text/plain;
 name="linux-2.4.20-nfs-ia64-EIO.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.20-nfs-ia64-EIO.patch"

--- linux-2.4.20/net/sunrpc/timer.c.orig	2003-05-08 15:10:24.000000000 -0400
+++ linux-2.4.20/net/sunrpc/timer.c	2003-05-08 15:40:01.000000000 -0400
@@ -8,7 +8,7 @@
 
 #define RPC_RTO_MAX (60*HZ)
 #define RPC_RTO_INIT (HZ/5)
-#define RPC_RTO_MIN (2)
+#define RPC_RTO_MIN (HZ/30)
 
 void
 rpc_init_rtt(struct rpc_rtt *rt, long timeo)

--------------080101010905080005040507--



-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
