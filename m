Return-Path: linux-nfs-owner@vger.kernel.org
Received: from plane.gmane.org ([80.91.229.3]:39061 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752798AbaDRUKH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 18 Apr 2014 16:10:07 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <glN-linux-nfs@m.gmane.org>)
	id 1WbF6q-0006Q3-Rh
	for linux-nfs@vger.kernel.org; Fri, 18 Apr 2014 22:10:04 +0200
Received: from 95-89-86-106-dynip.superkabel.de ([95.89.86.106])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 22:10:04 +0200
Received: from bernd.schubert by 95-89-86-106-dynip.superkabel.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Fri, 18 Apr 2014 22:10:04 +0200
To: linux-nfs@vger.kernel.org
From: Bernd Schubert <bernd.schubert@fastmail.fm>
Subject: [PATCH] nfsd: nfsd4_decode_create: Fix a possible NULL pointer dereference
Date: Fri, 18 Apr 2014 22:06:43 +0200
Message-ID: <lis0kj$kaj$1@ger.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

While running FhGFS-to-NFS stress tests, I noticed this bug (with a 
RHEL 6.5 kernel, but I think it also in linux-git).

[ 3428.087489] BUG: unable to handle kernel paging request at ffff880735fb8000
[ 3428.094821] IP: [<ffffffffa038066e>] nfsd4_create+0x27e/0x380 [nfsd]

gdb resolves this to

(gdb) l *(nfsd4_create+0x27e)
0x1469e is in nfsd4_create (fs/nfsd/nfs4proc.c:527).
522                      * null-terminate by brute force, since at worst we
523                      * will overwrite the first byte of the create namelen
524                      * in the XDR buffer, which has already been extracted
525                      * during XDR decode.
526                      */
527                     create->cr_linkname[create->cr_linklen] = 0;
528
529                     status = nfsd_symlink(rqstp, &cstate->current_fh,
530                                           create->cr_name, create->cr_namelen,
531                                           create->cr_linkname, create->cr_linklen,


create->cr_linkname is set in nfsd4_decode_create and 
even current .git does not check for the result of savemem 
there.

--
nfsd: nfsd4_decode_create: Fix a possible NULL pointer dereference

From: Bernd Schubert <bernd.schubert@itwm.fraunhofer.de>

create->cr_linkname was later used without any check if savemem()
succeeded.


Signed-off-by: Bernd Schubert <bernd.schubert@fastmail.fm>
---
 fs/nfsd/nfs4xdr.c |    4 ++++
 1 file changed, 4 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 2723c1b..eb65d1e 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -603,6 +603,10 @@ nfsd4_decode_create(struct nfsd4_compoundargs *argp, struct nfsd4_create *create
 		READ32(create->cr_linklen);
 		READ_BUF(create->cr_linklen);
 		SAVEMEM(create->cr_linkname, create->cr_linklen);
+		status = check_filename(create->cr_linkname,
+					create->cr_linklen);
+		if (status)
+			return status;
 		break;
 	case NF4BLK:
 	case NF4CHR:

