Return-Path: linux-nfs-owner@vger.kernel.org
Received: from aserp1040.oracle.com ([141.146.126.69]:18177 "EHLO
	aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161917Ab3LFNVJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 6 Dec 2013 08:21:09 -0500
Message-ID: <52A1CF22.106@oracle.com>
Date: Fri, 06 Dec 2013 17:20:34 +0400
From: Stanislav Kholmanskikh <stanislav.kholmanskikh@oracle.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: xfs@oss.sgi.com, linux-nfs@vger.kernel.org,
        Vasily Isaenko <vasily.isaenko@oracle.com>
Subject: Re: nfs vs xfstests 193
References: <20131106115648.GA24804@infradead.org>
In-Reply-To: <20131106115648.GA24804@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 11/06/2013 03:56 PM, Christoph Hellwig wrote:
> I've noticed that xfstests 193 fails when run over NFS talking to an
> XFS-based Linux server.  The test checks that we behave correctly
> vs Posix 1003.1 for the various operations that end up in ->setattr.
>
> Without the no_root_squash export flag we're not even able to run
> something resembling the test as we get permission problems all through
> it, see the first attachment for details.
>
> With the root_squash export op we fail to clear the setuid/setgid
> bits in various truncate and chown subtests, see the second attachment
> for details.
Hi!

I've come across  the same issue. But NFS server is backed by ext4 file 
system in my environment.

The test case quotes POSIX:

"If the specified file is a regular file, one or more of the S_IXUSR, 
S_IXGRP, or S_IXOTH bits of the
file mode are set, and the process has appropriate privileges, it is 
implementation-defined whether the set-user-ID and set-group-ID
bits are altered."

So the difference that what we have now:

between nfs:
~# touch file; chmod ug+s file; chmod u+x file; ls -l file; chown root 
file; ls -l file; rm -f file
-rwsr-Sr-- 1 root root 0 Dec  6 04:49 file
-rwsr-Sr-- 1 root root 0 Dec  6 04:49 file

and ext3, ext4, xfs, btrfs:
~# touch file; chmod ug+s file; chmod u+x file; ls -l file; chown root 
file; ls -l file; rm -f file
-rwsr-Sr-- 1 root root 0 Dec  6 04:49 file
-rwxr-Sr-- 1 root root 0 Dec  6 04:49 file

is not a violation of this POSIX statement. But It's just an 
"implementation-defined" behaviour.

I suppose that the difference raises because of this part of code in 
fs/nfsd/vfs.c:

         /* Revoke setuid/setgid on chown */
         if (!S_ISDIR(inode->i_mode) &&
             (((iap->ia_valid & ATTR_UID) && !uid_eq(iap->ia_uid, 
inode->i_uid)) ||
              ((iap->ia_valid & ATTR_GID) && !gid_eq(iap->ia_gid, 
inode->i_gid)))) {
                 iap->ia_valid |= ATTR_KILL_PRIV;
                 if (iap->ia_valid & ATTR_MODE) {
                         /* we're setting mode too, just clear the s*id 
bits */
                         iap->ia_mode &= ~S_ISUID;
                         if (iap->ia_mode & S_IXGRP)
                                 iap->ia_mode &= ~S_ISGID;
                 } else {
                         /* set ATTR_KILL_* bits and let VFS handle it */
                         iap->ia_valid |= (ATTR_KILL_SUID | ATTR_KILL_SGID);
                 }
         }

uid_eq() and gid_eq() checkings allow removal of s*id bits only if the 
owner/group of the file is changed during chown().

I.e. on nfs:
~# touch file; chmod ug+s file; chmod u+x file; ls -l file; chown bin 
file; ls -l file; rm -f file
-rwsr-Sr-- 1 root root 0 Dec  6 05:02 file
-rwxr-Sr-- 1 bin root 0 Dec  6 05:02 file

Is it acceptable to change NFS kernel server behaviour by removal of 
!uid_eq(iap->ia_uid, inode->i_uid) and !gid_eq(iap->ia_gid, 
inode->i_gid) from the condition above?

Just to make the behaviour more consistent between NFS and other "local" 
file systems as It was done by
commit 
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/commit/?id=0953e620de0538cbd081f1b45126f6098112a598

Thank you!



