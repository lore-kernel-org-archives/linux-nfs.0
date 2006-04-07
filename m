From: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Subject: vfs_rmdir race with nfsd
Date: Fri, 07 Apr 2006 13:33:57 +0900
Message-ID: <1144384437.439380.7022.nullmailer@yamt.dyndns.org>
Mime-Version: 1.0
Content-Type: Multipart/Mixed; boundary="NextPart-20060407131525-0403800"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1FRift-0008IV-GH
	for nfs@lists.sourceforge.net; Thu, 06 Apr 2006 21:34:21 -0700
Received: from fla1abg085.kng.mesh.ad.jp ([219.107.209.85] helo=yamt.dyndns.org)
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1FRifs-0007LK-8g
	for nfs@lists.sourceforge.net; Thu, 06 Apr 2006 21:34:21 -0700
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

--NextPart-20060407131525-0403800
Content-Type: Text/Plain; charset=us-ascii

hi,

the attached diff is to fix a race with nfsd.

if someone (ie. nfsd) dget the dentry in the meantime,
it can stay unhashed and can cause directory dentry aliases later.
i chose this mailing list because i think it can't happen without
nfsd involved.

although the diff is against a locally modified version of 2.4.24,
i think that the same problem exists in both of 2.4.30 and 2.6.16.

YAMAMOTO Takashi

--NextPart-20060407131525-0403800
Content-Type: Text/Plain; charset=us-ascii
Content-Disposition: attachment; filename="a.diff"

--- ./fs/namei.c.BACKUP	Wed Apr  5 19:43:27 2006
+++ ./fs/namei.c	Thu Apr  6 12:08:15 2006
@@ -1424,6 +1424,8 @@ int vfs_rmdir(struct inode *dir, struct 
 	if (!error) {
 		inode_dir_notify(dir, DN_DELETE);
 		d_delete(dentry);
+	} else if (d_unhashed(dentry)) {
+		d_rehash(dentry);
 	}
 	dput(dentry);
 

--NextPart-20060407131525-0403800--


-------------------------------------------------------
This SF.Net email is sponsored by xPML, a groundbreaking scripting language
that extends applications into web and mobile media. Attend the live webcast
and join the prime developer group breaking into this new coding territory!
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=110944&bid=241720&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
