Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:40995 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752653Ab2DPQO1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 16 Apr 2012 12:14:27 -0400
From: Jan Kara <jack@suse.cz>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: dchinner@redhat.com, LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, Jan Kara <jack@suse.cz>,
        Alex Elder <elder@kernel.org>, Anton Altaparmakov <anton@tuxera.com>,
        Ben Myers <bpm@sgi.com>, Chris Mason <chris.mason@oracle.com>,
        cluster-devel@redhat.com, "David S. Miller" <davem@davemloft.net>,
        fuse-devel@lists.sourceforge.net,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Joel Becker <jlbec@evilplan.org>,
        KONISHI Ryusuke <konishi.ryusuke@lab.ntt.co.jp>,
        linux-btrfs@vger.kernel.org, linux-ext4@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-nilfs@vger.kernel.org,
        linux-ntfs-dev@lists.sourceforge.net, Mark Fasheh <mfasheh@suse.com>,
        Miklos Szeredi <miklos@szeredi.hu>, ocfs2-devel@oss.oracle.com,
        OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>,
        Steven Whitehouse <swhiteho@redhat.com>,
        "Theodore Ts'o" <tytso@mit.edu>, xfs@oss.sgi.com
Subject: [PATCH 00/19 v5] Fix filesystem freezing deadlocks
Date: Mon, 16 Apr 2012 18:13:38 +0200
Message-Id: <1334592845-22862-1-git-send-email-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

  Hello,

  here is the fifth iteration of my patches to improve filesystem freezing.
No serious changes since last time. Mostly I rebased patches and merged this
series with series moving file_update_time() to ->page_mkwrite() to simplify
testing and merging.

Filesystem freezing is currently racy and thus we can end up with dirty data on
frozen filesystem (see changelog patch 13 for detailed race description). This
patch series aims at fixing this.

To be able to block all places where inodes get dirtied, I've moved filesystem
file_update_time() call to ->page_mkwrite callback (patches 01-07) and put
freeze handling in mnt_want_write() / mnt_drop_write(). That however required
some code shuffling and changes to kern_path_create() (see patches 09-12). I
think the result is OK but opinions may differ ;). The advantage of this change
also is that all filesystems get freeze protection almost for free - even ext2
can handle freezing well now.

Another potential contention point might be patch 19. In that patch we make
freeze_super() refuse to freeze the filesystem when there are open but unlinked
files which may be impractical in some cases. The main reason for this is the
problem with handling of file deletion from fput() called with mmap_sem held
(e.g. from munmap(2)), and then there's the fact that we cannot really force
such filesystem into a consistent state... But if people think that freezing
with open but unlinked files should happen, then I have some possible
solutions in mind (maybe as a separate patchset since this is large enough).

I'm not able to hit any deadlocks, lockdep warnings, or dirty data on frozen
filesystem despite beating it with fsstress and bash-shared-mapping while
freezing and unfreezing for several hours (using ext4 and xfs) so I'm
reasonably confident this could finally be the right solution.

Changes since v4:
  * added a couple of Acked-by's
  * added some comments & doc update
  * added patches from series "Push file_update_time() into .page_mkwrite"
    since it doesn't make much sense to keep them separate anymore
  * rebased on top of 3.4-rc2

Changes since v3:
  * added third level of freezing for fs internal purposes - hooked some
    filesystems to use it (XFS, nilfs2)
  * removed racy i_size check from filemap_mkwrite()

Changes since v2:
  * completely rewritten
  * freezing is now blocked at VFS entry points
  * two stage freezing to handle both mmapped writes and other IO

The biggest changes since v1:
  * have two counters to provide safe state transitions for SB_FREEZE_WRITE
    and SB_FREEZE_TRANS states
  * use percpu counters instead of own percpu structure
  * added documentation fixes from the old fs freezing series
  * converted XFS to use SB_FREEZE_TRANS counter instead of its private
    m_active_trans counter

								Honza

CC: Alex Elder <elder@kernel.org>
CC: Anton Altaparmakov <anton@tuxera.com>
CC: Ben Myers <bpm@sgi.com>
CC: Chris Mason <chris.mason@oracle.com>
CC: cluster-devel@redhat.com
CC: "David S. Miller" <davem@davemloft.net>
CC: fuse-devel@lists.sourceforge.net
CC: "J. Bruce Fields" <bfields@fieldses.org>
CC: Joel Becker <jlbec@evilplan.org>
CC: KONISHI Ryusuke <konishi.ryusuke@lab.ntt.co.jp>
CC: linux-btrfs@vger.kernel.org
CC: linux-ext4@vger.kernel.org
CC: linux-nfs@vger.kernel.org
CC: linux-nilfs@vger.kernel.org
CC: linux-ntfs-dev@lists.sourceforge.net
CC: Mark Fasheh <mfasheh@suse.com>
CC: Miklos Szeredi <miklos@szeredi.hu>
CC: ocfs2-devel@oss.oracle.com
CC: OGAWA Hirofumi <hirofumi@mail.parknet.co.jp>
CC: Steven Whitehouse <swhiteho@redhat.com>
CC: "Theodore Ts'o" <tytso@mit.edu>
CC: xfs@oss.sgi.com
