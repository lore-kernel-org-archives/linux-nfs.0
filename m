Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f169.google.com ([209.85.192.169]:33871 "EHLO
	mail-pd0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754522AbbFBBlK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Jun 2015 21:41:10 -0400
Message-ID: <556D09AF.7050003@gmail.com>
Date: Tue, 02 Jun 2015 09:41:03 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>
CC: Al Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        NeilBrown <neilb@suse.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH 0/4 v2] NFSD: Pin to vfsmount for some nfsd exports cache
References: <5561E7E4.50604@gmail.com> <20150601182155.GC26489@fieldses.org>
In-Reply-To: <20150601182155.GC26489@fieldses.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 6/2/2015 2:21 AM, J. Bruce Fields wrote:
> On Sun, May 24, 2015 at 11:01:56PM +0800, Kinglong Mee wrote:
>> If there are some mount points(not exported for nfs) under pseudo root,
>> after client's operation of those entry under the root, anyone *can't*
>> unmount those mount points until export cache expired.
> 
> Thanks for the update, apologies for the delayed response.
> 
>>
>> # cat /etc/exports
>> /nfs/xfs        *(rw,insecure,no_subtree_check,no_root_squash)
>> /nfs/pnfs       *(rw,insecure,no_subtree_check,no_root_squash)
>> # ll /nfs/
>> total 0
>> drwxr-xr-x. 3 root root 84 Apr 21 22:27 pnfs
>> drwxr-xr-x. 3 root root 84 Apr 21 22:27 test
>> drwxr-xr-x. 2 root root  6 Apr 20 22:01 xfs
>> # mount /dev/sde /nfs/test
>> # df
>> Filesystem                      1K-blocks    Used Available Use% Mounted on
>> ......
>> /dev/sdd                          1038336   32944   1005392   4% /nfs/pnfs
>> /dev/sdc                         10475520   32928  10442592   1% /nfs/xfs
>> /dev/sde                           999320    1284    929224   1% /nfs/test
>> # mount -t nfs 127.0.0.1:/nfs/ /mnt
>> # ll /mnt/*/
>> /mnt/pnfs/:
>> total 0
>> -rw-r--r--. 1 root root 0 Apr 21 22:23 attr
>> drwxr-xr-x. 2 root root 6 Apr 21 22:19 tmp
>>
>> /mnt/xfs/:
>> total 0
>> # umount /nfs/test/
>> umount: /nfs/test/: target is busy
>>         (In some cases useful info about processes that
>>          use the device is found by lsof(8) or fuser(1).)
>>
>> I don't think that's user expect, they want umount /nfs/test/.
>>
>> It's caused by exports cache of nfsd holds the reference of
>> the path (here is /nfs/test/), so, it can't be umounted.
>>
>> v1 --> v2,
>> 1. Adds an option named "allow_umount" for exports allowing user
>>    un-mounting the filesystem where nfsd exports base on.
> 
> I don't think allow_umount is a useful option.  I'd rather just make the
> code behave like allow_umount was on all the time.

Got it.

A new patch site is posted as updated from v1.

> 
> The fact is nobody could ever *depend* on umount to fail on an exported
> filesystem anyway.
> 
> I do think we might want a stronger "allow_umount" option that actually
> revokes locks and such as necessary.  I just don't see the need for this
> in between case.

Yes, it isn't.

But user always care it when umount fail, and it is late.
I think a proc file is useful than mount options like the stronger
"allow_umount". Maybe "exportfs -f" can do the job of revokes locks.

We can discuss it deeply when really need it. 

thanks,
Kinglong Mee

> 
> --b.
> 
>> 2. New helpers path_get_pin/path_put_unpin for path pin.
>> 3. Update exports according to the "allow_umount" option.
>>
>> Kinglong Mee (5):
>>   fs_pin: Fix uninitialized value in fs_pin
>>   fs_pin: Export functions for specific filesystem
>>   path: New helpers path_get_pin/path_put_unpin for path pin
>>   sunrpc: New helper cache_force_expire for cache cleanup
>>   nfsd: Allows user un-mounting filesystem where nfsd exports base on
>>
>>  fs/fs_pin.c                      |  3 +++
>>  fs/namei.c                       | 26 ++++++++++++++++++++
>>  fs/nfsd/export.c                 | 52 ++++++++++++++++++++++++++++++++--------
>>  fs/nfsd/export.h                 | 11 ++++++++-
>>  include/linux/fs_pin.h           |  6 +++++
>>  include/linux/path.h             |  4 ++++
>>  include/linux/sunrpc/cache.h     | 11 +++++++++
>>  include/uapi/linux/nfsd/export.h |  3 ++-
>>  8 files changed, 104 insertions(+), 12 deletions(-)
>>
>> -- 
>> 2.4.1
> 
