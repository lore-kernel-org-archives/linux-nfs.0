From: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Subject: RPCGSSD and root on Linux client
Date: Thu, 8 Mar 2007 15:58:40 -0800
Message-ID: <01AE8AF878612047A442668306EAEB055C44F8@SACEXMV01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "Burlyga, Alex" <Alex.Burlyga@netapp.com>
To: <nfs@lists.sourceforge.net>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HPSVY-0005Tn-CZ
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 15:58:52 -0800
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HPSVY-0005IA-Cz
	for nfs@lists.sourceforge.net; Thu, 08 Mar 2007 15:58:54 -0800
Received: from sacexrs02.hq.netapp.com (sacexrs02.corp.netapp.com
	[10.99.190.106])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l28Nwg6X016490
	for <nfs@lists.sourceforge.net>; Thu, 8 Mar 2007 15:58:42 -0800 (PST)
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

We've hit the following issue with root and Kerberos on the linux
client:

> I run in into interesting problem with recent change to rpcgssd on the

> linux client.
> The change itself made -m flag mandatory, meaning that for user uid = 
> 0 , different principal will be used, namely first principal specified

> in /etc/krb5.keytab which starts with nfs. From the filer perspective 
> after that change there is no way root will come in as a principal 
> over RPCSEC_GSS so, for example, root can't create a file with root as

> owner. I'm not sure how Linux nfs server handles this, but behavior 
> seems broken. Do you know what was the rationale behind this change?
> am I missing something?

Our guess at what's going on here is that gssd was changed so that
initial mounts and the automounter could acquire a cred even when there
is no root cred available on the machine.  Unfortunately, the change to
gssd maps all uid=0 requests to a non-root principal.  Currently the
code does something like this:

  if (uid == 0)
	map some non-root principal to uid 0
  else
      do normal uid->principal mapping

I'm suggesting chaging this logic to:

  do normal uid->principal mapping
  if mapping failed && uid == 0
	map some non-root principal to uid 0 (as in the original case)

So, if we have a root cred hanging around (e.g., in krb5.keytab, via
kinit, etc.), we go ahead and use it.  Otherwise, we use the existing
code to map uid 0 to some other principal.  In either case, automount,
mounts during startup, etc. should be happy, but we're still able to use
the root principal.

Patch below is **untested** but illustrates the proposed change.

We need to know if we've missed something in the reasoning for the
original change that impacts the proposed solution.  Or if the proposal
is flawed in some other respect :-)

  -Dan

 
--- gssd_proc.c.orig	2007-03-08 15:22:40.637927000 -0800
+++ gssd_proc.c	2007-03-08 15:28:00.671967000 -0800
@@ -688,6 +688,18 @@ handle_krb5_upcall(struct clnt_info *clp
 		goto out;
 	}
 
+	/* Tell krb5 gss which credentials cache to use */
+	gssd_setup_krb5_user_gss_ccache(uid, clp->servername);
+
+	if (create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
+				AUTHTYPE_KRB5) != 0 && 
+			uid != 0) {
+		printerr(0, "WARNING: Failed to create krb5 context "
+		    "for user with uid %d for server %s\n",
+			 uid, clp->servername);
+		goto out_return_error;
+	}
+
 	if (uid == 0) {
 		int success = 0;
 
@@ -723,18 +735,6 @@ handle_krb5_upcall(struct clnt_info *clp
 			goto out_return_error;
 		}
 	}
-	else {
-		/* Tell krb5 gss which credentials cache to use */
-		gssd_setup_krb5_user_gss_ccache(uid, clp->servername);
-
-		if ((create_auth_rpc_client(clp, &rpc_clnt, &auth, uid,
-							AUTHTYPE_KRB5))
!= 0) {
-			printerr(0, "WARNING: Failed to create krb5
context "
-				    "for user with uid %d for server
%s\n",
-				 uid, clp->servername);
-			goto out_return_error;
-		}
-	}
 
 	if (!authgss_get_private_data(auth, &pd)) {
 		printerr(0, "WARNING: Failed to obtain authentication "

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys-and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
