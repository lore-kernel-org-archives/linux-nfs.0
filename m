From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] kNFSd - 5 of 11 - gss_svc_module_ref.patch
Date: Mon, 31 May 2004 15:33:55 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20040531193355.GB27622@fieldses.org>
References: <20040528143518.31534.patches@notabene> <E1BTZ7b-0008ES-04@notabene.cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NeilBrown <neilb@cse.unsw.edu.au>, nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BUsXu-000635-6S
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 12:34:06 -0700
Received: from dsl093-002-214.det1.dsl.speakeasy.net
	([66.93.2.214] helo=pumpkin.fieldses.org ident=Debian-exim)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.30)
	id 1BUsXt-0004TG-RV
	for nfs@lists.sourceforge.net; Mon, 31 May 2004 12:34:05 -0700
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <E1BTZ7b-0008ES-04@notabene.cse.unsw.edu.au>
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Fri, May 28, 2004 at 02:37:30PM +1000, NeilBrown wrote:
> 
> The server sunrpc code should take a reference on the relevant module before
> calling any authentication code.

That patch has two small but critical typos; could you also apply the
following?  Thanks.--Bruce Fields


Fix a null deference if svc_authorise is called twice for a request, and fix
the test in svcauth_register which otherwise causes initialization of the gss
module to fail.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>


 net/sunrpc/svcauth.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff -puN net/sunrpc/auth_gss/svcauth_gss.c~gss_svc_module_ref_fix net/sunrpc/auth_gss/svcauth_gss.c
diff -puN net/sunrpc/svcauth.c~gss_svc_module_ref_fix net/sunrpc/svcauth.c
--- linux-2.6.7-rc1/net/sunrpc/svcauth.c~gss_svc_module_ref_fix	2004-05-30 17:19:57.000000000 -0400
+++ linux-2.6.7-rc1-bfields/net/sunrpc/svcauth.c	2004-05-30 17:49:08.000000000 -0400
@@ -70,10 +70,10 @@ int svc_authorise(struct svc_rqst *rqstp
 
 	rqstp->rq_authop = NULL;
 	
-	if (aops) 
+	if (aops) {
 		rv = aops->release(rqstp);
-
-	module_put(aops->owner);
+		module_put(aops->owner);
+	}
 	return rv;
 }
 
@@ -82,7 +82,7 @@ svc_auth_register(rpc_authflavor_t flavo
 {
 	int rv = -EINVAL;
 	spin_lock(&authtab_lock);
-	if (flavor < RPC_AUTH_MAXFLAVOR && authtab[flavor] != NULL) {
+	if (flavor < RPC_AUTH_MAXFLAVOR && authtab[flavor] == NULL) {
 		authtab[flavor] = aops;
 		rv = 0;
 	}

_


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
