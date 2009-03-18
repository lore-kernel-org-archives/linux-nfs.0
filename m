From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: nfsd4: don't check ip address in setclientid
Date: Wed, 18 Mar 2009 19:36:40 -0400
Message-ID: <20090318233640.GO18894@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:42908 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751196AbZCRXgl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 19:36:41 -0400
Received: from bfields by pickle.fieldses.org with local (Exim 4.69)
	(envelope-from <bfields@fieldses.org>)
	id 1Lk5JQ-0005sh-D5
	for linux-nfs@vger.kernel.org; Wed, 18 Mar 2009 19:36:40 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I'm queuing this up for 2.6.30, barring objections.

--b.

commit 026722c25e6eb018eab8b9a3c198c258f5b7a2e7
Author: J. Bruce Fields <bfields@citi.umich.edu>
Date:   Wed Mar 18 15:06:26 2009 -0400

    nfsd4: don't check ip address in setclientid
    
    The spec allows clients to change ip address, so we shouldn't be
    requiring that setclientid always come from the same address.  For
    example, a client could reboot and get a new dhcpd address, but still
    present the same clientid to the server.  In that case the server should
    revoke the client's previous state and allow it to continue, instead of
    (as it currently does) returning a CLID_INUSE error.
    
    Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 54651aa..070e9e5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -791,10 +791,9 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	if (conf) {
 		/* RFC 3530 14.2.33 CASE 0: */
 		status = nfserr_clid_inuse;
-		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)
-				|| conf->cl_addr != sin->sin_addr.s_addr) {
-			dprintk("NFSD: setclientid: string in use by clientat %pI4\n",
-				&conf->cl_addr);
+		if (!same_creds(&conf->cl_cred, &rqstp->rq_cred)) {
+			dprintk("NFSD: setclientid: string in use by client"
+				" at %pI4\n", &conf->cl_addr);
 			goto out;
 		}
 	}
