From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/1] nfsd41: use sv_max_mesg for forechannel max sizes
Date: Mon, 28 Sep 2009 12:41:58 -0400
Message-ID: <20090928164158.GB13299@fieldses.org>
References: <1253755941-4485-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:37280 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752520AbZI1Qlj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Sep 2009 12:41:39 -0400
In-Reply-To: <1253755941-4485-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 23, 2009 at 09:32:21PM -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> ca_maxresponsesize and ca_maxrequest size include the RPC header.
> 
> sv_max_mesg is sv_max_payolad plus a page for overhead and is used in
> svc_init_buffer to allocate server buffer space for both the request and reply.
> Note that this means we can service an RPC compound that requires
> ca_maxrequestsize (MAXWRITE) or ca_max_responsesize (MAXREAD) but that we do
> not support an RPC compound that requires both ca_maxrequestsize and
> ca_maxresponsesize.

Thanks Andy, applied, as follows, with some minor documentation changes.

--b.

commit ddc04fd4d5163aee9ebdb38a56c365b602e2b7b7
Author: Andy Adamson <andros@netapp.com>
Date:   Wed Sep 23 21:32:21 2009 -0400

    nfsd41: use sv_max_mesg for forechannel max sizes
    
    ca_maxresponsesize and ca_maxrequest size include the RPC header.
    
    sv_max_mesg is sv_max_payolad plus a page for overhead and is used in
    svc_init_buffer to allocate server buffer space for both the request and reply.
    Note that this means we can service an RPC compound that requires
    ca_maxrequestsize (MAXWRITE) or ca_max_responsesize (MAXREAD) but that we do
    not support an RPC compound that requires both ca_maxrequestsize and
    ca_maxresponsesize.
    
    Signed-off-by: Andy Adamson <andros@netapp.com>
    [bfields@citi.umich.edu: more documentation updates]
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/Documentation/filesystems/nfs41-server.txt b/Documentation/filesystems/nfs41-server.txt
index 1f95e77..1bd0d0c 100644
--- a/Documentation/filesystems/nfs41-server.txt
+++ b/Documentation/filesystems/nfs41-server.txt
@@ -213,3 +213,10 @@ The following cases aren't supported yet:
   DESTROY_CLIENTID, DESTROY_SESSION, EXCHANGE_ID.
 * DESTROY_SESSION MUST be the final operation in the COMPOUND request.
 
+Nonstandard compound limitations:
+* No support for a sessions fore channel RPC compound that requires both a
+  ca_maxrequestsize request and a ca_maxresponsesize reply, so we may
+  fail to live up to the promise we made in CREATE_SESSION fore channel
+  negotiation.
+* No more than one IO operation (read, write, readdir) allowed per
+  compound.
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 2153f9b..fcb9817 100644
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
 
