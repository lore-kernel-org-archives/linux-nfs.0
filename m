From: "Jeremy Kusnetz" <JKusnetz@nrtc.org>
Subject: RE: Chrooted BIND broke on NFS server between kernel 2.4.21 and 2.4.22
Date: Fri, 12 Dec 2003 18:02:15 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <F7F4B5EA9EBD414D8A0091E80389450569D3D1@exchange.nrtc.coop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.24)
	id 1AUwIh-0006ls-E7
	for nfs@lists.sourceforge.net; Fri, 12 Dec 2003 15:02:23 -0800
Received: from outmail.nrtc.org ([204.145.144.17] helo=exchange.nrtc.coop)
	by sc8-sf-mx1.sourceforge.net with esmtp (Exim 4.24)
	id 1AUwIh-0005ZQ-2n
	for nfs@lists.sourceforge.net; Fri, 12 Dec 2003 15:02:23 -0800
To: "Jeremy Kusnetz" <JKusnetz@nrtc.org>,
	<nfs@lists.sourceforge.net>
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

> I've done some more digging, apparently things broke with 2.4.22-pre1

Okay, I've found the diff that causes this problem.  I removed it from =
the pre1 patch, and I was able to start named. That's about all I can =
do, no idea how to fix it:

diff -Naur -X /home/marcelo/lib/dontdiff linux-2.4.21/fs/nfsd/nfsfh.c =
linux-2.4.22-pre1/fs/nfsd/nfsfh.c
--- linux-2.4.21/fs/nfsd/nfsfh.c        2003-06-20 21:57:02.000000000 =
+0000
+++ linux-2.4.22-pre1/fs/nfsd/nfsfh.c   2003-06-20 21:59:08.000000000 =
+0000
@@ -697,33 +697,23 @@
        error =3D 0;

        if (!(exp->ex_flags & NFSEXP_NOSUBTREECHECK)) {
-               if (exp->ex_dentry !=3D dentry) {
-                       struct dentry *tdentry =3D dentry;
+               struct dentry *tdentry =3D dentry;

-                       do {
-                               tdentry =3D tdentry->d_parent;
-                               if (exp->ex_dentry =3D=3D tdentry)
-                                       break;
-                               /* executable only by root and we can't =
be root */
-                               if (current->fsuid
-                                   && (exp->ex_flags & =
NFSEXP_ROOTSQUASH)
-                                   && !(tdentry->d_inode->i_uid
-                                        && (tdentry->d_inode->i_mode & =
S_IXUSR))
-                                   && !(tdentry->d_inode->i_gid
-                                        && (tdentry->d_inode->i_mode & =
S_IXGRP))
-                                   && !(tdentry->d_inode->i_mode & =
S_IXOTH)
-                                       ) {
-                                       error =3D nfserr_stale;
-                                       dprintk("fh_verify: no =
root_squashed access.\n");
-                               }
-                       } while ((tdentry !=3D tdentry->d_parent));
-                       if (exp->ex_dentry !=3D tdentry) {
-                               error =3D nfserr_stale;
-                               printk("nfsd Security: %s/%s bad =
export.\n",
-                                      dentry->d_parent->d_name.name,
-                                      dentry->d_name.name);
-                               goto out;
-                       }
+               while (tdentry !=3D exp->ex_dentry && !IS_ROOT(tdentry)) =
{
+                       struct dentry *parent =3D tdentry->d_parent;
+
+                       /* make sure parents give x permission to user =
*/
+                       error =3D permission(parent->d_inode, MAY_EXEC);
+                       if (error)
+                               break;
+                       tdentry =3D parent;
+               }
+               if (exp->ex_dentry !=3D tdentry) {
+                       error =3D nfserr_stale;
+                       printk("fh_verify: no root_squashed access at =
%s/%s.\n",
+                              dentry->d_parent->d_name.name,
+                              dentry->d_name.name);
+                       goto out;
                }
        }



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
