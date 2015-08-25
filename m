Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ob0-f182.google.com ([209.85.214.182]:36180 "EHLO
	mail-ob0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752074AbbHYUsI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Aug 2015 16:48:08 -0400
Received: by obkg7 with SMTP id g7so153350528obk.3
        for <linux-nfs@vger.kernel.org>; Tue, 25 Aug 2015 13:48:07 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAN-5tyFs3j2tNqm4rgsWrzO9KcFDQBfCrtNG7TNgMHrTzs9p5w@mail.gmail.com>
References: <CAN-5tyFs3j2tNqm4rgsWrzO9KcFDQBfCrtNG7TNgMHrTzs9p5w@mail.gmail.com>
Date: Tue, 25 Aug 2015 16:48:07 -0400
Message-ID: <CAHQdGtQu4_Z2XOAtA2GFTsQF8whvfOnfExonq9sp0JAJu30SBQ@mail.gmail.com>
Subject: Re: evict inode + new open race
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Olga Kornievskaia <aglo@umich.edu>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 25, 2015 at 4:24 PM, Olga Kornievskaia <aglo@umich.edu> wrote:
> Hi folks,
>
> I have brought up earlier an existence of a race between evict inode
> and an open where a new open happens after a delegation was removed
> from the inode but the rpc tasks/network packets of DELEGRETURN and
> OPEN arrive at the server in reverse order (OPEN before DELEGRETURN).
> This particular case can be 'handled' by the server. However, there is
> a different race that can't be.
>
> There is a race between an ACCESS call and a DELEGRETURN. If a cached
> open is used but we need to check permissions, then ACCESS code will
> go on the wire. If at the same time the evict inode process is
> happening, ACCESS code is returned and DELEGRETURN leaves the client
> without an open stateid or delegation stateid. There might be a race
> between a DELEGRETURN and an OPEN when it's just cached open and
> permissions aren't checked.

If the client is doing a cached open, then how could there be a
simultaneous evict_inode() for that inode? The dentry will be
refcounted by the open() process, pinning the inode refcount to a
value > 0, and preventing it from being evicted.

> I noticed that before evict inode is called, the VFS layer will first
> call drop_inode() function (if implemented) and based on that decision
> it will instead of evicting put the inode back on the LRU list and
> mark it REFERENCED.

Doing so would break 'umount' in the case where there are delegations.
It might also cause resource problems on the client, since it can no
longer evict inodes in order to reclaim memory.
