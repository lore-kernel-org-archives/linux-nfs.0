From: Kenneth Sumrall <ksumrall@pacbell.net>
Subject: NFSD SGID permission problem
Date: Thu, 31 Mar 2005 17:25:39 -0800
Message-ID: <424CA313.8030508@pacbell.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060600090107010204060900"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DHAut-0005dj-NL
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 17:25:43 -0800
Received: from gateway-1237.mvista.com ([12.44.186.158] helo=av.mvista.com)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1DHAur-0001LK-Hj
	for nfs@lists.sourceforge.net; Thu, 31 Mar 2005 17:25:43 -0800
Received: from pacbell.net (av [127.0.0.1])
	by av.mvista.com (8.9.3/8.9.3) with ESMTP id RAA02061
	for <nfs@lists.sourceforge.net>; Thu, 31 Mar 2005 17:25:39 -0800
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


This is a multi-part message in MIME format.
--------------060600090107010204060900
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

So, I sent the message below on 12/10/04, and got no response.  So, I'm
resending it again.  I'd like some feedback on this as I'm not sure my
fix doesn't create a security hole.

Thanks!

Ken Sumrall
ksumrall@pacbell.net

=======================================================================

Hello,

I've been running the Linux Test Package on a system with NFS root,
and one of the errors it found I think is a bug in the kernel NFSD.

The test is chown02, and it tests two things.  Quoting from the comments
in the test case, it tests:

   * Test Description:
   *  Verify that, when chown(2) invoked by super-user to change the owner and
   *  group of a file specified by path to any numeric owner(uid)/group(gid)
   *  values,
   *      - clears setuid and setgid bits set on an executable file.
   *      - preserves setgid bit set on a non-group-executable file.

The second test case is the one that fails.  In the example, if a file
has these permissions and owners:
    -rwx--S---    1 root     root            0 Dec 10 17:39 /tmp/testfile2

and chown(2) is called to change the owner/group to 700:701, the resulting
file should look like this:
    -rwx--S---    1 700      701             0 Dec 10 17:39 /tmp/testfile2

On an NFS mounted filesystem (with no_root_squash enabled, so I'm still
root across the mount) I get this:
    -rwx------    1 700      701             0 Dec 10 17:39 /tmp/testfile2

After a brief search for SGID in the nfsd code, I removed a few lines of code
from linux/fs/nfsd/vfs.c (see attached patch) and I started to get the right
results.  The underlying filesystem appears to properly enforce clearing
of the SGID bit when the group execute bit is set, and leave the SGID alone
when the group execute bit is not set.  I did this work on my Redhat 9.0
workstation which was the NFS server for these tests, so the patch is
against a 2.4.20 kernel, but the same code is in 2.4.28, and similar code
is in 2.6.9.  The underlying filesystem NFSD was exporting was ext3.

So, the question is, is this patch the proper fix?  The code to keep the SGID
bit if group execute is not present is in linux/fs/open.c, and the comment says:
          /*
           * Likewise, if the user or group of a non-directory has been changed
           * by a non-root user, remove the setgid bit UNLESS there is no group
           * execute bit (this would be a file marked for mandatory locking).
           * 19981026     David C Niemi <niemi@tux.org>
           *

so it appears to be common code, and not dependent on the underlying filesystem.

I'm no NFS expert, so I'm looking for comments and feedback.

Thanks!

Ken Sumrall
ksumrall@pacbell.net



--------------060600090107010204060900
Content-Type: text/plain;
 name="nfsd.chown.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="nfsd.chown.patch"

Index: linux/fs/nfsd/vfs.c
===================================================================
RCS file: /cvsdev/mvl-kernel/linux/fs/nfsd/vfs.c,v
retrieving revision 1.3
diff -u -r1.3 vfs.c
--- linux/fs/nfsd/vfs.c	17 Dec 2002 18:21:16 -0000	1.3
+++ linux/fs/nfsd/vfs.c	11 Dec 2004 01:56:26 -0000
@@ -277,18 +277,6 @@
 		imode = iap->ia_mode |= (imode & ~S_IALLUGO);
 	}
 
-	/* Revoke setuid/setgid bit on chown/chgrp */
-	if ((iap->ia_valid & ATTR_UID) && (imode & S_ISUID)
-	 && iap->ia_uid != inode->i_uid) {
-		iap->ia_valid |= ATTR_MODE;
-		iap->ia_mode = imode &= ~S_ISUID;
-	}
-	if ((iap->ia_valid & ATTR_GID) && (imode & S_ISGID)
-	 && iap->ia_gid != inode->i_gid) {
-		iap->ia_valid |= ATTR_MODE;
-		iap->ia_mode = imode &= ~S_ISGID;
-	}
-
 	/* Change the attributes. */
 
 


--------------060600090107010204060900--



-------------------------------------------------------
This SF.net email is sponsored by Demarc:
A global provider of Threat Management Solutions.
Download our HomeAdmin security software for free today!
http://www.demarc.com/Info/Sentarus/hamr30
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
