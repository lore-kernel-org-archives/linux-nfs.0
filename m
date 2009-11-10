From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/2] vfs: ensure that dentries are revalidated on open (try #2)
Date: Tue, 10 Nov 2009 11:27:34 -0500
Message-ID: <1257870456-31188-1-git-send-email-jlayton@redhat.com>
Cc: ebiederm@xmission.com, adobriyan@gmail.com,
	viro@ZenIV.linux.org.uk, jamie@shareable.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-nfs@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is the second attempt to fix this problem. The first one attempted
to fix this in procfs, but Eric Biederman pointed out that file bind
mounts have a similar problem. This set attempts to fix the issue at a
higher level, in the generic VFS layer.

In certain situations, when it knows that they are valid, the path
walking code will skip revalidating dentries that it finds in the cache.
This causes problems with filesystems such as NFSv4 and CIFS that depend
on the d_revalidate routine to do opens during lookup.

A simple way to demonstrate this problem is by having a program open a
file that sits on NFSv4 via a procfs symlink or file bind mount, and
then try to set a fcntl read lock on the file. The lock operation will
return -ENOLCK because the open file has no NFSv4 state attached.

This set fixes this problem by adding a new routine to force a
revalidation of the dentry in these situations when they're being done
in order to open a file.

This fixes my testcase, and I haven't seen any other adverse affects on
it. I am however, far from certain that I'm not breaking the refcounting
in the situation where open_reval_path returns an error. I'd appreciate
someone giving me some sanity checks there. Also, have I missed any
places that need to force a revalidate like this?

Comments welcome...

Jeff Layton (2):
  vfs: force reval of dentries for LAST_BIND symlinks on open
  vfs: force reval on dentry of bind mounted files for LOOKUP_OPEN

 fs/namei.c |   50 ++++++++++++++++++++++++++++++++++++++++++++++++--
 1 files changed, 48 insertions(+), 2 deletions(-)

