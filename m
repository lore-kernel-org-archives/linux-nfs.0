From: Kevin Coffman <kwc@citi.umich.edu>
Subject: Re: NFS4 + ticket handling
Date: Mon, 15 May 2006 12:28:17 -0400
Message-ID: <20060515162817.65F0F1BBAE@citi.umich.edu>
References: <446899A3.1000402@vwi.tu-dresden.de>
Mime-Version: 1.0
Content-Type: multipart/mixed ;
	boundary="==_Exmh_1147710388_78820"
Cc: nfs@lists.sourceforge.net, Kevin Coffman <kwc@citi.umich.edu>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from [10.3.1.94] (helo=sc8-sf-list2-new.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Fffvm-0001TM-4k
	for nfs@lists.sourceforge.net; Mon, 15 May 2006 09:28:26 -0700
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fffvm-0001D9-1W
	for nfs@lists.sourceforge.net; Mon, 15 May 2006 09:28:26 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1Fffvj-0006Ci-Oq
	for nfs@lists.sourceforge.net; Mon, 15 May 2006 09:28:26 -0700
To: kolbe@vwi.tu-dresden.de
In-reply-to: <446899A3.1000402@vwi.tu-dresden.de> 
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

> I'm planing a migration from v3 to v4 on Debian 
> (Server:AMD64+Client:i386) because of the 16+ groups problem.
> So I would know something about the kerberos handling which was not 
> found in docu.
> 
> @moment I'm using kerberos for user authentication on all systems 
> against Win2003AD.
> System things (e.g nssldap) are solved via a common princ for all 
> systems "systemuser@realm" and not "systemuser/hostname@realm" because I 
> don't like to build + manage a separate keytab for every service + every 
> machine.
> Ticket is updated to a special cache via kinit -k -c /etc/.cache
> 
> Is such a solution also working with nfs4 or I have to build a special 
> keytab for nfs and every machine?


The current code will only consider a key for nfs/*.


The attached (untested) patch should use any key, but it is still
clear (to me) that we want to allow this.


--==_Exmh_1147710388_78820
Content-Type: application/x-patch ; name="gssd_use_any_keytab.patch"
Content-Description: gssd_use_any_keytab.patch
Content-Disposition: attachment; filename="gssd_use_any_keytab.patch"

---

 nfs-utils-1.0.8-kwc/utils/gssd/krb5_util.c |    4 ++++
 1 files changed, 4 insertions(+)

diff -puN utils/gssd/krb5_util.c~gssd_use_any_keytab utils/gssd/krb5_util.c
--- nfs-utils-1.0.8/utils/gssd/krb5_util.c~gssd_use_any_keytab	2006-05-15 12:22:01.042382000 -0400
+++ nfs-utils-1.0.8-kwc/utils/gssd/krb5_util.c	2006-05-15 12:23:03.646272000 -0400
@@ -444,6 +444,7 @@ gssd_process_krb5_keytab(krb5_context co
 		}
 		printerr(2, "Processing keytab entry for principal '%s'\n",
 			 pname);
+#if 0
 #ifdef HAVE_KRB5
 		if ( (kte.principal->data[0].length == GSSD_SERVICE_NAME_LEN) &&
 		     (strncmp(kte.principal->data[0].data, GSSD_SERVICE_NAME,
@@ -454,6 +455,9 @@ gssd_process_krb5_keytab(krb5_context co
 			      GSSD_SERVICE_NAME_LEN) == 0) &&
 
 #endif
+#else
+		if
+#endif
 		     (!gssd_have_realm_ple((void *)&kte.principal->realm)) ) {
 			printerr(2, "We will use this entry (%s)\n", pname);
 			ple = malloc(sizeof(struct gssd_k5_kt_princ));

_




-------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


--==_Exmh_1147710388_78820--
