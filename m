Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:35940 "EHLO
	mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754938AbcFTS6e (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Jun 2016 14:58:34 -0400
MIME-Version: 1.0
In-Reply-To: <CA+55aFzK2K-7UeQRsWR7ooNHMMbtMFRAF60byR1Gvmbf9XWhbA@mail.gmail.com>
References: <1466382443-11063-1-git-send-email-deepa.kernel@gmail.com> <CA+55aFzK2K-7UeQRsWR7ooNHMMbtMFRAF60byR1Gvmbf9XWhbA@mail.gmail.com>
From: Deepa Dinamani <deepa.kernel@gmail.com>
Date: Mon, 20 Jun 2016 11:58:31 -0700
Message-ID: <CABeXuvpzRy=qccBqq70iT_W9EGSfcpAjfyqkayUTT01F8Ghh5g@mail.gmail.com>
Subject: Re: [PATCH v2 00/24] Delete CURRENT_TIME and CURRENT_TIME_SEC macros
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Arnd Bergmann <arnd@arndb.de>, Thomas Gleixner <tglx@linutronix.de>,
        "Theodore Ts'o" <tytso@mit.edu>, Al Viro <viro@zeniv.linux.org.uk>,
        y2038 Mailman List <y2038@lists.linaro.org>,
        "adilger.kernel@dilger.ca" <adilger.kernel@dilger.ca>,
        Adrian Hunter <adrian.hunter@intel.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Brian Uchino <buchino@cisco.com>,
        ceph-devel <ceph-devel@vger.kernel.org>, Chris Mason <clm@fb.com>,
        Changman Lee <cm224.lee@samsung.com>,
        Artem Bityutskiy <dedekind1@gmail.com>,
        David Sterba <dsterba@suse.com>, Alex Elder <elder@kernel.org>,
        Eric Paris <eparis@redhat.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Hiral Patel <hiralpat@cisco.com>, Ilya Dryomov <idryomov@gmail.com>,
        Jan Kara <jack@suse.com>, Jaegeuk Kim <jaegeuk@kernel.org>,
        Josef Bacik <jbacik@fb.com>,
        "James E.J. Bottomley" <jejb@linux.vnet.ibm.com>,
        jfs-discussion@lists.sourceforge.net, Joel Becker <jlbec@evilplan.org>,
        John Stultz <john.stultz@linaro.org>, linux-audit@redhat.com,
        linux-btrfs <linux-btrfs@vger.kernel.org>,
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
        Suma Ramars <sramars@cisco.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "Yan, Zheng" <zyan@redhat.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> This version now looks ok to me.
>
> I do have a comment (or maybe just a RFD) for future work.
>
> It does strike me that once we actually change over the inode times to
> use timespec64, the calling conventions are going to be fairly
> horrendous on most 32-bit architectures.
>
> Gcc handles 8-byte structure returns (on most architectures) by
> returning them as two 32-bit registers (%edx:%eax on x86). But once it
> is timespec64, that will no longer be the case, and the calling
> convention will end up using a pointer to the local stack instead.
>
> So for 32-bit code generation, we *may* want to introduce a new model of doing
>
>     set_inode_time(inode, ATTR_ATIME | ATTR_MTIME);
>
> which basically just does
>
>     inode->i_atime = inode->i_mtime = current_time(inode);
>
> but with a much easier calling convention on 32-bit architectures.

Arnd and I had discussed something like this before.
But, for entirely different reasons:

Having the set_inode_time() like you suggest will also help switching
of vfs inode times to timespec64.
We were suggesting all the accesses to inode time be abstracted
through something like inode_set_time().
Arnd also had suggested a split representation of fields in the struct
inode as well which led to space savings
as well. And, having the split representation also meant no more
direct assignments:

https://lkml.org/lkml/2016/1/7/20

This in general will be similar to setattr_copy(), but only sets times
rather than other attributes as well.

If this is what is preferred, then the patches to change vfs to use
timespec64 could make use of this and will
need to be refactored. So maybe it would be good to discuss before I
post those patches.

-Deepa
