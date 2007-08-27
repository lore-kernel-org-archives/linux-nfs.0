From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [PATCH 13/15] knfsd: remove code duplication in
	nfsd4_setclientid()
Date: Mon, 27 Aug 2007 16:22:54 -0400
Message-ID: <11882461782430-git-send-email-bfields@fieldses.org>
References: <11882461763072-git-send-email-bfields@fieldses.org>
	<1188246176681-git-send-email-bfields@fieldses.org>
	<1188246176897-git-send-email-bfields@fieldses.org>
	<1188246177833-git-send-email-bfields@fieldses.org>
	<11882461773576-git-send-email-bfields@fieldses.org>
	<11882461771774-git-send-email-bfields@fieldses.org>
	<1188246177195-git-send-email-bfields@fieldses.org>
	<11882461773396-git-send-email-bfields@fieldses.org>
	<1188246177259-git-send-email-bfields@fieldses.org>
	<1188246177192-git-send-email-bfields@fieldses.org>
	<11882461773221-git-send-email-bfields@fieldses.org>
	<11882461773657-git-send-email-bfields@fieldses.org>
	<11882461772689-git-send-email-bfields@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>,
	"J. Bruce Fields" <bfields@citi.umich.edu>, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IPl6y-0004hG-QM
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:00 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IPl71-0003O2-Hr
	for nfs@lists.sourceforge.net; Mon, 27 Aug 2007 13:23:05 -0700
In-Reply-To: <11882461772689-git-send-email-bfields@fieldses.org>
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

From: J. Bruce Fields <bfields@citi.umich.edu>

Each branch of this if-then-else has a bunch of duplicated code that we
could just put at the end.

Signed-off-by: "J. Bruce Fields" <bfields@citi.umich.edu>
---
 fs/nfsd/nfs4state.c |   30 ++++++------------------------
 1 files changed, 6 insertions(+), 24 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 09573b9..6256492 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -774,13 +774,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		new = create_client(clname, dname);
 		if (new == NULL)
 			goto out;
-		copy_verf(new, &clverifier);
-		new->cl_addr = sin->sin_addr.s_addr;
-		copy_cred(&new->cl_cred,&rqstp->rq_cred);
 		gen_clid(new);
-		gen_confirm(new);
-		gen_callback(new, setclid);
-		add_to_unconfirmed(new, strhashval);
 	} else if (same_verf(&conf->cl_verifier, &clverifier)) {
 		/*
 		 * CASE 1:
@@ -806,13 +800,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		new = create_client(clname, dname);
 		if (new == NULL)
 			goto out;
-		copy_verf(new,&conf->cl_verifier);
-		new->cl_addr = sin->sin_addr.s_addr;
-		copy_cred(&new->cl_cred,&rqstp->rq_cred);
 		copy_clid(new, conf);
-		gen_confirm(new);
-		gen_callback(new, setclid);
-		add_to_unconfirmed(new,strhashval);
 	} else if (!unconf) {
 		/*
 		 * CASE 2:
@@ -825,13 +813,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		new = create_client(clname, dname);
 		if (new == NULL)
 			goto out;
-		copy_verf(new,&clverifier);
-		new->cl_addr = sin->sin_addr.s_addr;
-		copy_cred(&new->cl_cred,&rqstp->rq_cred);
 		gen_clid(new);
-		gen_confirm(new);
-		gen_callback(new, setclid);
-		add_to_unconfirmed(new, strhashval);
 	} else if (!same_verf(&conf->cl_confirm, &unconf->cl_confirm)) {
 		/*	
 		 * CASE3:
@@ -852,19 +834,19 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		new = create_client(clname, dname);
 		if (new == NULL)
 			goto out;
-		copy_verf(new,&clverifier);
-		new->cl_addr = sin->sin_addr.s_addr;
-		copy_cred(&new->cl_cred,&rqstp->rq_cred);
 		gen_clid(new);
-		gen_confirm(new);
-		gen_callback(new, setclid);
-		add_to_unconfirmed(new, strhashval);
 	} else {
 		/* No cases hit !!! */
 		status = nfserr_inval;
 		goto out;
 
 	}
+	copy_verf(new, &clverifier);
+	new->cl_addr = sin->sin_addr.s_addr;
+	copy_cred(&new->cl_cred, &rqstp->rq_cred);
+	gen_confirm(new);
+	gen_callback(new, setclid);
+	add_to_unconfirmed(new, strhashval);
 	setclid->se_clientid.cl_boot = new->cl_clientid.cl_boot;
 	setclid->se_clientid.cl_id = new->cl_clientid.cl_id;
 	memcpy(setclid->se_confirm.data, new->cl_confirm.data, sizeof(setclid->se_confirm.data));
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
