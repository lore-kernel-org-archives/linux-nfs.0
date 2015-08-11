Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx141.netapp.com ([216.240.21.12]:59152 "EHLO mx141.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752507AbbHKRwd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Aug 2015 13:52:33 -0400
Subject: Re: [PATCH 0/7] NFSv4.2: Add support for the COPY operation
To: "J. Bruce Fields" <bfields@fieldses.org>
References: <1438979904-8775-1-git-send-email-Anna.Schumaker@Netapp.com>
 <20150810210758.GD10455@fieldses.org>
CC: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
From: Anna Schumaker <Anna.Schumaker@netapp.com>
Message-ID: <55CA3659.1010302@Netapp.com>
Date: Tue, 11 Aug 2015 13:52:25 -0400
MIME-Version: 1.0
In-Reply-To: <20150810210758.GD10455@fieldses.org>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/10/2015 05:07 PM, J. Bruce Fields wrote:
> On Fri, Aug 07, 2015 at 04:38:16PM -0400, Anna Schumaker wrote:
>> These patches add client and server support for the NFS v4.2 COPY operation.
>> Unlike the similar CLONE operation, COPY can support both acceleration through
>> and reflink and a full copy of data from one file into another.  These patches
>> make use of Zach Brown's vfs_copy_file_range() syscall, and the first three
>> patches in this series are simply a reposting of the patches that add the
>> syscall.
>>
>> Patch 4 expands vfs_copy_file_range() to fall back on the splice interface for
>> copies where the filesystem does not support copy accelerations.  This behavior
>> is useful for NFSD, since we'll still want to copy the file even if we can't
>> do a reflink.  Additionally, this opens up the possibility of in-kernel copies
>> for all filesystems without needing to do frequent switches between kernel and
>> user space.  The only potential drawback I've noticed is that splice will write
> 
> Also on the server side it means the copy can potentially take
> arbitrarily long, right?  (And tie up a protocol slot and server thread
> the whole time?)

Potentially, but I could put in a cap like we had talked about in the past.  In practice, the VFS limits copies to slightly more than 2G because of the call to rw_verify_area().

> 
>> out data in PAGE_SIZE chunks, even if wsize > PAGE_SIZE.  This leads to a few
>> more writes over the wire, but I have not noticed a significant timing
>> difference.  Still, I wonder if there is a better way to optimize this for NFS.
> 
> Ideally, write-behind and readahead should paper over this?

I think I might have misinterpreted the RPC counts, and it is writing out chunks larger than PAGE_SIZE.  I noticed that there were twice as many writes as reads, but when I looked at wireshark I saw that each write was wsize/2.

Thanks,
Anna

> 
>>
>> The remaining patches implement the COPY operation for both the client and the
>> server.  The program I used for testing is included as an RFC as the last patch
>> in the series.  I gathered performance information by comparing the runtime and
>> RPC count of this program against /usr/bin/cp for various file sizes.
>>
>> /usr/bin/cp:
>>                       size:    513MB   1024MB   1536MB   2048MB
>> ------------- ------------- -------- -------- -------- --------
>> nfs v4 client        total:     8203    16396    24588    32780
>> ------------- ------------- -------- -------- -------- --------
>> nfs v4 client         read:     4096     8192    12288    16384
>> nfs v4 client        write:     4096     8192    12288    16384
>> nfs v4 client       commit:        1        1        1        1
>> nfs v4 client         open:        1        1        1        1
>> nfs v4 client    open_noat:        2        2        2        2
>> nfs v4 client        close:        1        1        1        1
>> nfs v4 client      setattr:        2        2        2        2
>> nfs v4 client       access:        2        3        3        3
>> nfs v4 client      getattr:        2        2        2        2
>>
>> /usr/bin/cp /nfs/test-512  /nfs/test-copy  0.00s user 0.32s system 14% cpu 2.209 total
>> /usr/bin/cp /nfs/test-1024 /nfs/test-copy  0.00s user 0.66s system 18% cpu 3.651 total
>> /usr/bin/cp /nfs/test-1536 /nfs/test-copy  0.02s user 0.97s system 18% cpu 5.477 total
>> /usr/bin/cp /nfs/test-2048 /nfs/test-copy  0.00s user 1.38s system 15% cpu 9.085 total
>>
>>
>> Copy system call:
>>                       size:    512MB   1024MB   1536MB   2048MB
>> ------------- ------------- -------- -------- -------- --------
>> nfs v4 client        total:        6        6        6        6
>> ------------- ------------- -------- -------- -------- --------
>> nfs v4 client         open:        2        2        2        2
>> nfs v4 client        close:        2        2        2        2
>> nfs v4 client       access:        1        1        1        1
>> nfs v4 client         copy:        1        1        1        1
>>
>>
>> ./nfscopy /nfs/test-512  /nfs/test-copy  0.00s user 0.00s system 0% cpu 1.148 total
>> ./nfscopy /nfs/test-1024 /nfs/test-copy  0.00s user 0.00s system 0% cpu 2.293 total
>> ./nfscopy /nfs/test-1536 /nfs/test-copy  0.00s user 0.00s system 0% cpu 3.037 total
>> ./nfscopy /nfs/test-2048 /nfs/test-copy  0.00s user 0.00s system 0% cpu 4.045 total
>>
>>
>> Questions, comments, and other testing ideas would be greatly appreciated!
>>
>> Thanks,
>> Anna
>>
>>
>> Anna Schumaker (4):
>>   VFS: Fall back on splice if no copy function defined
>>   nfsd: Pass filehandle to nfs4_preprocess_stateid_op()
>>   NFSD: Implement the COPY call
>>   NFS: Add COPY nfs operation
>>
>> Zach Brown (3):
>>   vfs: add copy_file_range syscall and vfs helper
>>   x86: add sys_copy_file_range to syscall tables
>>   btrfs: add .copy_file_range file operation
>>
>>  arch/x86/entry/syscalls/syscall_32.tbl |   1 +
>>  arch/x86/entry/syscalls/syscall_64.tbl |   1 +
>>  fs/btrfs/ctree.h                       |   3 +
>>  fs/btrfs/file.c                        |   1 +
>>  fs/btrfs/ioctl.c                       |  91 ++++++++++++----------
>>  fs/nfs/nfs42.h                         |   1 +
>>  fs/nfs/nfs42proc.c                     |  40 ++++++++++
>>  fs/nfs/nfs42xdr.c                      | 136 +++++++++++++++++++++++++++++++++
>>  fs/nfs/nfs4file.c                      |   8 ++
>>  fs/nfs/nfs4proc.c                      |   1 +
>>  fs/nfs/nfs4xdr.c                       |   1 +
>>  fs/nfsd/nfs4proc.c                     |  79 +++++++++++++++++--
>>  fs/nfsd/nfs4state.c                    |   5 +-
>>  fs/nfsd/nfs4xdr.c                      |  62 ++++++++++++++-
>>  fs/nfsd/state.h                        |   4 +-
>>  fs/nfsd/vfs.c                          |  13 ++++
>>  fs/nfsd/vfs.h                          |   1 +
>>  fs/nfsd/xdr4.h                         |  23 ++++++
>>  fs/read_write.c                        | 133 ++++++++++++++++++++++++++++++++
>>  include/linux/fs.h                     |   3 +
>>  include/linux/nfs4.h                   |   1 +
>>  include/linux/nfs_fs_sb.h              |   1 +
>>  include/linux/nfs_xdr.h                |  27 +++++++
>>  include/uapi/asm-generic/unistd.h      |   4 +-
>>  kernel/sys_ni.c                        |   1 +
>>  25 files changed, 587 insertions(+), 54 deletions(-)
>>
>> -- 
>> 2.5.0

