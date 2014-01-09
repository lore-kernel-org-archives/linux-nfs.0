Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f176.google.com ([209.85.213.176]:41416 "EHLO
	mail-ig0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751137AbaAIT1H convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jan 2014 14:27:07 -0500
Received: by mail-ig0-f176.google.com with SMTP id k19so16958284igc.3
        for <linux-nfs@vger.kernel.org>; Thu, 09 Jan 2014 11:27:07 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.1 \(1827\))
Subject: Re: [PATCH RFC] nfs: remove nfs_show_devname
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <20140109141259.553c58f0@tlielax.poochiereds.net>
Date: Thu, 9 Jan 2014 14:27:04 -0500
Cc: "Yin.JianHong" <jiyin@redhat.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <7AA69B49-5971-4548-BE27-B8F90D1C0F10@primarydata.com>
References: <1389293995-634-1-git-send-email-jlayton@redhat.com> <6FE57B0D-2373-4B40-BA14-E6F2BF3C44E3@primarydata.com> <20140109141259.553c58f0@tlielax.poochiereds.net>
To: Layton Jeff <jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jan 9, 2014, at 14:12, Jeff Layton <jlayton@redhat.com> wrote:

> On Thu, 9 Jan 2014 14:06:54 -0500
> Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
>> 
>> On Jan 9, 2014, at 13:59, Jeff Layton <jlayton@redhat.com> wrote:
>> 
>>> The nfs code will currently construct a devname to show in places like
>>> /proc/mounts by turning a dentry into a path. Unfortunately, that's
>>> somewhat problematic if the user ended up mounting through a symlink on
>>> the server. The devname that then shows up in /proc/mounts now doesn't
>>> match the one that was originally passed into the mount request.
>> 
>> This is 100% according to design. Why is it suddenly a problem?
>> 
>> By displaying the original pathname, you also end up bypassing referral resolution, etc. This is exactly why the .show_devname operation was introduced in the first place.
>> 
> 
> AFAIU, the main issue is that when /etc/mtab is a symlink
> to /proc/mounts, you can't do this in the example in the patch
> description:
> 
>    # mount server:/export/bar /mnt/bar
>    # umount server:/export/bar
> 
> ...since umount will try to ID the mountpoint by looking up the devname
> in /etc/mtab.

The NFS pathname is NOT a devname. It shouldn’t be abused as a substitute for a mount point.

Particularly not so when you consider that the same NFS path can be mounted in several different places with different mount options. The same path can even refer to completely different locations (i.e. different file handles) if, say, the original directory has been renamed on the server.

> What exactly would this break with referrals?
> 

It would “break” in the sense that the admin would have no clue that his client is actually talking to a different server than the one specified in the mount.

--
Trond Myklebust
Linux NFS client maintainer

