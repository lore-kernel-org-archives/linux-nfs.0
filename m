Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:52296 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751985AbdFTMoh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 20 Jun 2017 08:44:37 -0400
Subject: Re: [PATCH 1/1] [RFC] 64bit copy_file_range system call
To: "Darrick J. Wong" <darrick.wong@oracle.com>,
        Olga Kornievskaia <aglo@umich.edu>
Cc: Olga Kornievskaia <kolga@netapp.com>,
        "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>,
        linux-nfs <linux-nfs@vger.kernel.org>
References: <5bca6687-ac03-72ef-f38e-6759a0fbb1d6@gmail.com>
 <20170614185335.58193-1-kolga@netapp.com>
 <20170615035923.GA4521@birch.djwong.org>
 <CAN-5tyGCYjR4wXkpjD8XKXSSAmSS1VG2SA1Kr4V5iJFPjZJFug@mail.gmail.com>
 <20170615205357.GA13715@birch.djwong.org>
From: Steve Dickson <SteveD@RedHat.com>
Message-ID: <ea1f0408-63f0-cad6-f8f0-92bd7ac31ae6@RedHat.com>
Date: Tue, 20 Jun 2017 08:44:35 -0400
MIME-Version: 1.0
In-Reply-To: <20170615205357.GA13715@birch.djwong.org>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 06/15/2017 04:53 PM, Darrick J. Wong wrote:
> On Thu, Jun 15, 2017 at 10:39:42AM -0400, Olga Kornievskaia wrote:
>> On Wed, Jun 14, 2017 at 11:59 PM, Darrick J. Wong
>> <darrick.wong@oracle.com> wrote:
>>> On Wed, Jun 14, 2017 at 02:53:35PM -0400, Olga Kornievskaia wrote:
>>>> This is a proposal to allow 64bit count to copy and return as
>>>> a result of a copy_file_range. No attempt was made to share code
>>>> with the 32bit function because 32bit interface should probably
>>>> get depreciated.
>>>>
>>>> Why use 64bit? Current uses of 32bit are by clone_file_range()
>>>> which could use 64bit count and NFS copy_file_range also supports
>>>> 64bit count value.
>>>>
>>>> Also with this proposal off-the-bet allow the userland to copy
>>>> between different mount points.
>>>>
>>>> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
>>>> ---
>>>>  arch/x86/entry/syscalls/syscall_32.tbl |   1 +
>>>>  arch/x86/entry/syscalls/syscall_64.tbl |   1 +
>>>>  fs/read_write.c                        | 146 +++++++++++++++++++++++++++++++--
>>>>  include/linux/fs.h                     |   4 +
>>>>  include/linux/syscalls.h               |   3 +
>>>>  include/uapi/asm-generic/unistd.h      |   4 +-
>>>>  kernel/sys_ni.c                        |   1 +
>>>>  7 files changed, 154 insertions(+), 6 deletions(-)
>>>>
>>>> diff --git a/arch/x86/entry/syscalls/syscall_32.tbl b/arch/x86/entry/syscalls/syscall_32.tbl
>>>> index 448ac21..1f5f1e7 100644
>>>> --- a/arch/x86/entry/syscalls/syscall_32.tbl
>>>> +++ b/arch/x86/entry/syscalls/syscall_32.tbl
>>>> @@ -391,3 +391,4 @@
>>>>  382  i386    pkey_free               sys_pkey_free
>>>>  383  i386    statx                   sys_statx
>>>>  384  i386    arch_prctl              sys_arch_prctl                  compat_sys_arch_prctl
>>>> +385  i386    copy_file_range64       sys_copy_file_range64
>>>> diff --git a/arch/x86/entry/syscalls/syscall_64.tbl b/arch/x86/entry/syscalls/syscall_64.tbl
>>>> index 5aef183..e658bbe 100644
>>>> --- a/arch/x86/entry/syscalls/syscall_64.tbl
>>>> +++ b/arch/x86/entry/syscalls/syscall_64.tbl
>>>> @@ -339,6 +339,7 @@
>>>>  330  common  pkey_alloc              sys_pkey_alloc
>>>>  331  common  pkey_free               sys_pkey_free
>>>>  332  common  statx                   sys_statx
>>>> +333  64      copy_file_range64       sys_copy_file_range64
>>>>
>>>>  #
>>>>  # x32-specific system call numbers start at 512 to avoid cache impact
>>>> diff --git a/fs/read_write.c b/fs/read_write.c
>>>> index e3ee985..c9c072b 100644
>>>> --- a/fs/read_write.c
>>>> +++ b/fs/read_write.c
>>>> @@ -1700,7 +1700,7 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
>>>>       return ret;
>>>>  }
>>>>
>>>> -static int clone_verify_area(struct file *file, loff_t pos, u64 len, bool write)
>>>> +static int rw64_verify_area(struct file *file, loff_t pos, u64 len, bool write)
>>>>  {
>>>>       struct inode *inode = file_inode(file);
>>>>
>>>> @@ -1723,6 +1723,142 @@ static int clone_verify_area(struct file *file, loff_t pos, u64 len, bool write)
>>>>       return security_file_permission(file, write ? MAY_WRITE : MAY_READ);
>>>>  }
>>>>
>>>> +u64 vfs_copy_file_range64(struct file *file_in, loff_t pos_in,
>>>> +                         struct file *file_out, loff_t pos_out,
>>>> +                         u64 len, unsigned int flags)
>>>
>>> AFAICT the difference between vfs_copy_file_range() and
>>> vfs_copy_file_range64() is that you've replaced 'size_t len' with
>>> 'u64 len', correct?
>>
>> That and I'm asking to allow for cross-device copy to be allowed by
>> the system call.
> 
> I was fine letting each fs decide if it was going to allow cross-device
> copy or not, but Christoph argued that since we don't generally allow
> operations across mountpoints we shouldn't allow cross-mountpoint
> {clone,copy}_file_range either.
> 
> Roughly translated, XFS has no cross-device copy abilities, there aren't
> any plans to add it, so I don't feel motivated to argue for it... but if
> the nfs community is so motivated (it sounds like it) then y'all could
> try one more time.
> 
So since XFS (or any other local fs) does not have this ability,
NFS does not needed it?? That can't be the reason for the
push back that is denying NFS this ability.. 

steved.
