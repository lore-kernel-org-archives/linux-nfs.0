From: andros@netapp.com
Subject: [PATCH 1/1] nfsd41: use sv_max_mesg for forechannel max sizes
Date: Wed, 23 Sep 2009 21:32:21 -0400
Message-ID: <1253755941-4485-1-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:7172 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751613AbZIXVGW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 24 Sep 2009 17:06:22 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

ca_maxresponsesize and ca_maxrequest size include the RPC header.

sv_max_mesg is sv_max_payolad plus a page for overhead and is used in
svc_init_buffer to allocate server buffer space for both the request and reply.
Note that this means we can service an RPC compound that requires
ca_maxrequestsize (MAXWRITE) or ca_max_responsesize (MAXREAD) but that we do
not support an RPC compound that requires both ca_maxrequestsize and
ca_maxresponsesize.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 Documentation/filesystems/nfs41-server.txt |    3 +++
 fs/nfsd/nfs4state.c                        |    3 ++-
 2 files changed, 5 insertions(+), 1 deletions(-)

diff --git a/Documentation/filesystems/nfs41-server.txt b/Documentation/filesystems/nfs41-server.txt
index 05d81cb..6c1c4a7 100644
--- a/Documentation/filesystems/nfs41-server.txt
+++ b/Documentation/filesystems/nfs41-server.txt
@@ -159,3 +159,6 @@ The following cases aren't supported yet:
   DESTROY_CLIENTID, DESTROY_SESSION, EXCHANGE_ID.
 * DESTROY_SESSION MUST be the final operation in the COMPOUND request.
 
+CREATE_SESSION fore channel negotiation:
+* No support for a sessions fore channel RPC compound that requires both a
+  ca_maxrequestsize and a ca_maxresponsesize.
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 46e9ac5..e9a08e5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -477,13 +477,14 @@ static int set_forechannel_drc_size(struct nfsd4_channel_attrs *fchan)
 
 /*
  * fchan holds the client values on input, and the server values on output
+ * sv_max_mesg is the maximum payload plus one page for overhead.
  */
 static int init_forechannel_attrs(struct svc_rqst *rqstp,
 				  struct nfsd4_channel_attrs *session_fchan,
 				  struct nfsd4_channel_attrs *fchan)
 {
 	int status = 0;
-	__u32   maxcount = svc_max_payload(rqstp);
+	__u32   maxcount = nfsd_serv->sv_max_mesg;
 
 	/* headerpadsz set to zero in encode routine */
 
-- 
1.6.2.5

