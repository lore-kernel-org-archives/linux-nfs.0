From: "Shantanu Goel" <Shantanu.Goel@lehman.com>
Subject: [NFS PATCH] 2.6.0-test10 Invalidate cached inode attributes
 after rename
Date: Wed, 26 Nov 2003 14:41:45 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <3FC501F9.1050306@lehman.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=iso-8859-1;
 format=flowed
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list1.sourceforge.net with esmtp
	(Cipher TLSv1:DES-CBC3-SHA:168) (Exim 3.31-VA-mm2 #1 (Debian))
	id 1AP5b3-0000MB-00
	for <nfs@lists.sourceforge.net>; Wed, 26 Nov 2003 11:45:09 -0800
Received: from mail-red.bigfish.com ([216.148.222.61] helo=mail4-red-R.bigfish.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.24)
	id 1AP5b3-0004k1-Ja
	for nfs@lists.sourceforge.net; Wed, 26 Nov 2003 11:45:09 -0800
Received: from mail4-red.bigfish.com (localhost.localdomain [127.0.0.1])
	by mail4-red-R.bigfish.com (Postfix) with ESMTP id B0F2C13F36A
	for <nfs@lists.sourceforge.net>; Wed, 26 Nov 2003 19:45:03 +0000 (UCT)
Received: from extrelay4.lehman.com (unknown [192.147.57.134])
	by mail4-red.bigfish.com (Postfix) with ESMTP id 68F9B13F471
	for <nfs@lists.sourceforge.net>; Wed, 26 Nov 2003 19:41:53 +0000 (UCT)
To: nfs@lists.sourceforge.net
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

Hi Trond et al,

The following one line patch invalidates the attributes of the 
underlying inode when a file is renamed.  Some filesystems update ctime 
upon rename().  One such filesystem is ext3, and a comment in the 
relevant code there indicates this is true with other Unix filesystems 
as well.
The following problem was observed on Fedora Core 1 running a stock 
kernel.org 2.6.0-test10.
The server is running Solaris 2.8 but I have verified the same issue 
exists with a server running Linix 2.4.22.  These operations a done via 
a Perl script.

1. Check out a CVS repository into an NFS mounted directory.
2. Move files from CVS working directory into another directory in the 
same filesystem.
3. Tar up the resultant directory.
4. Tar prints lots of "file changed after we read it" messages.

Tar obtains ctime via stat() before reading the file and compares it to 
the ctime obtained via fstat() after having read the file.  The two 
differ because the intervening open() forces an attribute refresh due to 
CTO consistency at which time ctime is updated.  Forcing a cache 
invalidation during rename() eliminates this particular scenario.

Thanks,
Shantanu

--- 2.6.0-test10/fs/nfs/dir.c.~1~    2003-10-17 17:43:11.000000000 -0400
+++ 2.6.0-test10/fs/nfs/dir.c    2003-11-26 12:42:27.000000000 -0500
@@ -1257,6 +1257,7 @@
 
     nfs_zap_caches(new_dir);
     nfs_zap_caches(old_dir);
+    NFS_CACHEINV(old_inode);
     error = NFS_PROTO(old_dir)->rename(old_dir, &old_dentry->d_name,
                        new_dir, &new_dentry->d_name);
 out:



------------------------------------------------------------------------------
This message is intended only for the personal and confidential use of the
designated recipient(s) named above.  If you are not the intended recipient of
this message you are hereby notified that any review, dissemination,
distribution or copying of this message is strictly prohibited.  This
communication is for information purposes only and should not be regarded as
an offer to sell or as a solicitation of an offer to buy any financial
product, an official confirmation of any transaction, or as an official
statement of Lehman Brothers.  Email transmission cannot be guaranteed to be
secure or error-free.  Therefore, we do not represent that this information is
complete or accurate and it should not be relied upon as such.  All
information is subject to change without notice.



-------------------------------------------------------
This SF.net email is sponsored by: SF.net Giveback Program.
Does SourceForge.net help you be more productive?  Does it
help you create better code?  SHARE THE LOVE, and help us help
YOU!  Click Here: http://sourceforge.net/donate/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
