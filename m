From: Olaf Kirch <okir@suse.de>
Subject: Small nfs-utils patch
Date: Mon, 23 May 2005 12:15:57 +0200
Message-ID: <20050523101557.GD24634@suse.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="sm4nu43k4a2Rpi4c"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Da9ya-0008N6-UT
	for nfs@lists.sourceforge.net; Mon, 23 May 2005 03:16:00 -0700
Received: from mx2.suse.de ([195.135.220.15])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1Da9ya-0002kK-68
	for nfs@lists.sourceforge.net; Mon, 23 May 2005 03:16:00 -0700
Received: from hermes.suse.de (hermes-ext.suse.de [195.135.221.8])
	(using TLSv1 with cipher EDH-RSA-DES-CBC3-SHA (168/168 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 18656109C5
	for <nfs@lists.sourceforge.net>; Mon, 23 May 2005 12:15:58 +0200 (CEST)
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


--sm4nu43k4a2Rpi4c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Without this patch, showmount -e would sometimes display
host names that should really have been subsumed under a
wildcard entry.

The problem was that the code in get_exportlist would always
skip the next group entry after removing one FQDN.

Olaf
-- 
Olaf Kirch   |  --- o --- Nous sommes du soleil we love when we play
okir@suse.de |    / | \   sol.dhoop.naytheet.ah kin.ir.samse.qurax

--sm4nu43k4a2Rpi4c
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="nfs-utils-1.0.6-showmount.patch"


Without this patch, showmount -e would sometimes display
host names that should really have been subsumed under a
wildcard entry.

The problem was that the code in get_exportlist would always
skip the next group entry after removing one FQDN.

Signed-off-by: Olaf Kirch <okir@suse.de>

Index: nfs-utils-1.0.7/utils/mountd/mountd.c
===================================================================
--- nfs-utils-1.0.7.orig/utils/mountd/mountd.c
+++ nfs-utils-1.0.7/utils/mountd/mountd.c
@@ -409,11 +409,9 @@ get_exportlist(void)
 				xfree(c->gr_name);
 				xfree(c);
 				xfree (hp);
-				if ((c = *cp) == NULL)
-				  break;
+				continue;
 			      }
-			      else
-				xfree (hp);
+			      xfree (hp);
 			    }
 			    cp = &(c->gr_next);
 			  }

--sm4nu43k4a2Rpi4c--


-------------------------------------------------------
This SF.Net email is sponsored by Oracle Space Sweepstakes
Want to be the first software developer in space?
Enter now for the Oracle Space Sweepstakes!
http://ads.osdn.com/?ad_id=7412&alloc_id=16344&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
