From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 2/2] SUNRPC: Fix default hostname created in
	rpc_create()
Date: Sat,  1 Sep 2007 12:42:40 -0400
Message-ID: <1188664961458-git-send-email-bfields@citi.umich.edu>
References: <11886649602150-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>,
	nfs@lists.sourceforge.net, Olga Kornievskaia <aglo@citi.umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IRW3T-0000co-MP
	for nfs@lists.sourceforge.net; Sat, 01 Sep 2007 09:42:39 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IRW3W-0003uH-W2
	for nfs@lists.sourceforge.net; Sat, 01 Sep 2007 09:42:44 -0700
In-Reply-To: <11886649602150-git-send-email-bfields@citi.umich.edu>
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

Since 43780b87fa7..., rpc_create() fills in a default hostname based on
the ip address if the servername passed in is null.  A small typo made
that default incorrect.  (But this information appears to be used only
for debugging right now, so I don't believe the typo causes any bugs in
the current kernel.)

Thanks to Olga Kornievskaia for bug report and testing.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>
Cc: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/clnt.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 52429b1..f167fdf 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -253,7 +253,7 @@ struct rpc_clnt *rpc_create(struct rpc_create_args *args)
 	 */
 	if (args->servername == NULL) {
 		struct sockaddr_in *addr =
-					(struct sockaddr_in *) &args->address;
+					(struct sockaddr_in *) args->address;
 		snprintf(servername, sizeof(servername), NIPQUAD_FMT,
 			NIPQUAD(addr->sin_addr.s_addr));
 		args->servername = servername;
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
