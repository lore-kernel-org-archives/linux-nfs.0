From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 04/10] mount.nfs: Remove a redundant port assignment
Date: Fri, 03 Aug 2007 13:23:44 -0400
Message-ID: <20070803172344.3357.22732.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IH0sI-0001w6-Le
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:23:42 -0700
Received: from flpvm23.prodigy.net ([207.115.20.53])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IH0sL-0007ce-Dq
	for nfs@lists.sourceforge.net; Fri, 03 Aug 2007 10:23:46 -0700
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

getport() always fills in its port number before calling GETPORT.  No need
for the caller to do this.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index efedf25..220bbce 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -333,7 +333,6 @@ static int probe_port(clnt_addr_t *server, const unsigned long *versions,
 	p_vers = vers ? &vers : versions;
 	rpc_createerr.cf_stat = 0;
 	for (;;) {
-		saddr->sin_port = htons(PMAPPORT);
 		p_port = getport(saddr, prog, *p_vers, *p_prot);
 		if (p_port) {
 			if (!port || port == p_port) {


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
