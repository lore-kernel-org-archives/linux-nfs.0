From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 1/2] nfs: add server port to rpc_pipe info file
Date: Sat,  1 Sep 2007 12:42:39 -0400
Message-ID: <11886649602150-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, Olga Kornievskaia <aglo@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IRW3S-0000cj-NI
	for nfs@lists.sourceforge.net; Sat, 01 Sep 2007 09:42:38 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IRW3W-0003uF-W6
	for nfs@lists.sourceforge.net; Sat, 01 Sep 2007 09:42:43 -0700
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

On the client, when an alternate server port is specified on the mount
commandline, we need to make sure gssd knows about it.

Also, on the server side, when we're sending krb5 callbacks to the
client, we'll use the same mechanism to let gssd know about the callback
port.

Thanks to Olga Kornievskaia for testing and for an earlier
implementation.

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
1.5.3.rc5.19.g0734d


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
