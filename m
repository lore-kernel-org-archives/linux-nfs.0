Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:51859 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751780Ab0HYSqR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Aug 2010 14:46:17 -0400
Received: by fxm13 with SMTP id 13so556545fxm.19
        for <linux-nfs@vger.kernel.org>; Wed, 25 Aug 2010 11:46:15 -0700 (PDT)
Subject: Re: hang in writeback code on nfsv4 mount
From: Artem Bityutskiy <dedekind1@gmail.com>
Reply-To: dedekind1@gmail.com
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond@netapp.com>, Christoph Hellwig <hch@lst.de>,
        Jens Axboe <jaxboe@fusionio.com>
In-Reply-To: <20100825154451.GB14440@fieldses.org>
References: <20100825023425.GA24591@fieldses.org>
	 <1282717945.24044.187.camel@localhost>
	 <20100825154451.GB14440@fieldses.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 25 Aug 2010 21:46:11 +0300
Message-ID: <1282761971.16502.134.camel@brekeke>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

On Wed, 2010-08-25 at 11:44 -0400, J. Bruce Fields wrote:
> > sudo mount -t nfs4 sauron:/home/dedekind/ /mnt/sauron_home/
> > 
> > works fine. Any hints about how to reproduce this are welcome.
> 
> Huh.  The simple mount hits it every time for me.  I'll investigate some
> more.

If you have any hints for me, please let me know. Note, I do not know
much about NFS and I very rarely use it. I'm very interested to
investigate this and fix, but I'm going to LinuxCon Brasil soon so not
sure I'll be able to look at this next week. But if there is a way to
reproduce this with a single laptop (without having 2 hosts separate
hosts, may be using localhost?) - I can look at this while being at the
conference as well :-)

> > I'll try to look at the code and figure out why this could happen.
> > 
> > So, does the mount at some point succeed? Or it is blocked forever? And
> > sysrq-t output would be useful to look at as well.
> 
> It's blocked forever as far as I can tell.  I'll get a sysrq-t trace.
> 
> > Also, it is strange that 'sys_mount()' involves 'nfs4_kill_super()' - is
> > this normal or this is an error path?
> 
> NFSv4 uses a temporary private namespace to look up the initial mount
> path--see c02d7adf8c5429727a98bad1d039bccad4c61c50 and preceding commits
> for explanation.  So this may well be normal (but I haven't looked at it
> closely).

Ok, thanks.

> Hm, my mount path has a mountpoint in it--if sauron:/home/dedekind/
> doesn't, then that's a difference between our setups.

Err, you mean that /home/dedekind on my NFS4 server should be a mount
point? Yes, it is an ext4 FS.

> > [1]: the kernel tree does not compile on this commit, and I applied
> > patch on top to solve the compilation issue:
> > 387ac089361fbe5ef287e6950c5c40f6b18e5c55 "block: fix missing export of
> > blk_types.h"
> 
> Maybe you only hit that if you do headers_install or headers_check?

Yes, this goes from headers_check, but I only run make -j11 and it runs
headers_check at the end, I do not do this explicitly.

Anyway, I'll try to reproduce / look at this tomorrow some more. May be
mount, then stress test, then unmount will help. I was distracted today
and did not really spend enough time to this.

Artem.

