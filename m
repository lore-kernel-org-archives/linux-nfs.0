From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 0/7] fix setuid/setgid clearing in
	networked filesystems (take 6)
Date: Mon, 10 Sep 2007 10:52:16 -0400
Message-ID: <200709101452.l8AEqGFw016262@dantu.rdu.redhat.com>
Cc: nfs@lists.sourceforge.net, unionfs@filesystems.org,
	linux-cifs-client@lists.samba.org, ecryptfs-devel@lists.sourceforge.net,
	reiserfs-devel@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org
Return-path: <linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org>
List-Unsubscribe: <https://lists.samba.org/mailman/listinfo/linux-cifs-client>,
	<mailto:linux-cifs-client-request@lists.samba.org?subject=unsubscribe>
List-Archive: <http://lists.samba.org/archive/linux-cifs-client>
List-Post: <mailto:linux-cifs-client@lists.samba.org>
List-Help: <mailto:linux-cifs-client-request@lists.samba.org?subject=help>
List-Subscribe: <https://lists.samba.org/mailman/listinfo/linux-cifs-client>,
	<mailto:linux-cifs-client-request@lists.samba.org?subject=subscribe>
Sender: linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org
Errors-To: linux-cifs-client-bounces+glfc-linux-cifs-client=gmane.org@lists.samba.org
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
bits into a mode change and the setattr operation has no way to
know its intent.

The following patchset fixes this by making notify_change no longer
clear the ATTR_KILL_SUID and ATTR_KILL_SGID bits in the ia_valid before
handing it off to the setattr inode op. setattr can then check for the
presence of these bits, and if they're set it can assume that the mode
change was only for the purposes of clearing these bits.

This means that we now have an implicit assumption that notify_change is
never called with ATTR_MODE and either ATTR_KILL_S*ID bit set. Nothing
currently enforces that, so the main patch (5/7) adds a BUG() if that
occurs.

The first four patches fix up callers of notify_change to make sure that
they don't trip the new BUG() call. The last two patches change CIFS and
NFS to ignore the mode change if either ATTR_KILL_S*ID is set.

This patchset should apply cleanly to 2.6.23-rc4-mm1. This is
basically the same patchset as take 5. The only differences are that
the patches have been reordered to make the tree cleanly bisectable,
and the comment in notify_change is now a bit more descriptive.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
