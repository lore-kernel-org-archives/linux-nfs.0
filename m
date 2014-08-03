Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f176.google.com ([209.85.220.176]:59176 "EHLO
	mail-vc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751739AbaHCXOT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 3 Aug 2014 19:14:19 -0400
Received: by mail-vc0-f176.google.com with SMTP id id10so9840108vcb.35
        for <linux-nfs@vger.kernel.org>; Sun, 03 Aug 2014 16:14:18 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140804090328.0068952f@notabene.brown>
References: <53deb592.cf6oANONk2xIr46y%fengguang.wu@intel.com>
	<20140804090328.0068952f@notabene.brown>
Date: Sun, 3 Aug 2014 19:14:18 -0400
Message-ID: <CAHQdGtRYzKZiJLEuKAPWyE7j=H0-ymLJ-mpj+k1=eNY-MR70vA@mail.gmail.com>
Subject: Re: [nfs:testing 56/61] fs/nfs/dir.c:1092:26: sparse: incompatible
 types in comparison expression (different address spaces)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: NeilBrown <neilb@suse.de>
Cc: kbuild test robot <fengguang.wu@intel.com>, kbuild-all@01.org,
        NFS <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Aug 3, 2014 at 7:03 PM, NeilBrown <neilb@suse.de> wrote:
> On Mon, 04 Aug 2014 06:20:02 +0800 kbuild test robot <fengguang.wu@intel.com>
> wrote:
>
>> tree:   git://git.linux-nfs.org/projects/trondmy/linux-nfs.git testing
>> head:   f682a398b2e24ae0a775ddf37cced83b897198ee
>> commit: d51ac1a8e9b86b2d17d349bb256869cab6522787 [56/61] NFS: prepare for RCU-walk support but pushing tests later in code.
>> reproduce: make C=1 CF=-D__CHECK_ENDIAN__
>>
>>
>> sparse warnings: (new ones prefixed by >>)
>>
>> >> fs/nfs/dir.c:1092:26: sparse: incompatible types in comparison expression (different address spaces)
>> >> fs/nfs/dir.c:1169:31: sparse: incompatible types in comparison expression (different address spaces)
>>
>> vim +1092 fs/nfs/dir.c
>>
>>   1086                struct nfs_fh *fhandle = NULL;
>>   1087                struct nfs_fattr *fattr = NULL;
>>   1088                struct nfs4_label *label = NULL;
>>   1089                int error;
>>   1090
>>   1091                if (flags & LOOKUP_RCU) {
>> > 1092                        parent = rcu_dereference(dentry->d_parent);
>>   1093                        dir = ACCESS_ONCE(parent->d_inode);
>>   1094                        if (!dir)
>>   1095                                return -ECHILD;
>
> Hmmm.. I suspect rcu_dereference doesn't really make sense here.
> After all, d_parent is not assigned with rcu_assign_ptr, and no-one else uses
> rcu_dereference for it.
>
> The issue is that, without locks, d_parent could change at any point.
> As dentries are freed with call_rcu it is safe to follow any pointers we find,
> but there is a limit how much we can trust them.
> It is very likely that any change to d_parent that mattered would increment
> some seqlock so that RCU-walk would eventually abort.
>
>
> So we may not need the
>
>> > 1169                        if (parent != rcu_dereference(dentry->d_parent))
>>   1170                                return -ECHILD;
>
> at the end, as a seqlock will probably catch any problem.

My main worry with that argument is whether or not the d_seq protected
lookups are guaranteed to always cover the parent. I can't see
anything in Documentation/filesystems/path-lookup.txt that indicates
that they must be.

> Without that we don't even need to store 'parent' at all, just
>      dir = ACCESS_ONCE(dentry->d_parent->d_inode);
>
> If we keep it, which is probably safest, then using ACCESS_ONCE in place of
> the current rcu_dereference() make sense.
>
>      parent = ACCESS_ONCE(dentry->d_parent);
>      dir = ACCESS_ONCE(dir->d_inode);
>
> ...
>
>      if (parent != ACCESS_ONCE(dentry->d_parent))
>             return -ECHILD;
>
>
> Trond, would you like me to resend that patch, or do you want to just
> s/rcu_derefence/ACCESS_ONCE/
> ??

Could you send an incremental patch?

Thanks!
  Trond


-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
