Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pz0-f52.google.com ([209.85.210.52]:38610 "EHLO
	mail-pz0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754705Ab2DPV76 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Apr 2012 17:59:58 -0400
Received: by mail-pz0-f52.google.com with SMTP id e40so7458022dak.11
        for <linux-nfs@vger.kernel.org>; Mon, 16 Apr 2012 14:59:58 -0700 (PDT)
Subject: Re: [PATCH 00/19 v5] Fix filesystem freezing deadlocks
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@whamcloud.com>
In-Reply-To: <1334592845-22862-1-git-send-email-jack@suse.cz>
Date: Mon, 16 Apr 2012 15:02:50 -0700
Cc: Al Viro <viro@ZenIV.linux.org.uk>, dchinner@redhat.com,
        LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org,
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
Message-Id: <C9A0E2F0-ED57-40D6-9F75-5D72D45D21F0@dilger.ca>
References: <1334592845-22862-1-git-send-email-jack@suse.cz>
To: Jan Kara <jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-04-16, at 9:13 AM, Jan Kara wrote:
> Another potential contention point might be patch 19. In that patch
> we make freeze_super() refuse to freeze the filesystem when there
> are open but unlinked files which may be impractical in some cases.
> The main reason for this is the problem with handling of file deletion
> from fput() called with mmap_sem held (e.g. from munmap(2)), and
> then there's the fact that we cannot really force such filesystem
> into a consistent state... But if people think that freezing with
> open but unlinked files should happen, then I have some possible
> solutions in mind (maybe as a separate patchset since this is
> large enough).

Looking at a desktop system, I think it is very typical that there
are open-unlinked files present, so I don't know if this is really
an acceptable solution.  It isn't clear from your comments whether
this is a blanket refusal for all open-unlinked files, or only in
some particular cases...

lsof | grep deleted
nautilus  25393  adilger   19r      REG           253,0      340     253954 /home/adilger/.local/share/gvfs-metadata/home (deleted)
nautilus  25393  adilger   20r      REG           253,0    32768     253964 /home/adilger/.local/share/gvfs-metadata/home-f332a8f3.log (deleted)
gnome-ter 25623  adilger   22u      REG            0,18    17841    2717846 /tmp/vtePIRJCW (deleted)
gnome-ter 25623  adilger   23u      REG            0,18     5568    2717847 /tmp/vteDCSJCW (deleted)
gnome-ter 25623  adilger   29u      REG            0,18      480    2728484 /tmp/vte6C1TCW (deleted)

Cheers, Andreas





