Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:33691 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755780AbbHYVQI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 17:16:08 -0400
Received: by igfj19 with SMTP id j19so22411496igf.0
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 14:16:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAHQdGtQu4_Z2XOAtA2GFTsQF8whvfOnfExonq9sp0JAJu30SBQ@mail.gmail.com>
References: <CAN-5tyFs3j2tNqm4rgsWrzO9KcFDQBfCrtNG7TNgMHrTzs9p5w@mail.gmail.com>
	<CAHQdGtQu4_Z2XOAtA2GFTsQF8whvfOnfExonq9sp0JAJu30SBQ@mail.gmail.com>
Date: Tue, 25 Aug 2015 17:16:07 -0400
Message-ID: <CAN-5tyGmzkz0e27Gt3thfjL4JNi5f1DgSZQYvSHx4u+z08KmPw@mail.gmail.com>
Subject: Re: evict inode + new open race
From: Olga Kornievskaia <aglo@umich.edu>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 25, 2015 at 4:48 PM, Trond Myklebust
<trond.myklebust@primarydata.com> wrote:
> On Tue, Aug 25, 2015 at 4:24 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
>> Hi folks,
>>
>> I have brought up earlier an existence of a race between evict inode
>> and an open where a new open happens after a delegation was removed
>> from the inode but the rpc tasks/network packets of DELEGRETURN and
>> OPEN arrive at the server in reverse order (OPEN before DELEGRETURN).
>> This particular case can be 'handled' by the server. However, there is
>> a different race that can't be.
>>
>> There is a race between an ACCESS call and a DELEGRETURN. If a cached
>> open is used but we need to check permissions, then ACCESS code will
>> go on the wire. If at the same time the evict inode process is
>> happening, ACCESS code is returned and DELEGRETURN leaves the client
>> without an open stateid or delegation stateid. There might be a race
>> between a DELEGRETURN and an OPEN when it's just cached open and
>> permissions aren't checked.
>
> If the client is doing a cached open, then how could there be a
> simultaneous evict_inode() for that inode? The dentry will be
> refcounted by the open() process, pinning the inode refcount to a
> value > 0, and preventing it from being evicted.

A very good question and I don't have a good answer. I don't fully
understand why. I'm only have proof by existence demonstrated by
Jorge. I'm staring at the code and I see i_lock is being used very
infrequently. It's possible that as the last close happened and iput()
has changed the value to 0, then before the evict() is called already
not holding the i_lock() at that time, then there is a new open
coming. while that open changes i_count, i think evict() will no
longer check i_count.

>
>> I noticed that before evict inode is called, the VFS layer will first
>> call drop_inode() function (if implemented) and based on that decision
>> it will instead of evicting put the inode back on the LRU list and
>> mark it REFERENCED.
>
> Doing so would break 'umount' in the case where there are delegations.
> It might also cause resource problems on the client, since it can no
> longer evict inodes in order to reclaim memory.

yes resource constraint problem is a problem. as for unmount, i think
that might change the superblock from being active and no longer
having MS_ACTIVE set, then the iput_final() code still proceeds to
evict the inode.

> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
