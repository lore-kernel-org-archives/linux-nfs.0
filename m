From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/3] remove extraneous mountlist_add/del calls and
 change remaining ones to use IP addresses
Date: Mon, 18 Dec 2006 15:43:56 -0500
Message-ID: <4586FD8C.2050602@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GwPL8-0006Bz-Ts
	for nfs@lists.sourceforge.net; Mon, 18 Dec 2006 12:44:02 -0800
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1GwPL9-0002Ct-Iv
	for nfs@lists.sourceforge.net; Mon, 18 Dec 2006 12:44:04 -0800
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

Neil suggested a patch to change the mountlist_add and mountlist_del calls to
use IP addresses instead of the names returned by client_compose based on a
command line option flag.

I don't see any real reason to put client_compose strings into the rmtab, so
this patch makes it so that it adds IP addresses instead of those strings to
the rmtab by default.

It also removes all mountlist_add calls that are being done from kernel cache
routines. My main concern there is NFSv4. We don't seem to make any upcalls to
mountd on NFSv4 unmounts, and I don't see a way to reliably remove NFSv4
entries. So, I figured I'd stick with having mountlist_add only called when
a v2 or v3 mount call is made, and mountlist_del called only on the
corresponding unmount call.

Neil, I'm open to respinning this so that it gets called again from the kernel
caching routines, but I'm not sure how to prevent the rmtab from growing w/o
bound that way.

Signed-off-by: Jeff Layton <jlayton@redhat.com>

--- nfs-utils-1.0.10/utils/mountd/cache.c.mlcleanup
+++ nfs-utils-1.0.10/utils/mountd/cache.c
@@ -83,9 +83,6 @@ void auth_unix_ip(FILE *f)
  		qword_print(f, *client?client:"DEFAULT");
  	qword_eol(f);

-	if (client && strcmp(ipaddr, client))
-		mountlist_add(ipaddr, *client?client:"DEFAULT");
-
  	if (client) free(client);
  	
  }
@@ -295,7 +292,6 @@ void nfsd_export(FILE *f)
  		qword_printint(f, found->m_export.e_anonuid);
  		qword_printint(f, found->m_export.e_anongid);
  		qword_printint(f, found->m_export.e_fsid);
-		mountlist_add(dom, path);
  	}
  	qword_eol(f);
   out:
@@ -373,8 +369,6 @@ void cache_export_ent(char *domain, stru
  	qword_eol(f);

  	fclose(f);
-
-	mountlist_add(domain, exp->e_path);
  }

  void cache_export(nfs_export *exp)
@@ -393,9 +387,6 @@ void cache_export(nfs_export *exp)
  	
  	fclose(f);

-	if (strcmp(inet_ntoa(exp->m_client->m_addrlist[0]), exp->m_client->m_hostname))
-		mountlist_add(inet_ntoa(exp->m_client->m_addrlist[0]), exp->m_client->m_hostname);
-
  	cache_export_ent(exp->m_client->m_hostname, &exp->m_export);
  }

--- nfs-utils-1.0.10/utils/mountd/mountd.c.mlcleanup
+++ nfs-utils-1.0.10/utils/mountd/mountd.c
@@ -225,14 +225,11 @@ mount_umnt_1_svc(struct svc_req *rqstp,
  	if (!(exp = auth_authenticate("unmount", sin, p))) {
  		return 1;
  	}
-	if (new_cache) {
-		if (strcmp(inet_ntoa(exp->m_client->m_addrlist[0]), exp->m_client->m_hostname))
-			mountlist_del(inet_ntoa(exp->m_client->m_addrlist[0]), exp->m_client->m_hostname);
-		mountlist_del(exp->m_client->m_hostname, p);
-	} else {
-		mountlist_del(exp->m_client->m_hostname, p);
+
+	if (!new_cache)
  		export_reset (exp);
-	}
+
+	mountlist_del(inet_ntoa(sin->sin_addr), p);
  	return 1;
  }

@@ -421,8 +418,10 @@ get_rootfh(struct svc_req *rqstp, dirpat
  		fh = cache_get_filehandle(exp, v3?64:32, p);
  		if (fh == NULL)
  			*error = NFSERR_ACCES;
-		else
+		else {
  			*error = NFS_OK;
+			mountlist_add(inet_ntoa(sin->sin_addr), p);
+		}
  		return fh;
  	} else {
  		struct nfs_fh_len  *fh;
@@ -443,7 +442,7 @@ get_rootfh(struct svc_req *rqstp, dirpat
  						stb.st_dev, stb.st_ino);
  		}
  		if (fh != NULL) {
-			mountlist_add(exp->m_client->m_hostname, p);
+			mountlist_add(inet_ntoa(sin->sin_addr), p);
  			*error = NFS_OK;
  			export_reset (exp);
  			return fh;

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
