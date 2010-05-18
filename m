From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: Re: [PATCH 2/2] nfsd4: fix callback program version
Date: Tue, 18 May 2010 18:48:49 -0400
Message-ID: <20100518224848.GA26911@fieldses.org>
References: <1273877123-23617-1-git-send-email-bfields@citi.umich.edu> <1273877123-23617-2-git-send-email-bfields@citi.umich.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:60889 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752432Ab0ERWst (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 18 May 2010 18:48:49 -0400
Received: from bfields by fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1OEVaj-00070m-3j
	for linux-nfs@vger.kernel.org; Tue, 18 May 2010 18:48:49 -0400
In-Reply-To: <1273877123-23617-2-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 14, 2010 at 06:45:23PM -0400, J. Bruce Fields wrote:
> The 4.1 rfc actually specifices that the callback program must have
> version 4.
> 
> As far as I can tell, this was unspecified in rfc 3530.  But it looks to
> me like the NFSv4 client only ever accepted version 1!
> 
> Newer linux clients allow either 1 or 4, for either minor version.
> 
> So, the safest approach seems to be to use version 1 for 4.0 clients,
> and version 4 for 4.1 clients.

OK, following further discussion on the ietf list, let's stick to
version 1 for now and just add a comment.

--b.

commit b7299f44394336f51b526247a870d47d28f4f97c
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Fri May 14 17:57:35 2010 -0400

    nfs4: minor callback code simplification, comment
    
    Note the position in the version array doesn't have to match the actual
    rpc version number--to me it seems clearer to maintain the distinction.
    
    Also document choice of rpc callback version number, as discussed in
    e.g. http://www.ietf.org/mail-archive/web/nfsv4/current/msg07985.html
    and followups.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 77bc9d3..eb78e7e 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -424,13 +424,19 @@ static struct rpc_procinfo     nfs4_cb_procedures[] = {
 };
 
 static struct rpc_version       nfs_cb_version4 = {
+/*
+ * Note on the callback rpc program version number: despite language in rfc
+ * 5661 section 18.36.3 requiring servers to use 4 in this field, the
+ * official xdr descriptions for both 4.0 and 4.1 specify version 1, and
+ * in practice that appears to be what implementations use.  The section
+ * 18.36.3 language is expected to be fixed in an erratum.
+ */
         .number                 = 1,
         .nrprocs                = ARRAY_SIZE(nfs4_cb_procedures),
         .procs                  = nfs4_cb_procedures
 };
 
 static struct rpc_version *	nfs_cb_version[] = {
-	NULL,
 	&nfs_cb_version4,
 };
 
@@ -471,7 +477,7 @@ int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *cb)
 		.timeout	= &timeparms,
 		.program	= &cb_program,
 		.prognumber	= cb->cb_prog,
-		.version	= nfs_cb_version[1]->number,
+		.version	= 0,
 		.authflavor	= clp->cl_flavor,
 		.flags		= (RPC_CLNT_CREATE_NOPING | RPC_CLNT_CREATE_QUIET),
 		.client_name    = clp->cl_principal,
