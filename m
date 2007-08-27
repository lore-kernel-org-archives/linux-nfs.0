From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/4] add killattr inode operation to allow filesystems to interpret ATTR_KILL_S*ID bits
Date: Mon, 27 Aug 2007 13:27:03 -0400
Message-ID: <200708271727.l7RHR36m007248@dantu.rdu.redhat.com>
Cc: linux-cifs-client@lists.samba.org, nfs@lists.sourceforge.net
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

When an unprivileged process attempts to modify a file that has the
setuid or setgid bits set, the VFS will attempt to clear these bits. The
VFS will set the ATTR_KILL_SUID or ATTR_KILL_SGID bits in the ia_valid
mask, and then call notify_change to clear these bits and set the mode
accordingly.

With a networked filesystem (NFS and CIFS in particular but likely
others), the client machine or process may not have credentials that
allow for setting the mode. In some situations, this can lead to file
corruption, an operation failing outright because the setattr fails, or
to races that lead to a mode change being reverted.

In this situation, we'd like to just leave the handling of this to the
server and ignore these bits. The problem is that by the time the
setattr op is called, the VFS has already reinterpreted the ATTR_KILL_*
bits into a mode change. We can't fix this in the filesystems where this
is a problem, as doing so would leave us having to second-guess what the
VFS wants us to do. So we need to change it so that filesystems have
more flexibility in how to interpret the ATTR_KILL_* bits.

The first patch in the following patchset adds a new inode operation
called "killattr" and has notify change call it if it's defined. The
purpose of this inode op is to properly interpret the ATTR_KILL_SUID and
ATTR_KILL_SGID bits. Filesystems that do not declare a killattr inode
operation will keep the existing behavior, converting these bits
into a mode change.

The next two patches add a killattr inode op for NFS and CIFS which just
clears the bits (to allow the server to handle them). The final patch
updates the Documentation dir to describe the new killattr inode
operation.

This patchset should apply cleanly to 2.6.23-rc3-mm1. Comments and
suggestions appreciated...

Signed-off-by: Jeff Layton <jlayton@redhat.com>

