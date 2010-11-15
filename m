Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36904 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932948Ab0KORYW (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Nov 2010 12:24:22 -0500
Date: Mon, 15 Nov 2010 12:24:17 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Alexey Zaytsev <alexey.zaytsev@gmail.com>
Cc: linux-fsdevel@vger.kernel.org, Eric Paris <eparis@redhat.com>,
        Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        Robert Love <robert.w.love@intel.com>
Subject: Re: A possible fsnotify bug.
Message-ID: <20101115172416.GA10044@fieldses.org>
References: <AANLkTik_MigWuCfJyj282GZOyEDURtJt9pgSKP7d=77_@mail.gmail.com>
 <AANLkTimB3=cVRLJD7PmiOvBgYvjHh2dn1iZB+Rnehafp@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
In-Reply-To: <AANLkTimB3=cVRLJD7PmiOvBgYvjHh2dn1iZB+Rnehafp@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, Nov 15, 2010 at 02:15:55AM +0300, Alexey Zaytsev wrote:
> Confirmed, the user is getting duplicate notifications. Looks like
> this has been working this way since the original inotify patch. Is
> this the intended behavior?

I can't think of any reason for the nfsd code to be diong the
notification itself--looks like just a mistake to me.

--b.

> 
> On Sun, Nov 14, 2010 at 08:14, Alexey Zaytsev <alexey.zaytsev@gmail.com> wrote:
> > Hi.
> >
> > Have not tested, but this code in fs/nfsd/vfs.c looks suspicious:
> > http://git.kernel.org/?p=linux/kernel/git/torvalds/linux-2.6.git;a=blob;f=fs/nfsd/vfs.c;h=184938fcff04d5dff712b8bee01f5d7e41bb20ad;hb=HEAD#l1032
> >
> > 1032         host_err = vfs_writev(file, (struct iovec __user *)vec,
> > vlen, &offset);
> > 1033         set_fs(oldfs);
> > 1034         if (host_err < 0)
> > 1035                 goto out_nfserr;
> > 1036         *cnt = host_err;
> > 1037         nfsdstats.io_write += host_err;
> > 1038         fsnotify_modify(file);
> >
> > fsnotify_modify() is called from vfs_writev() -> do_readv_writev(),
> > and the users are probably getting duplicate events, right?
> >
