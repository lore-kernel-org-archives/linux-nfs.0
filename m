From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [RFC/PATCH] nfs: add server port to rpc_pipe info file
Date: Tue, 14 Aug 2007 17:19:31 -0400
Message-ID: <20070814211931.GF16376@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aglo@citi.umich.edu,
	Chuck Lever <chuck.lever@netapp.com>
To: Trond Myklebust <trond@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IL3nZ-0001Jw-3a
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 14:19:33 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IL3nc-0001LV-Q3
	for nfs@lists.sourceforge.net; Tue, 14 Aug 2007 14:19:37 -0700
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

On the server side, when sending krb5 callbacks to the client, gssd
needs to know the callback port.

Together with an nfs-utils patch, this also allows us to support krb5
mounts of servers using non-standard ports; currently if you specify an
alternate server port on the commandline the mount fails.

I don't know whether appending an extra "port:" line here is the right
approach, though.  Comments?

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>
---
 net/sunrpc/rpc_pipe.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
index 669e12a..9b0a489 100644
--- a/net/sunrpc/rpc_pipe.c
+++ b/net/sunrpc/rpc_pipe.c
@@ -329,6 +329,7 @@ rpc_show_info(struct seq_file *m, void *v)
 			clnt->cl_prog, clnt->cl_vers);
 	seq_printf(m, "address: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_ADDR));
 	seq_printf(m, "protocol: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_PROTO));
+	seq_printf(m, "port: %s\n", rpc_peeraddr2str(clnt, RPC_DISPLAY_PORT));
 	return 0;
 }
 
-- 
1.5.3.rc4.67.gf9286


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
