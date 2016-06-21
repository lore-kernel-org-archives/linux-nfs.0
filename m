Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.126.134]:52065 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750931AbcFUPBK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 21 Jun 2016 11:01:10 -0400
From: Arnd Bergmann <arnd@arndb.de>
To: y2038@lists.linaro.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Deepa Dinamani <deepa.kernel@gmail.com>,
        Dave Kleikamp <shaggy@kernel.org>,
        jfs-discussion@lists.sourceforge.net,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Adrian Hunter <adrian.hunter@intel.com>, Chris Mason <clm@fb.com>,
        "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>,
        buchino@cisco.com, Thomas Gleixner <tglx@linutronix.de>,
        "Yan, Zheng" <zyan@redhat.com>, jejb@linux.vnet.ibm.com,
        Paul Moore <paul@paul-moore.com>,
        Linux SCSI List <linux-scsi@vger.kernel.org>,
        Ilya Dryomov <idryomov@gmail.com>,
        "linux-ext4@vger.kernel.org" <linux-ext4@vger.kernel.org>,
        Changman Lee <cm224.lee@samsung.com>, Mark Fasheh <mfasheh@suse.com>,
        sramars@cisco.com, John Stultz <john.stultz@linaro.org>,
        Al Viro <viro@zeniv.linux.org.uk>, David Sterba <dsterba@suse.com>,
        Jaegeuk Kim <jaegeuk@kernel.org>,
        ceph-devel <ceph-devel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Alex Elder <elder@kernel.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Sage Weil <sage@redhat.com>,
        "Martin K. Petersen" <martin.petersen@oracle.com>,
        Artem Bityutskiy <dedekind1@gmail.com>, Josef Bacik <jbacik@fb.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>, hiralpat@cisco.com,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Eric Paris <eparis@redhat.com>,
        "Linux F2FS DEV, Mailing List"
	<linux-f2fs-devel@lists.sourceforge.net>,
        Steve French <sfrench@samba.org>, linux-audit@redhat.com,
        ocfs2-devel@oss.oracle.com, Jan Kara <jack@suse.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        linux-mtd <linux-mtd@lists.infradead.org>,
        lustre-devel@lists.lustre.org,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-btrfs <linux-btrfs@vger.kernel.org>,
        Joel Becker <jlbec@evilplan.org>
Subject: Re: [Y2038] [PATCH v2 00/24] Delete CURRENT_TIME and CURRENT_TIME_SEC macros
Date: Tue, 21 Jun 2016 17:00:37 +0200
Message-ID: <4953017.3z0GqUlq8o@wuerfel>
In-Reply-To: <CA+55aFzK2K-7UeQRsWR7ooNHMMbtMFRAF60byR1Gvmbf9XWhbA@mail.gmail.com>
References: <1466382443-11063-1-git-send-email-deepa.kernel@gmail.com> <CA+55aFzK2K-7UeQRsWR7ooNHMMbtMFRAF60byR1Gvmbf9XWhbA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Monday, June 20, 2016 11:03:01 AM CEST you wrote:
> On Sun, Jun 19, 2016 at 5:26 PM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
> > The series is aimed at getting rid of CURRENT_TIME and CURRENT_TIME_SEC macros.

> Gcc handles 8-byte structure returns (on most architectures) by
> returning them as two 32-bit registers (%edx:%eax on x86). But once it
> is timespec64, that will no longer be the case, and the calling
> convention will end up using a pointer to the local stack instead.

I guess we already have that today, as the implementation of
current_fs_time() is

static inline struct timespec64 tk_xtime(struct timekeeper *tk)
{
        struct timespec64 ts;

        ts.tv_sec = tk->xtime_sec;
        ts.tv_nsec = (long)(tk->tkr_mono.xtime_nsec >> tk->tkr_mono.shift);
        return ts;
}
extern struct timespec64 current_kernel_time64(void);
struct timespec64 current_kernel_time64(void)
{
        struct timekeeper *tk = &tk_core.timekeeper;
        struct timespec64 now;
        unsigned long seq;

        do {
                seq = read_seqcount_begin(&tk_core.seq);

                now = tk_xtime(tk);
        } while (read_seqcount_retry(&tk_core.seq, seq));

        return now;
}
static inline struct timespec current_kernel_time(void)
{
        struct timespec64 now = current_kernel_time64();

        return timespec64_to_timespec(now);
}
extern struct timespec current_fs_time(struct super_block *sb);
struct timespec current_fs_time(struct super_block *sb)
{       
        struct timespec now = current_kernel_time();
        return timespec_trunc(now, sb->s_time_gran);
}       

We can surely do a little better than this, independent of the
conversion in Deepa's patch set.

> So for 32-bit code generation, we *may* want to introduce a new model of doing
> 
>     set_inode_time(inode, ATTR_ATIME | ATTR_MTIME);
> 
> which basically just does
> 
>     inode->i_atime = inode->i_mtime = current_time(inode);
> 
> but with a much easier calling convention on 32-bit architectures.
> 
> But that is entirely orthogonal to this patch-set, and should be seen
> as a separate issue.

I've played around with that, but found it hard to avoid going
through memory other than going all the way to the tk_xtime()
access to copy both tk->xtime_sec and the nanoseconds into
the inode fields.

Without that, the set_inode_time() implementation ends up
being more expensive than
inode->i_atime = inode->i_ctime = inode->i_mtime = current_time(inode);
because we still copy through the stack but also have
a couple of conditional branches that we don't have at the
moment.

At the moment, the triple assignment becomes (here on ARM)

   c:   4668            mov     r0, sp
  12:   f7ff fffe       bl      0 <current_kernel_time64>
  3e:   f107 0520       add.w   r5, r7, #32
                        12: R_ARM_THM_CALL      current_kernel_time64
  16:   f106 0410       add.w   r4, r6, #16
  1a:   e89d 000f       ldmia.w sp, {r0, r1, r2, r3} # load from stack
  1e:   e885 000f       stmia.w r5, {r0, r1, r2, r3} # store into i_atime
  22:   e884 000f       stmia.w r4, {r0, r1, r2, r3} #            i_ctime
  26:   e886 000f       stmia.w r6, {r0, r1, r2, r3} #            i_mtime

and a slightly more verbose version of the same thing on x86
(storing only 12 bytes instead of 16 is cheaper there, while
ARM does a store-multiple to copy the entire structure).

        Arnd
