Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f171.google.com ([209.85.213.171]:38779 "EHLO
	mail-ig0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbbH1DJl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Aug 2015 23:09:41 -0400
Received: by igyq3 with SMTP id q3so4222566igy.1
        for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2015 20:09:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150826133723.GX10756@twin.jikos.cz>
References: <1440577010-122867-1-git-send-email-tao.peng@primarydata.com>
 <1440577010-122867-2-git-send-email-tao.peng@primarydata.com> <20150826133723.GX10756@twin.jikos.cz>
From: Peng Tao <tao.peng@primarydata.com>
Date: Fri, 28 Aug 2015 11:09:20 +0800
Message-ID: <CAKVebiWCGNsrcUB8ZYbuD=bc6-kdb=sE0hUbSpAQHUZLfA_buA@mail.gmail.com>
Subject: Re: [PATCH-RFC-RESEND 1/9] vfs: pull btrfs clone API to vfs layer
To: dsterba@suse.cz, Peng Tao <tao.peng@primarydata.com>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
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

On Wed, Aug 26, 2015 at 9:37 PM, David Sterba <dsterba@suse.cz> wrote:
> On Wed, Aug 26, 2015 at 04:16:42PM +0800, Peng Tao wrote:
>> +struct file_clone_range {
>> +     __s64 src_fd;
>> +     __u64 src_offset;
>> +     __u64 src_length;
>> +     __u64 dest_offset;
>> +};
>
> Might be a good idea to add some spare bytes to the structure.
>
>>  struct fstrim_range {
>>       __u64 start;
>>       __u64 len;
>> @@ -159,6 +166,8 @@ struct inodes_stat_t {
>>  #define FIFREEZE     _IOWR('X', 119, int)    /* Freeze */
>>  #define FITHAW               _IOWR('X', 120, int)    /* Thaw */
>>  #define FITRIM               _IOWR('X', 121, struct fstrim_range)    /* Trim */
>> +#define FICLONE              _IOW(0x94, 9, int)      /* Clone */
>> +#define FICLONERANGE _IOW(0x94, 13, struct file_clone_range) /* Clone range */
>
> FICLONE is a special case of FICLONERANGE. The whole file clone had come
> historically first and then was refined, I don't think this needs to be
> copied to the generic API. A zeroed file_clone_range is simple to use
> for that purpose.
oh, sorry I missed this one...

BTRFS_IOC_CLONE is being used by cp(1) and widely shipped with
distros. So we cannot just abandon the API. And my intention is to
keep the clone ioctl "JUST WORK" (TM) with cp(1).

Cheers,
Tao
