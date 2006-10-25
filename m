From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/2] mountd: remove bogus mountlist_add/del calls,
	track	only v2/3 mounts
Date: Wed, 25 Oct 2006 09:07:02 -0400
Message-ID: <1161781622.7078.51.camel@dantu.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GciTR-0006cM-9j
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 06:07:13 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GciTN-0002rC-OR
	for nfs@lists.sourceforge.net; Wed, 25 Oct 2006 06:07:14 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com
	[172.16.52.254])
	by mx1.redhat.com (8.12.11.20060308/8.12.11) with ESMTP id
	k9PD73c1002053
	for <nfs@lists.sourceforge.net>; Wed, 25 Oct 2006 09:07:03 -0400
Received: from pobox.corp.redhat.com (pobox.corp.redhat.com [10.11.255.20])
	by int-mx1.corp.redhat.com (8.13.1/8.13.1) with ESMTP id k9PD72Bh001655
	for <nfs@lists.sourceforge.net>; Wed, 25 Oct 2006 09:07:02 -0400
Received: from dantu.rdu.redhat.com (dantu.rdu.redhat.com [172.16.57.196])
	by pobox.corp.redhat.com (8.13.1/8.12.8) with ESMTP id k9PD726F012126
	for <nfs@lists.sourceforge.net>; Wed, 25 Oct 2006 09:07:02 -0400
To: nfs@lists.sourceforge.net
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

This patch removes several mountlist_add and mountlist_del calls that
seem to be unnecessary. In particular, it removes these calls in a
couple of places that seem to be using it incorrectly (where it's
calling mountlist_add with the path section set to the hostname). This
patch gets rid of the lines in rmtab that look like this:

10.10.1.41:*
172.16.33.192:*
172.16.33.192:*,foo.bar.baz

Also, with this patch, NFSv4 mounts are no longer tracked in the rmtab.
In nfs4, it doesn't seem like any calls to mountd are made when a
filesystem is unmounted. Since we have no way to reliably track unmounts
of nfs4 filesystems in mountd, I figured it was best to just have mountd
not attempt to track mounts either.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

--- nfs-utils-1.0.9/utils/mountd/cache.c.mladd
+++ nfs-utils-1.0.9/utils/mountd/cache.c
@@ -83,9 +83,6 @@ void auth_unix_ip(FILE *f)
 		qword_print(f, *client?client:"DEFAULT");
 	qword_eol(f);
 
-	if (client && strcmp(ipaddr, client))
-		mountlist_add(ipaddr, *client?client:"DEFAULT");
-
 	if (client) free(client);
 	
 }
@@ -373,8 +370,6 @@ void cache_export_ent(char *domain, stru
 	qword_eol(f);
 
 	fclose(f);
-
-	mountlist_add(domain, exp->e_path);
 }
 
 void cache_export(nfs_export *exp)
@@ -393,9 +388,6 @@ void cache_export(nfs_export *exp)
 	
 	fclose(f);
 
-	if (strcmp(inet_ntoa(exp->m_client->m_addrlist[0]), exp->m_client->m_hostname))
-		mountlist_add(inet_ntoa(exp->m_client->m_addrlist[0]), exp->m_client->m_hostname);
-
 	cache_export_ent(exp->m_client->m_hostname, &exp->m_export);
 }
 
--- nfs-utils-1.0.9/utils/mountd/mountd.c.mladd
+++ nfs-utils-1.0.9/utils/mountd/mountd.c
@@ -222,17 +222,13 @@ mount_umnt_1_svc(struct svc_req *rqstp, 
 		p = rpath;
 	}
 
-	if (!(exp = auth_authenticate("unmount", sin, p))) {
+	if (!(exp = auth_authenticate("unmount", sin, p)))
 		return 1;
-	}
-	if (new_cache) {
-		if (strcmp(inet_ntoa(exp->m_client->m_addrlist[0]), exp->m_client->m_hostname))
-			mountlist_del(inet_ntoa(exp->m_client->m_addrlist[0]), exp->m_client->m_hostname);
-		mountlist_del(exp->m_client->m_hostname, p);
-	} else {
-		mountlist_del(exp->m_client->m_hostname, p);
+
+	mountlist_del(exp->m_client->m_hostname, p);
+	if (!new_cache)
 		export_reset (exp);
-	}
+
 	return 1;
 }
 
@@ -421,8 +417,11 @@ get_rootfh(struct svc_req *rqstp, dirpat
 		fh = cache_get_filehandle(exp, v3?64:32, p);
 		if (fh == NULL) 
 			*error = NFSERR_ACCES;
-		else
+		else {
 			*error = NFS_OK;
+			mountlist_add(exp->m_client->m_hostname,
+					exp->m_export.e_path);
+		}
 		return fh;
 	} else {
 		struct nfs_fh_len  *fh;



-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
