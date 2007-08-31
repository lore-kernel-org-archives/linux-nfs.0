From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] mount.nfs: Update description of clientaddr= in nfs(5)
Date: Fri, 31 Aug 2007 11:15:59 -0400
Message-ID: <20070831151559.9043.42134.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IR8Pg-0006VH-L9
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 08:28:01 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IR8EH-0008D5-5r
	for nfs@lists.sourceforge.net; Fri, 31 Aug 2007 08:16:13 -0700
Received: from monet.1015granger.net
	(adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpvm09.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id
	l7VFFoZX010578
	for <nfs@lists.sourceforge.net>; Fri, 31 Aug 2007 08:15:51 -0700
Received: from monet.1015granger.net (monet.1015granger.net [127.0.0.1])
	by monet.1015granger.net (8.14.1/8.14.1) with ESMTP id l7VFFxvk009059
	for <nfs@lists.sourceforge.net>; Fri, 31 Aug 2007 11:15:59 -0400
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

The description of clientaddr= in nfs(5) is out of date and omits some
other typical reasons for using it.  Expand the description.

Rewrite, take 2.  This may address review comments..?

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |   19 +++++++++++++++----
 1 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index e66daba..7248099 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -412,10 +412,21 @@ and
 .IR tcp .
 .TP 1.5i
 .I clientaddr=n
-On a multi-homed client, this
-causes the client to use a specific callback address when
-communicating with an NFS version 4 server.
-This option is currently ignored.
+Specifies a single IPv4 address in dotted-quad form that
+the NFS client advertises to allow servers to perform
+NFSv4 callback requests against files on this mount point.
+If the server is not able to establish callback connections
+to clients, performance may degrade, or accesses to
+files may temporarily hang.
+.IP
+If this option is not specified, the
+.BR mount (8)
+command attempts to discover an appropriate callback
+address automatically.
+The automatic discovery process is not perfect, however.
+In the presence of multiple client network interfaces, special
+routing policies, or atypical network topologies, the exact
+address to use for callbacks may be nontrivial to determine.
 .TP 1.5i
 .I sec=mode
 Same as \f3sec=mode\f1 for the nfs filesystem type (see above).


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
