From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 0/7] Improve the NFS/TCP reconnection code
Date: Tue, 06 Nov 2007 19:39:35 -0500
Message-ID: <20071107003834.13713.73536.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfsv4@linux-nfs.org, nfs@lists.sourceforge.net
To: Chuck Lever <Chuck.Lever@oracle.com>,
	Tom Talpey <Thomas.Talpey@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IpYvf-0002M3-EP
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 16:37:59 -0800
Received: from c-69-242-210-120.hsd1.mi.comcast.net ([69.242.210.120]
	helo=heimdal.trondhjem.org)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IpYvk-0004zc-Vr
	for nfs@lists.sourceforge.net; Tue, 06 Nov 2007 16:38:05 -0800
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

The following series of patches attempts to fix a problem with the
current Linux RPC client disconnect/reconnect logic in the TCP client.

Our current strategy whenever we need to disconnect from the server and
then reconnect is to force a reset of the connection (by issuing a
'special' connect(AF_UNSPEC) call that essentially causes the TCP layer
to send an RST to terminate the current connection.
This then allows us to reuse the port immediately without worrying about
TIME-WAIT states.

The problem is that RST is not supposed to be acked by the server. We
can therefore never be entirely sure that the connection was correctly
terminated on the server side. This again may cause a SYN, RST loop
when we try to reconnect since the server may think that we are trying
to reconnect from a port that is already connected.

The solution is to use a combination of the shutdown() command, and the
connect(AF_UNSPEC).

By using shutdown() to initiate the disconnection, we are able to hang
onto the socket and monitor the shutdown process via the ->state_change()
callback. Better, we can continue to receive replies on the socket until
the FIN from the server arrives to tell that it is done sending.

After the connection is shut down, we can then use the connect(AF_UNSPEC)
trick in order to reset the socket without releasing the port number. Note
that because the socket is already closed, no RST is sent to the server.
A curious side-effect of this is that the TIME-WAIT state gets moved to
a different port number. I'm not sure how to avoid this...

Cheers
  Trond

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
