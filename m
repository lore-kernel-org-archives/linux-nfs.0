From: Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH]  Reinstantiating stale inodes
Date: Mon, 03 May 2004 15:50:42 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <4096A292.8050109@RedHat.com>
References: <40892507.2030004@RedHat.com>  <4093CCB6.1040500@RedHat.com>	 <1083439518.3687.19.camel@lade.trondhjem.org> <4094397C.3030303@RedHat.com>	 <1083457337.3687.60.camel@lade.trondhjem.org> <409468B2.40200@RedHat.com> <1083468517.3687.70.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010607040404030509040308"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BKjSu-0002C8-28
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 12:51:00 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.30)
	id 1BKjSt-0003iB-M1
	for nfs@lists.sourceforge.net; Mon, 03 May 2004 12:50:59 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1083468517.3687.70.camel@lade.trondhjem.org>
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

This is a multi-part message in MIME format.
--------------010607040404030509040308
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Trond Myklebust wrote:

>I certainly would not expect any difference between the two when looking
>at the standard connectathon suite.
>  
>
Nor did I... I kinda thought it would reduce traffic.... but over the 
last few days,
I've tried a number of combinations of ctime and mtime to 1) fix the 
estale problem and
2) not added more traffic...  unfortunately with no success....

So I would like to propose a less intrusive patch what will simply zap
the directories caches when nfs_revalidate() sees an ESTALE.

This patch does not effect traffic and only the first dir entry is 
failed with ESTALE
and finally subsequent ls will not fail with ESTALEs....

Comments?

SteveD.

--------------010607040404030509040308
Content-Type: text/plain;
 name="linux-2.4.21-nfs-estale3.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="linux-2.4.21-nfs-estale3.patch"

--- linux-2.4.21/fs/nfs/inode.c.org	2004-05-03 08:57:36.000000000 -0400
+++ linux-2.4.21/fs/nfs/inode.c	2004-05-03 15:03:57.000000000 -0400
@@ -958,8 +958,16 @@ nfs_wait_on_inode(struct inode *inode, i
 int
 nfs_revalidate(struct dentry *dentry)
 {
+	int error;
 	struct inode *inode = dentry->d_inode;
-	return nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	
+	error = nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	if (error == -ESTALE) {
+		struct inode *dir = dentry->d_parent->d_inode;
+		nfs_zap_caches(dir);	
+	}
+
+	return error;
 }
 
 /*

--------------010607040404030509040308--


-------------------------------------------------------
This SF.Net email is sponsored by: Oracle 10g
Get certified on the hottest thing ever to hit the market... Oracle 10g. 
Take an Oracle 10g class now, and we'll give you the exam FREE.
http://ads.osdn.com/?ad_id=3149&alloc_id=8166&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
