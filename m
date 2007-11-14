From: Joe Perches <joe@perches.com>
Subject: [PATCH] - [15/15] - remove defconfig ptr comparisons to 0
	-	net/sunrpc
Date: Tue, 13 Nov 2007 18:05:39 -0800
Message-ID: <1195005939.5163.101.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	Networking Team <netdev@vger.kernel.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	"J. Bruce Fields" <bfields@fieldses.org>, nfs@lists.sourceforge.net,
	Linus Torvalds <torvalds@linux-foundation.org>
To: linux-kernel <linux-kernel@vger.kernel.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is7dn-000416-18
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 18:06:07 -0800
Received: from dsl022.labridge.com ([206.117.136.22] helo=perches.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is7dr-0004Pw-IM
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 18:06:12 -0800
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

Remove defconfig ptr comparison to 0

Remove sparse warning: Using plain integer as NULL pointer

Signed-off-by: Joe Perches <joe@perches.com>

---

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 76be83e..1600df2 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -157,7 +157,7 @@ static struct rpc_clnt * rpc_new_client(struct rpc_xprt *xprt, char *servname, s
 	clnt->cl_server = clnt->cl_inline_name;
 	if (len > sizeof(clnt->cl_inline_name)) {
 		char *buf = kmalloc(len, GFP_KERNEL);
-		if (buf != 0)
+		if (buf)
 			clnt->cl_server = buf;
 		else
 			len = sizeof(clnt->cl_inline_name);



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
