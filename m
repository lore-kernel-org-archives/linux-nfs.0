Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:41354 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2388043AbeGTTaW (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 20 Jul 2018 15:30:22 -0400
Received: by mail-ua0-f194.google.com with SMTP id t14-v6so8047843uao.8
        for <linux-nfs@vger.kernel.org>; Fri, 20 Jul 2018 11:40:51 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyHcrOFMmcnWC8svkiTU5B1ZqJVG03SoQCP1n9zdTTvJeA@mail.gmail.com>
References: <CAN-5tyH75NZyiZ43_--oGOcugYiyQk=soBs5XwMq91uRX4+2hA@mail.gmail.com>
 <7cccfa69267c44dbb629b154ee942df8280875bc.camel@hammerspace.com> <CAN-5tyHcrOFMmcnWC8svkiTU5B1ZqJVG03SoQCP1n9zdTTvJeA@mail.gmail.com>
From: Olga Kornievskaia <aglo@umich.edu>
Date: Fri, 20 Jul 2018 14:40:49 -0400
Message-ID: <CAN-5tyGqP1uOBTV9xd-CJ4HhdnQP9O66Rbm1nNoj5HhYMN=1Nw@mail.gmail.com>
Subject: Re: sending duplicate GETATTRs
To: Trond Myklebust <trondmy@hammerspace.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 20, 2018 at 2:17 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> On Fri, Jul 20, 2018 at 2:05 PM, Trond Myklebust
> <trondmy@hammerspace.com> wrote:
>> On Fri, 2018-07-20 at 13:26 -0400, Olga Kornievskaia wrote:
>>> Hi Trond,
>>>
>>> I would some help understanding attributes management.
>>>
>>> Right now, any time a directory inode that was marked with
>>> INVALID_ACCESS (say to a change_attribute changed) ends up triggering
>>> sending a duplicate GETATTR. I don't think that's correct.
>>>
>>> In nfs_execute_ok() we check if (nfs_check_cache_invalid(inode,
>>> NFS_INO_INVALID_ACCESS)) and the call __nfs_revalidate_inode() which
>>> will trigger GETATTR. I don't understand why after calling this
>>> function the INVALID_ACCESS doesn't get cleared? Because that's what
>>> causes the double GETATTR to be sent.
>>>
>>> On the open path, the first time the getattr is sent is in
>>>
>>> Jul 19 15:39:52 ipa18 kernel: dump_stack+0x5a/0x73
>>> Jul 19 15:39:52 ipa18 kernel: nfs4_proc_getattr+0x65/0x110 [nfsv4]
>>> Jul 19 15:39:52 ipa18 kernel: __nfs_revalidate_inode+0xe1/0x370 [nfs]
>>> Jul 19 15:39:52 ipa18 kernel: nfs_permission+0x16b/0x1f0 [nfs]
>>> Jul 19 15:39:52 ipa18 kernel: inode_permission+0xab/0x130
>>> Jul 19 15:39:52 ipa18 kernel: link_path_walk+0x29d/0x520
>>> Jul 19 15:39:52 ipa18 kernel: path_openat+0xf6/0x1230
>>> Jul 19 15:39:52 ipa18 kernel: do_filp_open+0x91/0x100
>>> Jul 19 15:39:52 ipa18 kernel: do_sys_open+0x126/0x210
>>> Jul 19 15:39:52 ipa18 kernel: do_syscall_64+0x55/0x180
>>> Jul 19 15:39:52 ipa18 kernel:
>>> entry_SYSCALL_64_after_hwframe+0x44/0xa9
>>>
>>> And then again during the open
>>>
>>> Jul 19 15:39:52 ipa18 kernel: dump_stack+0x5a/0x73
>>> Jul 19 15:39:52 ipa18 kernel: nfs4_proc_getattr+0x65/0x110 [nfsv4]
>>> Jul 19 15:39:52 ipa18 kernel: __nfs_revalidate_inode+0xe1/0x370 [nfs]
>>> Jul 19 15:39:52 ipa18 kernel: nfs_permission+0x16b/0x1f0 [nfs]
>>> Jul 19 15:39:52 ipa18 kernel: inode_permission+0xab/0x130
>>> Jul 19 15:39:52 ipa18 kernel: path_openat+0x942/0x1230
>>> Jul 19 15:39:52 ipa18 kernel: do_filp_open+0x91/0x100
>>> Jul 19 15:39:52 ipa18 kernel: do_sys_open+0x126/0x210
>>> Jul 19 15:39:52 ipa18 kernel: do_syscall_64+0x55/0x180
>>> Jul 19 15:39:52 ipa18 kernel:
>>> entry_SYSCALL_64_after_hwframe+0x44/0xa9
>>>
>>> Can't we remove INVALID_ACCESS after we revalidated the inode? This
>>> removes the duplicated GETATTRs. Is this a valid way of fixing this
>>> issue?
>>>
>>> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
>>> index 8f8e9e9..2b55a45 100644
>>> --- a/fs/nfs/dir.c
>>> +++ b/fs/nfs/dir.c
>>> @@ -2504,6 +2504,8 @@ static int nfs_execute_ok(struct inode *inode,
>>> int mask)
>>>                 if (mask & MAY_NOT_BLOCK)
>>>                         return -ECHILD;
>>>                 ret = __nfs_revalidate_inode(server, inode);
>>> +               if (!ret)
>>> +                       NFS_I(inode)->cache_validity &=
>>> ~NFS_INO_INVALID_ACCESS;
>>>         }
>>>         if (ret == 0 && !execute_ok(inode))
>>>                 ret = -EACCES;
>>
>>
>> I don't see how the above makes sense.
>>
>> Either the attribute revalidation confirmed that the change attr, mode
>> + uid + gid are unchanged, in which case the call to
>> nfs_refresh_inode() during revalidation will fail to set
>> NFS_INO_INVALID_ACCESS, or it confirmed that at least one of them has
>> changed, in which case we do want to revalidate the access cache.
>
> I'm confused as to against what are we checking then?
>
> We flagged a directory inode to have invalid attributes. So we sent a
> GETATTR. I would think that after getting the result all our
> attributes should be valid. Why would a client as the next operation
> send another GETATTR for the same inode?
>

I didn't answer your question but rather explained what I see client do.

Let's me see if I can try again:
in nfs_execute_ok() the check for the INVALID_CACHE is true so the
code calls __nfs_revalidate_inode() which ends up sending a GETATTR.
Could it be that what's happening is that GETATTRs reply for the
change_attr is different than what we have stored. BUT that's obvious,
we knew that to begin with since we are validating the attributes. So
we update it and then we send another GETATTR now the GETATTR sends
back the "same" change_attr and this time it matches what we have
stored. Why is this 2nd GETATTR necessary? The attribute should be
marked as valid after a getting a successful GETATTR.

>>
>> --
>> Trond Myklebust
>> Linux NFS client maintainer, Hammerspace
>> trond.myklebust@hammerspace.com
>>
