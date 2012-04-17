Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:60211 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755954Ab2DQJc7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Apr 2012 05:32:59 -0400
Date: Tue, 17 Apr 2012 11:32:46 +0200
From: Jan Kara <jack@suse.cz>
To: Andreas Dilger <adilger@whamcloud.com>
Cc: Jan Kara <jack@suse.cz>, Al Viro <viro@ZenIV.linux.org.uk>,
        dchinner@redhat.com, LKML <linux-kernel@vger.kernel.org>,
        linux-fsdevel@vger.kernel.org, Alex Elder <elder@kernel.org>,
        Anton Altaparmakov <anton@tuxera.com>, Ben Myers <bpm@sgi.com>,
        Chris Mason <chris.mason@oracle.com>, cluster-devel@redhat.com,
        "David S. Miller" <davem@davemloft.net>,
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
Subject: Re: [PATCH 00/19 v5] Fix filesystem freezing deadlocks
Message-ID: <20120417093246.GD7198@quack.suse.cz>
References: <1334592845-22862-1-git-send-email-jack@suse.cz>
 <C9A0E2F0-ED57-40D6-9F75-5D72D45D21F0@dilger.ca>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <C9A0E2F0-ED57-40D6-9F75-5D72D45D21F0@dilger.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon 16-04-12 15:02:50, Andreas Dilger wrote:
> On 2012-04-16, at 9:13 AM, Jan Kara wrote:
> > Another potential contention point might be patch 19. In that patch
> > we make freeze_super() refuse to freeze the filesystem when there
> > are open but unlinked files which may be impractical in some cases.
> > The main reason for this is the problem with handling of file deletion
> > from fput() called with mmap_sem held (e.g. from munmap(2)), and
> > then there's the fact that we cannot really force such filesystem
> > into a consistent state... But if people think that freezing with
> > open but unlinked files should happen, then I have some possible
> > solutions in mind (maybe as a separate patchset since this is
> > large enough).
> 
> Looking at a desktop system, I think it is very typical that there
> are open-unlinked files present, so I don't know if this is really
> an acceptable solution.  It isn't clear from your comments whether
> this is a blanket refusal for all open-unlinked files, or only in
> some particular cases...
  Thanks for looking at this. It is currently a blanket refusal. And I
agree it's problematic. There are two problems with open but unlinked
files.

One is that some old filesystems cannot get in a consistent state in
presence of open but unlinked files but for filesystems we really care
about - xfs, ext4, ext3, btrfs, or even ocfs2, gfs2 - that is not a real
issue (these filesystems will delete those inodes on next mount read-write).

The other problem is with what should happen when you put last inode
reference on a frozen filesystem. Two possibilities I see are:

a) block the iput() call - that is inconvenient because it can be
called in various contexts. I think we could possibly use the same level of
freeze protection as for page fault (this has changed since I originally
thought about this and that would make things simpler) but I'm not
completely sure.

b) let the iput finish but filesystem will keep inode on its orphan list
(or it's equivalent) and the inode will be deleted after the filesystem is
thawed. The advantage of this is we don't have to block iput(), the
disadvantage is we have to have filesystem support and not all filesystems
can do this.

Any thoughts?

								Honza
> 
> lsof | grep deleted
> nautilus  25393  adilger   19r      REG           253,0      340     253954 /home/adilger/.local/share/gvfs-metadata/home (deleted)
> nautilus  25393  adilger   20r      REG           253,0    32768     253964 /home/adilger/.local/share/gvfs-metadata/home-f332a8f3.log (deleted)
> gnome-ter 25623  adilger   22u      REG            0,18    17841    2717846 /tmp/vtePIRJCW (deleted)
> gnome-ter 25623  adilger   23u      REG            0,18     5568    2717847 /tmp/vteDCSJCW (deleted)
> gnome-ter 25623  adilger   29u      REG            0,18      480    2728484 /tmp/vte6C1TCW (deleted)
  
-- 
Jan Kara <jack@suse.cz>
SUSE Labs, CR
