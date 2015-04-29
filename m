Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36231 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1422668AbbD2LeN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Apr 2015 07:34:13 -0400
Received: by pabsx10 with SMTP id sx10so25444251pab.3
        for <linux-nfs@vger.kernel.org>; Wed, 29 Apr 2015 04:34:13 -0700 (PDT)
Message-ID: <5540C1AF.9020908@gmail.com>
Date: Wed, 29 Apr 2015 19:34:07 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Steve Dickson <SteveD@redhat.com>, NeilBrown <neilb@suse.de>,
        kinglongmee@gmail.com
Subject: Re: [PATCH] NFSD: Avoid race of locking parent's mutex at cross mount
References: <553FB0E7.7070601@gmail.com> <20150428213644.GE16090@fieldses.org>
In-Reply-To: <20150428213644.GE16090@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Cc Neil Brown,

On 4/29/2015 5:36 AM, J. Bruce Fields wrote:
> On Wed, Apr 29, 2015 at 12:10:15AM +0800, Kinglong Mee wrote:
>> When testing pseudo root, there is a mutex race between
>> nfsd and rpc.mountd for locking parent inode.
> 
> Thanks for investigating this!

My tests,
# cat /etc/exports
/nfs/xfs        *(rw,insecure,no_subtree_check,no_root_squash,crossmnt)
/nfs/pnfs       *(rw,insecure,no_subtree_check,no_root_squash,crossmnt)
# df | grep nfs
/dev/sde                          999320    1284   929224    1% /nfs/test
/dev/sdc                        10475520   32948 10442572    1% /nfs/xfs
/dev/sdd                         1038336   34160  1004176    4% /nfs/pnfs
# ls /nfs/
aclocal.m4     config.sub     cscope.po.out  ltmain.sh    pnfs
autogen.sh     configure      depcomp        Makefile     README
compile        configure.ac   hello          Makefile.am  tags
config.guess   COPYING        INSTALL        Makefile.in  test
config.log     cscope.in.out  install-sh     missing      test-driver
config.status  cscope.out     libtool        NEWS         xfs

# mount -t nfs 127.0.0.1:/nfs /mnt
# ll /mnt/*/
 ------------ hang here ------

> 
>> nfs-utils commit 6091c0a4c4 
>> ("mountd: add support for case-insensitive file names")
>> adds using name_to_handle_at which will locking parent.
>>
> 
> My first impulse is to blame nfs-utils, if it was really that commit
> that introduced the problem....
> 
> But waiting on mountd while holding this i_mutex does seem a little
> scary.  All it takes is an uncached lookup on the same directory, and a
> stat could do that, right?

Stat operation will go though the lookup_slow the first time.

Apr 29 18:16:16 ntest kernel: rpc.mountd      D ffff8800454dfb98     0  3874   1004 0x00000000
Apr 29 18:16:16 ntest kernel: ffff8800454dfb98 ffff880069a512e0 ffff880056888000 ffff8800454dfb78
Apr 29 18:16:16 ntest kernel: ffff8800454e0000 ffff880035ee2874 ffff880056888000 00000000ffffffff
Apr 29 18:16:16 ntest kernel: ffff880035ee2878 ffff8800454dfbb8 ffffffff8177fda7 0000000000000000
Apr 29 18:16:16 ntest kernel: Call Trace:
Apr 29 18:16:16 ntest kernel: [<ffffffff8177fda7>] schedule+0x37/0x90
Apr 29 18:16:16 ntest kernel: [<ffffffff817800ee>] schedule_preempt_disabled+0xe/0x10
Apr 29 18:16:16 ntest kernel: [<ffffffff81781c62>] __mutex_lock_slowpath+0xb2/0x120
Apr 29 18:16:16 ntest kernel: [<ffffffff81781cf3>] mutex_lock+0x23/0x40
Apr 29 18:16:16 ntest kernel: [<ffffffff81230714>] lookup_slow+0x34/0xc0
Apr 29 18:16:16 ntest kernel: [<ffffffff812358ee>] path_lookupat+0x89e/0xc60
Apr 29 18:16:16 ntest kernel: [<ffffffff81205192>] ? kmem_cache_alloc+0x1e2/0x260
Apr 29 18:16:16 ntest kernel: [<ffffffff812367a6>] ? getname_flags+0x56/0x200
Apr 29 18:16:16 ntest kernel: [<ffffffff81235cd7>] filename_lookup+0x27/0xc0
Apr 29 18:16:16 ntest kernel: [<ffffffff81237b53>] user_path_at_empty+0x63/0xd0
Apr 29 18:16:16 ntest kernel: [<ffffffff8121d310>] ? memory_failure_work_func+0xc0/0xc0
Apr 29 18:16:16 ntest kernel: [<ffffffff81237bd1>] user_path_at+0x11/0x20
Apr 29 18:16:16 ntest kernel: [<ffffffff8122a47a>] vfs_fstatat+0x6a/0xd0
Apr 29 18:16:16 ntest kernel: [<ffffffff8122aa61>] SYSC_newlstat+0x31/0x60
Apr 29 18:16:16 ntest kernel: [<ffffffff8122f1b2>] ? path_put+0x22/0x30
Apr 29 18:16:16 ntest kernel: [<ffffffff812865a1>] ? SyS_name_to_handle_at+0x171/0x200
Apr 29 18:16:16 ntest kernel: [<ffffffff8122ab9e>] SyS_newlstat+0xe/0x10
Apr 29 18:16:16 ntest kernel: [<ffffffff81783d2e>] system_call_fastpath+0x12/0x71

Before the upcall to rpc.mountd, nfsd have call lookup_one_len() for the file,
but I don't known why rpc.mountd will go though lookup_slow again?

thanks,
Kinglong Mee
