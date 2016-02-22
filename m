Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f172.google.com ([209.85.223.172]:34281 "EHLO
	mail-io0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753317AbcBVPra (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 22 Feb 2016 10:47:30 -0500
MIME-Version: 1.0
In-Reply-To: <CAHQdGtR26gqy7GzWui-bnb+W5W1PnUL_=okBZwz+XFmj_Q4A3A@mail.gmail.com>
References: <1456154274-30487-1-git-send-email-deepa.kernel@gmail.com>
	<1456154274-30487-9-git-send-email-deepa.kernel@gmail.com>
	<CAHQdGtR26gqy7GzWui-bnb+W5W1PnUL_=okBZwz+XFmj_Q4A3A@mail.gmail.com>
Date: Mon, 22 Feb 2016 21:17:29 +0530
Message-ID: <CABeXuvq6Fxcj15Zo9F7tPUN+-Jw7nOPcH8AHKP29Q+6R4mqmRQ@mail.gmail.com>
Subject: Re: [PATCH 8/8] net: sunrpc: Replace CURRENT_TIME by current_fs_time()
From: Deepa Dinamani <deepa.kernel@gmail.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        y2038@lists.linaro.org, Arnd Bergmann <arnd@arndb.de>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Feb 22, 2016 at 9:04 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Mon, Feb 22, 2016 at 10:17 AM, Deepa Dinamani <deepa.kernel@gmail.com> wrote:
>>
>> CURRENT_TIME macro is not appropriate for filesystems as it
>> doesn't use the right granularity for filesystem timestamps.
>> Use current_fs_time() instead.
>>
>> Signed-off-by: Deepa Dinamani <deepa.kernel@gmail.com>
>> Cc: "J. Bruce Fields" <bfields@fieldses.org>
>> Cc: Jeff Layton <jlayton@poochiereds.net>
>> Cc: Trond Myklebust <trond.myklebust@primarydata.com>
>> Cc: Anna Schumaker <anna.schumaker@netapp.com>
>> Cc: "David S. Miller" <davem@davemloft.net>
>> Cc: linux-nfs@vger.kernel.org
>> Cc: netdev@vger.kernel.org
>> ---
>>  net/sunrpc/rpc_pipe.c | 4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/sunrpc/rpc_pipe.c b/net/sunrpc/rpc_pipe.c
>> index 31789ef..bab3187 100644
>> --- a/net/sunrpc/rpc_pipe.c
>> +++ b/net/sunrpc/rpc_pipe.c
>> @@ -477,7 +477,9 @@ rpc_get_inode(struct super_block *sb, umode_t mode)
>>                 return NULL;
>>         inode->i_ino = get_next_ino();
>>         inode->i_mode = mode;
>> -       inode->i_atime = inode->i_mtime = inode->i_ctime = CURRENT_TIME;
>> +       inode->i_atime = current_fs_time(sb);
>> +       inode->i_mtime = inode->i_atime;
>> +       inode->i_ctime = inode->i_atime;
>>         switch (mode & S_IFMT) {
>>         case S_IFDIR:
>>                 inode->i_fop = &simple_dir_operations;
>
> Why would we care? This is a pseudo-fs. There is no expectation w.r.t.
> timestamp accuracy or resolution.

CURRENT_TIME is not y2038 safe.
We are switching all vfs timestamps to use 64 bit time.
And, deleting all references to CURRENT_TIME.
So CURRENT_TIME users will be replaced by either ktime_get_* apis
or current_fs_time_* apis.

There is going to be another series (based on
https://lkml.org/lkml/2016/2/12/76)
which switches vfs time to 64 bit.

This means [a,c,m] times in struct inode, struct attr and struct kstat
will be changed to use timespec64.

Even though this is a psuedo-fs, we choose to use filesystem apis
rather than ktime_get_* apis as current_fs_time_* apis will switch time
data types together with vfs.

-Deepa
