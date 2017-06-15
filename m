Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:33236 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751732AbdFONHm (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 15 Jun 2017 09:07:42 -0400
MIME-Version: 1.0
In-Reply-To: <142a7dbc-0a53-0f10-b8ed-73a896a4264d@infradead.org>
References: <5bca6687-ac03-72ef-f38e-6759a0fbb1d6@gmail.com>
 <20170614185335.58193-1-kolga@netapp.com> <142a7dbc-0a53-0f10-b8ed-73a896a4264d@infradead.org>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Thu, 15 Jun 2017 09:07:40 -0400
Message-ID: <CAN-5tyFxzJ4zFvqi1zr1quL3qei2MQHyeMNSpD0fPit3ZxgG1g@mail.gmail.com>
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
To: Randy Dunlap <rdunlap@infradead.org>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 14, 2017 at 5:50 PM, Randy Dunlap <rdunlap@infradead.org> wrote:
> On 06/14/17 11:53, Olga Kornievskaia wrote:
>> This is a proposal to allow 64bit count to copy and return as
>> a result of a copy_file_range. No attempt was made to share code
>> with the 32bit function because 32bit interface should probably
>> get depreciated.
>
>       deprecated.
>
>>
>> Why use 64bit? Current uses of 32bit are by clone_file_range()
>> which could use 64bit count and NFS copy_file_range also supports
>> 64bit count value.
>>
>> Also with this proposal off-the-bet allow the userland to copy
>
> what does "off-the-bet" mean?

from the beginning.

>
>> between different mount points.
>>
>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>> ---
>>  arch/x86/entry/syscalls/syscall_32.tbl |   1 +
>>  arch/x86/entry/syscalls/syscall_64.tbl |   1 +
>>  fs/read_write.c                        | 146 +++++++++++++++++++++++++++++++--
>>  include/linux/fs.h                     |   4 +
>>  include/linux/syscalls.h               |   3 +
>>  include/uapi/asm-generic/unistd.h      |   4 +-
>>  kernel/sys_ni.c                        |   1 +
>>  7 files changed, 154 insertions(+), 6 deletions(-)
>
>
> --
> ~Randy
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
