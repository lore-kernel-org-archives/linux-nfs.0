From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH kNFSd 012 of 26] svcrpc: gss: svc context creation error handling
Date: Fri, 13 Jan 2006 12:00:58 +1100
Message-ID: <1060113010058.23072@cse.unsw.edu.au>
References: <20060113115744.22704.patches@notabene>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1ExDJR-0002ZF-Sn
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:05 -0800
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.59] ident=root)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1ExDJR-0006lE-9V
	for nfs@lists.sourceforge.net; Thu, 12 Jan 2006 17:01:06 -0800
Received: From
	smtp-dist.unsw.edu.au ([149.171.97.17] == smtp-dist-02.services.comms.unsw.EDU.AU)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:01:01 +1100
Received: From
	neil.brown.name ([220.233.11.133] == 133.11.233.220.exetel.com.au) (auth-user neilb)
	(for <nfs@lists.sourceforge.net>) By tone With Smtp ;
	Fri, 13 Jan 2006 12:00:59 +1100
To: nfs@lists.sourceforge.net
Sender: nfs-admin@lists.sourceforge.net
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


Allow mechanisms to return more varied errors on the context creation downcall.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Neil Brown <neilb@suse.de>

### Diffstat output
 ./net/sunrpc/auth_gss/svcauth_gss.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff ./net/sunrpc/auth_gss/svcauth_gss.c~current~ ./net/sunrpc/auth_gss/svcauth_gss.c
--- ./net/sunrpc/auth_gss/svcauth_gss.c~current~	2006-01-13 11:51:06.000000000 +1100
+++ ./net/sunrpc/auth_gss/svcauth_gss.c	2006-01-13 11:51:07.000000000 +1100
@@ -420,7 +420,8 @@ static int rsc_parse(struct cache_detail
 			gss_mech_put(gm);
 			goto out;
 		}
-		if (gss_import_sec_context(buf, len, gm, &rsci.mechctx)) {
+		status = gss_import_sec_context(buf, len, gm, &rsci.mechctx);
+		if (status) {
 			gss_mech_put(gm);
 			goto out;
 		}


-------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc. Do you grep through log files
for problems?  Stop!  Download the new AJAX search engine that makes
searching your log files as easy as surfing the  web.  DOWNLOAD SPLUNK!
http://ads.osdn.com/?ad_id=7637&alloc_id=16865&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
