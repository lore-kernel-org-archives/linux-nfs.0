From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/2] mount.nfs: Update description of clientaddr= in
	nfs(5)
Date: Tue, 04 Sep 2007 16:13:55 -0400
Message-ID: <20070904201355.4721.10122.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ISemo-00088v-Uk
	for nfs@lists.sourceforge.net; Tue, 04 Sep 2007 13:14:11 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71] helo=flpi102.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ISems-0000D7-Bs
	for nfs@lists.sourceforge.net; Tue, 04 Sep 2007 13:14:15 -0700
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
other typical reasons for using it.  Expand its description.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/nfs.man |   22 +++++++++++++++++-----
 1 files changed, 17 insertions(+), 5 deletions(-)

diff --git a/utils/mount/nfs.man b/utils/mount/nfs.man
index e66daba..d92da19 100644
--- a/utils/mount/nfs.man
+++ b/utils/mount/nfs.man
@@ -411,11 +411,23 @@ Valid protocol types are
 and
 .IR tcp .
 .TP 1.5i
-.I clientaddr=n
-On a multi-homed client, this
-causes the client to use a specific callback address when
-communicating with an NFS version 4 server.
-This option is currently ignored.
+.I clientaddr=n.n.n.n
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
+address to use for callbacks may be nontrivial to determine,
+and should be explicitly set using this mount option.
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
