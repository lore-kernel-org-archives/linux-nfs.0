From: Chip Salzenberg <chip@pobox.com>
Subject: ACL patch - is this bad or good?
Date: Sat, 4 Dec 2004 17:26:59 -0500
Message-ID: <20041204222659.GA5837@perlsupport.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="fUYQa+Pmc3FrFX/N"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CaiMf-0003Vr-GR
	for nfs@lists.sourceforge.net; Sat, 04 Dec 2004 14:26:53 -0800
Received: from perlsupport.com
	([66.220.6.226] helo=mail.perlsupport.com ident=Debian-exim)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:RC4-SHA:128)
	(Exim 4.41)
	id 1CaiMe-0002Ce-I2
	for nfs@lists.sourceforge.net; Sat, 04 Dec 2004 14:26:53 -0800
Received: from pcp03344017pcs.malvrn01.pa.comcast.net ([68.54.140.48] helo=tytlal)
	by mail.perlsupport.com (Exim 4) with asmtp (TLS-1.0:RSA_ARCFOUR_SHA:16)
	id 1CaiMd-0001Dt-P5
	for nfs@lists.sourceforge.net; Sat, 04 Dec 2004 14:26:52 -0800
Received: from chip by tytlal with local (Exim 4.34)
	id 1CaiMl-0001WE-LM
	for nfs@lists.sourceforge.net; Sat, 04 Dec 2004 17:26:59 -0500
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


--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi there.  A Debian user contributed a copy of what he says is a Red
Hat patch to support "acl" and "no_acl" options for NFS exports.

Is this patch OK?
-- 
Chip Salzenberg              - a.k.a. -           <chip@pobox.com>
People are supposed to die for freedom.  Not the other way around.

--fUYQa+Pmc3FrFX/N
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="nfs-utils-1.0.3-aclexport.patch"

Add `no_acl' nfs export option

This patch adds the `acl' and `no_acl' nfs export options, which replace
the nfs_permission_mode module parameter of nfsd.o. The `no_acl' option
tells nfsd to mask off acl permissions so that clients will see a subset
of permissions that is safe even with old clients. Current clients
implement the NFSv3 ACCESS RPC, and therefore do not require the
`no_acl' export option. If no acls are supported in the nfs server, the
`no_acl' export option is not needed, either.

Thanks to Steve Dickson <SteveD@redhat.com> for proposing this.


Andreas Gruenbacher <agruen@suse.de>, SuSE Labs


Index: nfs-utils-1.0.4/utils/exportfs/exportfs.c
===================================================================
--- nfs-utils-1.0.4.orig/utils/exportfs/exportfs.c	2003-07-03 03:28:53.000000000 +0200
+++ nfs-utils-1.0.4/utils/exportfs/exportfs.c	2003-07-14 12:56:26.000000000 +0200
@@ -378,6 +378,8 @@ dump(int verbose)
 				c = dumpopt(c, "no_subtree_check");
 			if (ep->e_flags & NFSEXP_NOAUTHNLM)
 				c = dumpopt(c, "insecure_locks");
+			if (ep->e_flags & NFSEXP_NOACL)
+				c = dumpopt(c, "no_acl");
 			if (ep->e_flags & NFSEXP_FSID)
 				c = dumpopt(c, "fsid=%d", ep->e_fsid);
 			if (ep->e_mountpoint)
Index: nfs-utils-1.0.4/support/nfs/exports.c
===================================================================
--- nfs-utils-1.0.4.orig/support/nfs/exports.c	2003-05-30 07:17:56.000000000 +0200
+++ nfs-utils-1.0.4/support/nfs/exports.c	2003-07-14 12:56:26.000000000 +0200
@@ -185,6 +185,8 @@ putexportent(struct exportent *ep)
 		"no_" : "");
 	fprintf(fp, "%ssecure_locks,", (ep->e_flags & NFSEXP_NOAUTHNLM)?
 		"in" : "");
+	fprintf(fp, "%sacl,", (ep->e_flags & NFSEXP_NOACL)?
+		"no_" : "");
 	if (ep->e_flags & NFSEXP_FSID) {
 		fprintf(fp, "fsid=%d,", ep->e_fsid);
 	}
@@ -374,6 +376,10 @@ parseopts(char *cp, struct exportent *ep
 			ep->e_flags &= ~NFSEXP_NOAUTHNLM;
 		else if (strcmp(opt, "insecure_locks") == 0)
 			ep->e_flags |= NFSEXP_NOAUTHNLM;
+		else if (strcmp(opt, "acl") == 0)
+			ep->e_flags &= ~NFSEXP_NOACL;
+		else if (strcmp(opt, "no_acl") == 0)
+			ep->e_flags |= NFSEXP_NOACL;
 		else if (strncmp(opt, "mapping=", 8) == 0)
 			ep->e_maptype = parsemaptype(opt+8);
 		else if (strcmp(opt, "map_identity") == 0)	/* old style */
Index: nfs-utils-1.0.4/utils/exportfs/exports.man
===================================================================
--- nfs-utils-1.0.4.orig/utils/exportfs/exports.man	2003-05-30 07:17:56.000000000 +0200
+++ nfs-utils-1.0.4/utils/exportfs/exports.man	2003-07-14 12:56:26.000000000 +0200
@@ -218,6 +218,21 @@ be explicitly requested with either of t
 .IR auth_nlm ,
 or
 .IR secure_locks .
+.TP
+.IR no_acl
+This option tells nfsd to mask off acl permissions so that clients will
+only see a subset of the permissions on the exported file system. This
+subset is safe for NFSv2 clients, and for NFSv3 clients that perform
+access decisions locally. Current NFSv3 clients use the ACCESS RPC
+to perform all access decisions on the server. The
+.I no_acl
+option should be used for nfs exports with acl support that are exported
+to NFSv2 clients, or to NFSv3 clients that don't use the ACCESS RPC.
+This option is not needed for recent NFSv3 clients or if the exported
+file system has no acl support. The default is to export with acl
+support enabled (i.e.,
+.I no_acl
+is off.)
 
 '''.TP
 '''.I noaccess

--fUYQa+Pmc3FrFX/N--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
