From: Igor Zhbanov <izh1979@gmail.com>
Subject: VFS, NFS security bug? Should CAP_MKNOD and CAP_LINUX_IMMUTABLE be
	added to CAP_FS_MASK?
Date: Thu, 12 Mar 2009 15:25:39 +0300
Message-ID: <f44001920903120525h1a62b641p4a7894d86a41192b@mail.gmail.com>
References: <f44001920903110553t52ce0ba7l4ba97213e1c51873@mail.gmail.com>
	 <f44001920903120446k47590437q95242f7a55c11d57@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f176.google.com ([209.85.220.176]:50417 "EHLO
	mail-fx0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753926AbZCLMZo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Mar 2009 08:25:44 -0400
Received: by fxm24 with SMTP id 24so364175fxm.37
        for <linux-nfs@vger.kernel.org>; Thu, 12 Mar 2009 05:25:39 -0700 (PDT)
In-Reply-To: <f44001920903120446k47590437q95242f7a55c11d57-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello!

(I have sent this letter to linux-kernel and linux-fsdevel mailing
lists but don't know where to send better.)

It seems that CAP_MKNOD and CAP_LINUX_IMMUTABLE were forgotten to be
added to CAP_FS_MASK_B0 in linux-2.6.x and to CAP_FS_MASK in
linux-2.4.x. Both capabilities affects file system and can be
considered file system capabilities.

Let's look at linux-2.6.x.

In include/linux/capability.h CAP_FS_SET is defined to contain
following capabilities:
CAP_CHOWN, CAP_DAC_OVERRIDE, CAP_DAC_READ_SEARCH, CAP_FOWNER,
CAP_FSETID and CAP_MAC_OVERRIDE.

And CAP_NFSD_SET is defined to be the same plus CAP_SYS_RESOURCE.

So, both CAP_FS_SET and CAP_NFSD_SET doesn't include CAP_MKNOD and
CAP_LINUX_IMMUTABLE.

Also include/linux/capability.h there are cap_drop_fs_set(...),
cap_raise_fs_set(...),
cap_drop_nfsd_set(...) and cap_raise_nfsd_set(...) inline functions that return
corresponding capabilities sets.

Let's look how these functions are used.

In file fs/nfsd/auth.c function nfsd_setuser(...) calls
cap_raise_nfsd_set(...) and
cap_drop_nfsd_set(...) to add/exclude corresponding capabilities to/from
effective set of current nfsd process.

And in file security/commoncap.c function cap_task_post_setuid(...) calls
cap_drop_fs_set(...) and cap_raise_fs_set(...) to change effective set
of current task
when (current->fsuid != old_ruid).

In linux-2.4.x the story is the same.

In file include/linux/capability.h CAP_FS_MASK is defined to contain
CAP_CHOWN, CAP_DAC_OVERRIDE, CAP_DAC_READ_SEARCH, CAP_FOWNER, CAP_FSETID
capabilities.

And in file fs/nfsd/auth.c CAP_NFSD_MASK is defined to be same as CAP_FS_MASK
plus CAP_SYS_RESOURCE.

In file fs/nfsd/auth.c function nfsd_setuser(...) uses CAP_NFSD_MASK
to add/exclude corresponding capabilities to/from effective set of current
nfsd process.

And CAP_FS_MASK used in file kernel/sys.c in function sys_setfsuid(...)
to add/exclude corresponding capabilities to/from effective set of current task.

This can be exploited (and I have succesfully tried it).

Suppose you have NFS-share exported even with root_squash option.
If one client was compromised, local root can set CAP_MKNOD to some
local user's process. Then that user can execute mknod to create a device
that will be owned by that user, e.g. block device file for /dev/hda hard drive.

And he can create that device file on NFS-share (even exported with root_squash
option). After that he can someway (ssh, cgi) execute code on another nfs client
or the server to modify it's filesystem. It will be possible because
he owns that
device file on nfs share.

The problem is because CAP_MKNOD allows that user to successfully execute
vfs_mknod(...) function on local host, and that function will call corresponding
function in nfs module which sends request to NFS server. And nfsd will not
drop CAP_MKNOD in nfsd_setuser(...) function when impersonating to that user.

Of course, NFS-shares can be mounted with nodev option, but they should be
placed on separate partition on NFS-server, so even on server that partition
is mounted with nodev option too.

Also this potentially can be exploited whet some root-setuid binary
calls setfsuid(...)
function to drop privileges, but CAP_MKNOD will not be dropped.

So I suggest to add CAP_MKNOD and CAP_LINUX_IMMUTABLE to CAP_FS_MASK
in linux-2.4.x and to CAP_FS_MASK_B0 in linux-2.6.x.

What do you think? Should CAP_FS_MASK be fixed or it is just NFS problem and
one need to fix CAP_NFSD_SET (and CAP_NFSD_MASK in linux-2.4)?
