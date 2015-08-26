Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f181.google.com ([209.85.223.181]:35188 "EHLO
	mail-io0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756057AbbHZIba (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Aug 2015 04:31:30 -0400
Received: by iodt126 with SMTP id t126so10242736iod.2
        for <linux-nfs@vger.kernel.org>; Wed, 26 Aug 2015 01:31:29 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150826080111.GV10756@twin.jikos.cz>
References: <1440516829-116041-1-git-send-email-tao.peng@primarydata.com>
 <1440516829-116041-3-git-send-email-tao.peng@primarydata.com> <20150826080111.GV10756@twin.jikos.cz>
From: Peng Tao <tao.peng@primarydata.com>
Date: Wed, 26 Aug 2015 16:31:09 +0800
Message-ID: <CAKVebiWy6S4ri8_V+SuT+mnyTKjiubPS49k3LHF2Csh2TVf_SQ@mail.gmail.com>
Subject: Re: [PATCH RFC 02/11] vfs/btrfs: add .clone_range file operation
To: dsterba@suse.cz, Peng Tao <tao.peng@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Christoph Hellwig <hch@infradead.org>, Zach Brown <zab@zabbo.net>,
        Darren Hart <dvhart@linux.intel.com>,
        Bruce Fields <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>, linux-btrfs@vger.kernel.org,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 26, 2015 at 4:01 PM, David Sterba <dsterba@suse.cz> wrote:
> On Tue, Aug 25, 2015 at 11:33:40PM +0800, Peng Tao wrote:
>> --- a/include/uapi/linux/btrfs.h
>> +++ b/include/uapi/linux/btrfs.h
>> @@ -316,12 +316,6 @@ struct btrfs_ioctl_search_args_v2 {
>>       __u64 buf[0];                       /* out - found items */
>>  };
>>
>> -struct btrfs_ioctl_clone_range_args {
>> -  __s64 src_fd;
>> -  __u64 src_offset, src_length;
>> -  __u64 dest_offset;
>> -};
>
> For backward compatibility and not-breaking-builds reasons, do not
> remove anything from this file.
>
Got you. I'll keep it unchanged in the next version.

>> -
>>  /* flags for the defrag range ioctl */
>>  #define BTRFS_DEFRAG_RANGE_COMPRESS 1
>>  #define BTRFS_DEFRAG_RANGE_START_IO 2
>> @@ -548,7 +542,6 @@ static inline char *btrfs_err_str(enum btrfs_err_code err_code)
>>  #define BTRFS_IOC_TRANS_END    _IO(BTRFS_IOCTL_MAGIC, 7)
>>  #define BTRFS_IOC_SYNC         _IO(BTRFS_IOCTL_MAGIC, 8)
>>
>> -#define BTRFS_IOC_CLONE        _IOW(BTRFS_IOCTL_MAGIC, 9, int)
>
> The ioctl definition reuses the BTRFS_IOCTL_MAGIC (0x94), which is IMHO
> wrong.
>
I thought it breaks ABI if we choose a different value for the type
field of the ioctl. Am I misunderstanding it?

Thanks,
Tao
