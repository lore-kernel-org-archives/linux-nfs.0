Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:37479 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751470Ab2FIGaO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 9 Jun 2012 02:30:14 -0400
Date: Sat, 9 Jun 2012 07:29:52 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, dchinner@redhat.com,
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
Subject: Re: [PATCH 00/27 v6] Fix filesystem freezing deadlocks
Message-ID: <20120609062952.GY30000@ZenIV.linux.org.uk>
References: <1338589841-9568-1-git-send-email-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1338589841-9568-1-git-send-email-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jun 02, 2012 at 12:30:14AM +0200, Jan Kara wrote:
>   Hello,
> 
>   here is the sixth iteration of my patches to improve filesystem freezing.
> The change since last iteration is that filesystem can be frozen with open but
> unlinked files. After some thinking, I've decided that the best way to handle
> this is to block removal inside ->evict_inode() of each filesystem and use
> fs-internal level of freeze protection for that (usually I've instrumented
> filesystem's transaction system to use freeze protection). Handling
> inside VFS would be less work but the only level of freeze protection that
> has a chance of not causing deadlocks is the one used for page faults and even
> there it's not clear lock ordering would be correct wrt some fs-specific locks.
> I've converted ext2, ext4, btrfs, xfs, nilfs2, ocfs2, gfs2 and also checked
> that ext3, reiserfs, jfs should work as well (they have their internal freeze
> protection mechanisms, possibly they could be replaced by a generic one but
> given these are mostly aging filesystems, it's not a real priority IHMO).
> So finally I'm not aware of any pending issue with this patch set so if you
> have some concern, please speak up!

Could you rebase on top of e.g. -rc2 and repost?
