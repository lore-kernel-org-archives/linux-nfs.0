From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: 2.6.22 [PATCH 0/3] NLM: fix source address in server callbacks
Date: Mon, 9 Jul 2007 22:19:13 +0200
Message-ID: <20070709201913.GA3970@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: Linux NFS mailing list <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I7zhQ-0002Es-S6
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 13:19:12 -0700
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I7zhS-0005bU-Td
	for nfs@lists.sourceforge.net; Mon, 09 Jul 2007 13:19:16 -0700
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

Here's the patchset again but this time for 2.6.22 (verified) and based on
the earlier cleanup patch for creating a SUNRPC transport.  The xs_bind
(formerly xs_bindresvport) function slightly been recoded to make more
clear what it does.

The first patch changes the TCP server socket code to save the socket
name right after an accept(). This local address of a connection
(destination address of a request) is needed for connecting back when
doing the callback later. For UDP the address was already saved for RPC
replies because UDP is connectionless. This patch is IPv6 clean.

The second patch changes the NFS client code to be able to bind not only
to a privileged port but also to bind to a specific local address. The
client code is used by the server for callbacks.

The third patch is the actual NLM fix.

-- 
Frank

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
