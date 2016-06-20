Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f194.google.com ([209.85.214.194]:34049 "EHLO
	mail-ob0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752340AbcFTSDU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2016 14:03:20 -0400
MIME-Version: 1.0
In-Reply-To: <1466382443-11063-1-git-send-email-deepa.kernel@gmail.com>
References: <1466382443-11063-1-git-send-email-deepa.kernel@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 20 Jun 2016 11:03:01 -0700
Message-ID: <CA+55aFzK2K-7UeQRsWR7ooNHMMbtMFRAF60byR1Gvmbf9XWhbA@mail.gmail.com>
Subject: Re: [PATCH v2 00/24] Delete CURRENT_TIME and CURRENT_TIME_SEC macros
To: Deepa Dinamani <deepa.kernel@gmail.com>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>,
        "Theodore Ts'o" <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>,
        y2038@lists.linaro.org,
        "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>,
        Adrian Hunter <adrian.hunter@intel.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, buchino@cisco.com,
        ceph-devel <ceph-devel@vger.kernel.org>, Chris Mason <clm@fb.com>,
        Changman Lee <cm224.lee@samsung.com>,
        Artem Bityutskiy <dedekind1@gmail.com>,
        David Sterba <dsterba@suse.com>, Alex Elder <elder@kernel.org>,
        Eric Paris <eparis@redhat.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>, hiralpat@cisco.com,
        Ilya Dryomov <idryomov@gmail.com>, Jan Kara <jack@suse.com>,
        Jaegeuk Kim <jaegeuk@kernel.org>, Josef Bacik <jbacik@fb.com>,
        jejb@linux.vnet.ibm.com, jfs-discussion@lists.sourceforge.net,
        Joel Becker <jlbec@evilplan.org>, John Stultz <john.stultz@linaro.org>,
        linux-audit@redhat.com, linux-btrfs <linux-btrfs@vger.kernel.org>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        "Linux F2FS DEV, Mailing List"
	<linux-f2fs-devel@lists.sourceforge.net>,
        linux-mtd <linux-mtd@lists.infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux SCSI List <linux-scsi@vger.kernel.org>,
        lustre-devel@lists.lustre.org,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Mark Fasheh <mfasheh@suse.com>, ocfs2-devel@oss.oracle.com,
        Paul Moore <paul@paul-moore.com>, Sage Weil <sage@redhat.com>,
        Steve French <sfrench@samba.org>, Dave Kleikamp <shaggy@kernel.org>,
        sramars@cisco.com, Trond Myklebust <trond.myklebust@primarydata.com>,
        "Yan, Zheng" <zyan@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jun 19, 2016 at 5:26 PM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
> The series is aimed at getting rid of CURRENT_TIME and CURRENT_TIME_SEC macros.

This version now looks ok to me.

I do have a comment (or maybe just a RFD) for future work.

It does strike me that once we actually change over the inode times to
use timespec64, the calling conventions are going to be fairly
horrendous on most 32-bit architectures.

Gcc handles 8-byte structure returns (on most architectures) by
returning them as two 32-bit registers (%edx:%eax on x86). But once it
is timespec64, that will no longer be the case, and the calling
convention will end up using a pointer to the local stack instead.

So for 32-bit code generation, we *may* want to introduce a new model of doing

    set_inode_time(inode, ATTR_ATIME | ATTR_MTIME);

which basically just does

    inode->i_atime = inode->i_mtime = current_time(inode);

but with a much easier calling convention on 32-bit architectures.

But that is entirely orthogonal to this patch-set, and should be seen
as a separate issue.

And maybe it doesn't end up helping anyway, but I do think those
"simple" direct assignments will really generate pretty disgusting
code on 32-bit architectures.

That whole

    inode->i_atime = inode->i_mtime = CURRENT_TIME;

model really made a lot more sense back in the ancient days when inode
times were just simply 32-bit seconds (not even timeval structures).

                  Linus
