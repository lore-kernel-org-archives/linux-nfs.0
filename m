Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:53288 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756159Ab0KNXP4 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Nov 2010 18:15:56 -0500
In-Reply-To: <AANLkTik_MigWuCfJyj282GZOyEDURtJt9pgSKP7d=77_@mail.gmail.com>
References: <AANLkTik_MigWuCfJyj282GZOyEDURtJt9pgSKP7d=77_@mail.gmail.com>
Date: Mon, 15 Nov 2010 02:15:55 +0300
Message-ID: <AANLkTimB3=cVRLJD7PmiOvBgYvjHh2dn1iZB+Rnehafp@mail.gmail.com>
Subject: Re: A possible fsnotify bug.
From: Alexey Zaytsev <alexey.zaytsev@gmail.com>
To: linux-fsdevel@vger.kernel.org
Cc: Eric Paris <eparis@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        Robert Love <robert.w.love@intel.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Confirmed, the user is getting duplicate notifications. Looks like
this has been working this way since the original inotify patch. Is
this the intended behavior?

On Sun, Nov 14, 2010 at 08:14, Alexey Zaytsev <alexey.zaytsev@gmail.com> wrote:
> Hi.
>
> Have not tested, but this code in fs/nfsd/vfs.c looks suspicious:
> http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=fs/nfsd/vfs.c;h=184938fcff04d5dff712b8bee01f5d7e41bb20ad;hb=HEAD#l1032
>
> 1032         host_err = vfs_writev(file, (struct iovec __user *)vec,
> vlen, &offset);
> 1033         set_fs(oldfs);
> 1034         if (host_err < 0)
> 1035                 goto out_nfserr;
> 1036         *cnt = host_err;
> 1037         nfsdstats.io_write += host_err;
> 1038         fsnotify_modify(file);
>
> fsnotify_modify() is called from vfs_writev() -> do_readv_writev(),
> and the users are probably getting duplicate events, right?
>
