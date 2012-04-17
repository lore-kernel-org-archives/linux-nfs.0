Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:45974 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751924Ab2DQFKC convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Apr 2012 01:10:02 -0400
Received: by mail-pb0-f46.google.com with SMTP id un15so7193110pbc.19
        for <linux-nfs@vger.kernel.org>; Mon, 16 Apr 2012 22:10:02 -0700 (PDT)
Subject: Re: [PATCH 00/19 v5] Fix filesystem freezing deadlocks
Mime-Version: 1.0 (Apple Message framework v1084)
Content-Type: text/plain; charset=us-ascii
From: Andreas Dilger <adilger@whamcloud.com>
In-Reply-To: <20120417004329.GE6734@dastard>
Date: Mon, 16 Apr 2012 22:10:50 -0700
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
Message-Id: <141752A3-EDF1-4ABC-919D-4170B0455948@whamcloud.com>
References: <1334592845-22862-1-git-send-email-jack@suse.cz> <C9A0E2F0-ED57-40D6-9F75-5D72D45D21F0@dilger.ca> <20120417004329.GE6734@dastard>
To: Dave Chinner <david@fromorbit.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2012-04-16, at 5:43 PM, Dave Chinner wrote:
> On Mon, Apr 16, 2012 at 03:02:50PM -0700, Andreas Dilger wrote:
>> On 2012-04-16, at 9:13 AM, Jan Kara wrote:
>>> Another potential contention point might be patch 19. In that patch
>>> we make freeze_super() refuse to freeze the filesystem when there
>>> are open but unlinked files which may be impractical in some cases.
>>> The main reason for this is the problem with handling of file deletion from fput() called with mmap_sem held (e.g. from munmap(2)),
>>> and then there's the fact that we cannot really force such filesystem
>>> into a consistent state... But if people think that freezing with
>>> open but unlinked files should happen, then I have some possible
>>> solutions in mind (maybe as a separate patchset since this is
>>> large enough).
>> 
>> Looking at a desktop system, I think it is very typical that there
>> are open-unlinked files present, so I don't know if this is really
>> an acceptable solution.  It isn't clear from your comments whether
>> this is a blanket refusal for all open-unlinked files, or only in
>> some particular cases...
> 
> Unlinked-but-open files are the reason that XFS dirties the log
> after the freeze process is complete. This ensures that if the
> system crashes while the filesystem is frozen then log recovery
> during the next mount will process the unlinked (orphaned) inodes
> and free the correctly. i.e. you can still freeze a filesystem with
> inodes in this state successfully and have everythign behave as
> you'd expect.
> 
> I'm not sure how other filesystems handle this problem, but perhaps
> pushing this check down into filesystem specific code or adding a
> superblock feature flag might be a way to allow filesystems to
> handle this case in the way they think is best...

The ext3/4 code has long been able to handle open-unlinked files
properly after a crash (they are put into a singly-linked list from
the superblock on disk that is processed after journal recovery).

The issue here is that blocking freeze from succeeding with open-
unlinked files is an unreasonable assumption of this patch, and
I don't think it is acceptable to land this patchset (which IMHO
would prevent nearly every Gnome system from freezing unless these
apps have changed their behaviour in more recent releases).

Like you suggest, filesystems that handle this correctly should be
able to flag or otherwise indicate that this is OK, and allow the
freeze to continue.  For other filesystems that do not handle
open-unlinked file consistency during a filesystem freeze/snapshot
whether this should even be considered a new case, or is something
that has existed for ages already.

The other question is whether this is still a problem even for
filesystems handling the consistency issue, but from Jan's comment
above there is a new locking issue related to mmap_sem being added?

Cheers, Andreas
--
Andreas Dilger                       Whamcloud, Inc.
Principal Lustre Engineer            http://www.whamcloud.com/




