From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Inconsistent setattr behaviour
Date: Mon, 23 Feb 2009 08:52:55 -0800
Message-ID: <1235407975.7598.4.camel@heimdal.trondhjem.org>
References: <49A2CD2B.50607@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs@vger.kernel.org
To: "Sachin S. Prabhu" <sprabhu@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:40415 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753109AbZBWQxD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 23 Feb 2009 11:53:03 -0500
In-Reply-To: <49A2CD2B.50607@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2009-02-23 at 16:22 +0000, Sachin S. Prabhu wrote:
> There is an inconsistency seen in the behaviour of nfs compared to other local
> filesystems on linux when changing owner or group of a directory. If the
> directory has SUID/SGID flags set, on changing owner or group on the directory,
> the flags are stripped off on nfs. These flags are maintained on other
> filesystems such as ext3.
> 
> To reproduce on a nfs share or local filesystem, run the following commands
> mkdir test; chmod +s+g test; chown user1 test; ls -ld test
> 
> On the nfs share, the flags are stripped and the output seen is
> drwxr-xr-x 2 user1 root 4096 Feb 23  2009 test
> 
> On other local filesystems(ex: ext3), the flags are not stripped and the output
> seen is
> drwsr-sr-x 2 user1 root 4096 Feb 23 13:57 test
> 
> chown_common() called from sys_chown() will only strip the flags if the inode is
> not a directory.
> static int chown_common(struct dentry * dentry, uid_t user, gid_t group)
> {
> ..
>         if (!S_ISDIR(inode->i_mode))
>                 newattrs.ia_valid |=
>                         ATTR_KILL_SUID | ATTR_KILL_SGID | ATTR_KILL_PRIV;
> ..
> }
> 
> See: http://www.opengroup.org/onlinepubs/7990989775/xsh/chown.html
> 
> "If the path argument refers to a regular file, the set-user-ID (S_ISUID) and
> set-group-ID (S_ISGID) bits of the file mode are cleared upon successful return
> from chown(), unless the call is made by a process with appropriate privileges,
> in which case it is implementation-dependent whether these bits are altered. If
> chown() is successfully invoked on a file that is not a regular file, these
> bits may be cleared. These bits are defined in <sys/stat.h>."
> 
> The behaviour as it stands does not appear to violate POSIX.  However the
> actions performed are inconsistent when comparing ext3 and nfs.

Does this patch retain the behaviour that we strip suid/sgid bits on
executable files?

IOW: Is the following property retained

root@heimdal:~# touch /tmp/gnurr; chmod a+x,+s+g /tmp/gnurr; chown
bin /tmp/gnurr
root@heimdal:~# ls -l /tmp/gnurr
-rwxr-xr-x 1 bin root 0 2009-02-23 08:49 /tmp/gnurr


Trond

