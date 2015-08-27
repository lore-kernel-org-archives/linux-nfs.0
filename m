Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:38111 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752869AbbH0GX7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Aug 2015 02:23:59 -0400
Received: by ignq3 with SMTP id q3so1877571ign.1
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2015 23:23:58 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150826225232.GX714@dastard>
References: <1440577010-122867-1-git-send-email-tao.peng@primarydata.com>
 <1440577010-122867-2-git-send-email-tao.peng@primarydata.com> <20150826225232.GX714@dastard>
From: Peng Tao <tao.peng@primarydata.com>
Date: Thu, 27 Aug 2015 14:23:39 +0800
Message-ID: <CAKVebiWVdtcavHk3Y0VHMXs9RoUo=Awxn+=wrwxHtxw9ohNbiw@mail.gmail.com>
Subject: Re: [PATCH-RFC-RESEND 1/9] vfs: pull btrfs clone API to vfs layer
To: Dave Chinner <david@fromorbit.com>
Cc: Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>,
        Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-btrfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Aug 27, 2015 at 6:52 AM, Dave Chinner <david@fromorbit.com> wrote:
> On Wed, Aug 26, 2015 at 04:16:42PM +0800, Peng Tao wrote:
>> Now that a few file systems are adding clone functionality, namingly
>> btrfs, NFS (later in the series) and XFS
>> (ttp://oss.sgi.com/archives/xfs/2015-06/msg00407.html), it makes sense
>> to pull the ioctl to common code.
>>
>> Add vfs_file_clone_range() helper and .clone_range file operation interface
>> to allow underlying filesystems to clone between regular files.
>>
>> The change in do_vfs_ioctl() is defered to next patch where btrfs
>> .clone_range is added, just so that we don't break btrfs CLONE ioctl
>> with this patch.
>>
>> Signed-off-by: Peng Tao <tao.peng@primarydata.com>
>> ---
>>  fs/ioctl.c              | 24 ++++++++++++++++++++++++
>>  fs/read_write.c         | 45 +++++++++++++++++++++++++++++++++++++++++++++
>>  include/linux/fs.h      |  4 ++++
>>  include/uapi/linux/fs.h |  9 +++++++++
>>  4 files changed, 82 insertions(+)
> .....
>> +int vfs_file_clone_range(struct file *src_file, struct file *dst_file,
>> +                      loff_t off, size_t len, loff_t dstoff)
>> +{
>> +     struct inode *src_ino;
>> +     struct inode *dst_ino;
>> +     ssize_t ret;
>> +
>> +     if (!(src_file->f_mode & FMODE_READ) ||
>> +         !(dst_file->f_mode & FMODE_WRITE) ||
>> +         (dst_file->f_flags & O_APPEND) ||
>> +         !src_file->f_op || !src_file->f_op->clone_range)
>> +             return -EINVAL;
>> +
>> +     src_ino = file_inode(src_file);
>> +     dst_ino = file_inode(dst_file);
>> +
>> +        if (S_ISDIR(src_ino->i_mode) || S_ISDIR(dst_ino->i_mode))
>> +                return -EISDIR;
>
> Whacky whitespace.
>
> Also, shouldn't this call be restricted to S_ISREG() inodes? This
> only checks for directories...
Good point. I'll change it. Thanks!

Cheers,
Tao
