From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: 2.4 vs. 2.6 nfs client performance
Date: Fri, 14 Nov 2003 16:11:34 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <16309.17670.931812.401791@charged.uio.no>
References: <3FB27670.4C878A84@psu.edu>
	<shssmkttk34.fsf@charged.uio.no>
	<3FB29D43.A618973D@psu.edu>
	<16306.41898.291062.36209@charged.uio.no>
	<3FB2A738.3F2C90B8@psu.edu>
	<16306.49310.195265.145519@charged.uio.no>
	<3FB2DC60.FA7D3E08@psu.edu>
	<16306.59249.857512.354675@charged.uio.no>
	<3FB3924B.7450E9F7@psu.edu>
	<3FB3FDE8.47E819FF@psu.edu>
	<16308.8254.89284.377113@charged.uio.no>
	<3FB520E4.133AF7DB@psu.edu>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AKlEI-0008Le-00
	for <nfs@lists.sourceforge.net>; Fri, 14 Nov 2003 13:11:46 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.24)
	id 1AKlEI-0008V7-D2
	for nfs@lists.sourceforge.net; Fri, 14 Nov 2003 13:11:46 -0800
To: Jason Holmes <jholmes@psu.edu>
In-Reply-To: <3FB520E4.133AF7DB@psu.edu>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

>>>>> " " == Jason Holmes <jholmes@psu.edu> writes:

     > Files should be up there (http://magicbus.cac.psu.edu/nfs).  I
     > do have to admit that something odd is going on - 2.4.22 still
     > is faster than 2.6.0-test9-bk17 and test9-bk17 is still showing
     > the large amount of commits, but both of them are running
     > faster than they did before on the sync mounts and I'm not sure
     > what I might have changed to cause this.

Hmm... It looks like you are doing a succession of 4k commits. I'll
bet the read() code is involved in this...

Could you try the following patch and see if it improves things?

Cheers,
  Trond

--- linux-2.6.0-test9/fs/nfs/write.c.orig	2003-11-13 18:39:34.000000000 -0500
+++ linux-2.6.0-test9/fs/nfs/write.c	2003-11-14 16:04:58.000000000 -0500
@@ -1103,7 +1103,7 @@
 			error = nfs_flush_file(inode, file, idx_start, npages, how);
 #if defined(CONFIG_NFS_V3) || defined(CONFIG_NFS_V4)
 		if (error == 0)
-			error = nfs_commit_file(inode, file, idx_start, npages, how);
+			error = nfs_commit_file(inode, file, 0, 0, how);
 #endif
 	} while (error > 0);
 	return error;


-------------------------------------------------------
This SF. Net email is sponsored by: GoToMyPC
GoToMyPC is the fast, easy and secure way to access your computer from
any Web browser or wireless device. Click here to Try it Free!
https://www.gotomypc.com/tr/OSDN/AW/Q4_2003/t/g22lp?Target=mm/g22lp.tmpl
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
