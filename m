Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:35756 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1725886AbeGaWxM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 31 Jul 2018 18:53:12 -0400
From: Mark Fasheh <mfasheh@suse.de>
To: Al Viro <viro@ZenIV.linux.org.uk>, linux-fsdevel@vger.kernel.org
Cc: linux-btrfs@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Amir Goldstein <amir73il@gmail.com>,
        linux-unionfs@vger.kernel.org, Jeff Mahoney <jeffm@suse.com>,
        linux-nfs@vger.kernel.org
Subject: [RFC PATCH 0/4] vfs: map unique ino/dev pairs for user space
Date: Tue, 31 Jul 2018 14:10:41 -0700
Message-Id: <20180731211045.5671-1-mfasheh@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi,

These patches are follow-up to this conversation on fsdevel which provides a
good break-down of the core problem:

https://www.spinics.net/lists/linux-fsdevel/msg128003.html

That e-mail was in turn a follow-up to the following patch series:

https://lwn.net/Articles/753917/

which tried to solve the dev portion of this problem with a bit of structure
re-routing but was never accepted.


We have an inconsistency in how the kernel is exporting inode number /
device pairs for user space.  I'm not talking about stat(2) or statx(2) here
but everywhere else where an ino/dev is exported into a buffer for user
space.

We typically do this by simply dumping the potentially 32 bit inode->i_ino
and single device from super->s_dev.  Sometimes these values differ from
what is returned via stat(2) or statx(2).  Some filesystems might even show
duplicate (but internally different!) pairs when the raw i_ino/s_dev is
used.

Aside from breaking software which expects these pairs to be unique, this
can put the user in a situation where they might not be able to find an
inode referenced from some kernel log (be it /proc/, printk buffer, etc). 
What's even worse - depending on how ino is exported, they might even find
an existing but /wrong/ file.

The following patches fix these inconsistencies by introducing a VFS helper
function which calls the underlying filesystem ->getattr to get our real
inode number / device pair.  The returned values can then be used at those
places in the kernel where we are incorrectly reporting our ino/dev pair. 
We then update fs/proc/ and fs/locks.c to use this helper when writing to
/proc/PID/maps and /proc/locks respectively.


For anyone who is watching the evolution of these patches, this would be one
implementation of the 'callback' method which I discussed in my last e-mail. 
This approach is very straight forward and easy to understand but has some
drawbacks:

- Not all of the call sites can tolerate errors.  Instead, we fallback to
  inode->i_ino and super->s_dev in case of getattr error.  That behavior is
  no worse than what we have today but what we have today is pretty bad so I
  don't particularly feel good about that. It's better than nothing though.

- There are places in the kernel where we could never call into ->getattr. 
  There are tons of tracepoints for example that are printing the the wrong
  ino/dev pair.

- The helper function has to fake a path struct because getting a vfsmount
  from inside these call sites is impossible.  This isn't actually a big
  deal as nobody except NFS cares and the NFS patch is very trivial.  It's
  ugly though, so if we had consensus on this approach I would happily
  rework our ->getattr function signature, perhaps pulling the vfsmount and
  dentry arguments back out.

- The dentry argument to ->getattr is potentially problematic as we have
  some places which _only_ have an inode. Even if we had a dentry I'm not
  sure what would keep it from going negative while in the middle of our
  ->getattr call.


Comments and review would be greatly appreciated. Thanks,
	--Mark
