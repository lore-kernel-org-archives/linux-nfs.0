From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/4] move handling of setuid/gid bits from
	VFS into individual setattr functions (try 2)
Date: Mon, 20 Aug 2007 16:53:09 -0400
Message-ID: <200708202053.l7KKr9eE017753@dantu.rdu.redhat.com>
Cc: codalist@TELEMANN.coda.cs.cmu.edu, cluster-devel@redhat.com,
	jfs-discussion@lists.sourceforge.net,
	mikulas@artax.karlin.mff.cuni.cz, zippel@linux-m68k.org,
	xfs@oss.sgi.com, joel.becker@oracle.com, wli@holomorphy.com,
	reiserfs-devel@vger.kernel.org, dhowells@redhat.com,
	fuse-devel@lists.sourceforge.net, nfs@lists.sourceforge.net,
	jffs-dev@axis.com, user-mode-linux-user@lists.sourceforge.net,
	v9fs-developer@lists.sourceforge.net, linux-ext4@vger.kernel.org,
	linux-cifs-client@lists.samba.org, ocfs2-devel@oss.oracle.com,
	bfennema@falcon.csc.calpoly.edu
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <cluster-devel-bounces@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/cluster-devel>
List-Post: <mailto:cluster-devel@redhat.com>
List-Help: <mailto:cluster-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/cluster-devel>,
	<mailto:cluster-devel-request@redhat.com?subject=subscribe>
Sender: cluster-devel-bounces@redhat.com
Errors-To: cluster-devel-bounces@redhat.com
List-ID: <nfs.lists.sourceforge.net>

When an unprivileged process attempts to modify a file that has the
setuid or setgid bits set, the VFS will attempt to clear these bits. The
VFS will set the ATTR_KILL_SUID or ATTR_KILL_SGID bits in the ia_valid
mask, and then call notify_change to clear these bits and set the mode
accordingly.

With a networked filesystem (NFS and CIFS in particular but likely
others), the client machine may not have credentials that allow for
setting the mode. In some situations, this can lead to file corruption,
an operation failing outright because the setattr fails, or to races
that lead to a mode change being reverted.

In this situation, we'd like to just leave the handling of this to the
server and ignore these bits. The problem is that by the time the
setattr op is called, the VFS has already reinterpreted the ATTR_KILL_*
bits into a mode change. We can't fix this in the filesystems where this
is a problem, as doing so would leave us having to second-guess what the
VFS wants us to do. So we need to change it so that filesystems have
more flexibility in how to interpret the ATTR_KILL_* bits.

The first patch in the following patchset moves this logic out of
notify_change and into a helper function. It then has notify_change call
this helper function for inodes that do not have a setattr operation
defined. The other patches fix up the individual filesystems for the new
scheme, mostly by having them call the new helper.

Changing this abruptly could introduce security issues for filesystems
that live out-of-tree or if an in-tree filesystem is missed. As a
precaution, the patchset has notify_change check the ia_valid in the
iattr struct after the setattr call returns. If any ATTR_KILL_* bits are
still set, then notify_change assumes that the filesystem didn't handle
these bits correctly. It printk's a warning and attempts to clear them
the with another setattr call.

The upshot of this is that with this change, filesystems that define a
setattr inode operation are now responsible for handling the ATTR_KILL
bits as well. They can trivially do so by calling the helper, but
they should be converted to do so as soon as possible.

Some of the follow-on patches may not be strictly necessary, but I
decided that it was better to take the conservative approach and call
the helper when I wasn't sure. I've tried to CC the maintainers for the
individual filesystems where I could find them. Please let me know if
there are others who should be informed.

This patchset should apply cleanly to the current -mm tree. I've rolled
the patches that fix individual filesystems together per Christoph's
suggestion, though I can also provide them broken out individually
again if needed.

Comments and suggestions appreciated. Also, please let me know if
I've missed any filesystems that need to be converted...

Signed-off-by: Jeff Layton <jlayton@redhat.com>
