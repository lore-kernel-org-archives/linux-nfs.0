Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17233 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753220Ab2LMLcf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Dec 2012 06:32:35 -0500
Date: Thu, 13 Dec 2012 06:31:47 -0500
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: Ricky Ng-Adam <rngadam@lophilo.com>, linux-nfs@vger.kernel.org,
        neilb@suse.de
Subject: Re: WARNING: at linux/fs/inode.c:280 drop_nlink
Message-ID: <20121213063147.44b1cf73@tlielax.poochiereds.net>
In-Reply-To: <20121112095255.5c7babcc@tlielax.poochiereds.net>
References: <CAOAMTYQ_9bPjCtobC9kfUJrgiT8hx7FsMXoi5ZgWo+P1qjDb0g@mail.gmail.com>
	<20121112095255.5c7babcc@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 12 Nov 2012 09:52:55 -0500
Jeff Layton <jlayton@redhat.com> wrote:

> On Sat, 27 Oct 2012 20:19:38 +0800
> Ricky Ng-Adam <rngadam@lophilo.com> wrote:
> 
> > A one time warning after quite a bit of usage with no other problems:
> > 
> > ------------[ cut here ]------------
> > WARNING: at /home/rngadam/lophilo/linux/fs/inode.c:280 drop_nlink+0x54/0x60()
> > Modules linked in: ipt_REDIRECT xt_tcpudp iptable_nat nf_nat
> > nf_conntrack_ipv4 nf_defrag_ipv4 nf_conntrack ip_tables x_tables
> > snd_atmel_ac97c snd_ac97_codec ac97_bus snd_pcm snd_page_alloc
> > snd_timer snd soundcore lophilo(O) ipv6 autofs4
> > [<c000dfdc>] (unwind_backtrace+0x0/0xf0) from [<c0017784>]
> > (warn_slowpath_common+0x4c/0x64)
> > [<c0017784>] (warn_slowpath_common+0x4c/0x64) from [<c00177b8>]
> > (warn_slowpath_null+0x1c/0x24)
> > [<c00177b8>] (warn_slowpath_null+0x1c/0x24) from [<c00a9084>]
> > (drop_nlink+0x54/0x60)
> > [<c00a9084>] (drop_nlink+0x54/0x60) from [<c0131268>]
> > (nfs_dentry_iput+0x38/0x50)
> > [<c0131268>] (nfs_dentry_iput+0x38/0x50) from [<c00a67b0>] (d_kill+0x9c/0xec)
> > [<c00a67b0>] (d_kill+0x9c/0xec) from [<c00a6cf0>] (dput+0x78/0x134)
> > [<c00a6cf0>] (dput+0x78/0x134) from [<c0095128>] (fput+0x194/0x238)
> > [<c0095128>] (fput+0x194/0x238) from [<c0092380>] (filp_close+0x68/0x80)
> > [<c0092380>] (filp_close+0x68/0x80) from [<c001ab88>]
> > (put_files_struct+0xb4/0xd8)
> > [<c001ab88>] (put_files_struct+0xb4/0xd8) from [<c001ad1c>]
> > (do_exit+0x134/0x72c)
> > [<c001ad1c>] (do_exit+0x134/0x72c) from [<c001b59c>] (do_group_exit+0x40/0xac)
> > [<c001b59c>] (do_group_exit+0x40/0xac) from [<c001b618>]
> > (__wake_up_parent+0x0/0x18)
> > ---[ end trace 3bda0ec3b276e040 ]---
> > 
> > client:
> > 
> > Linux lophilo 3.4.4+ #34 Sat Oct 6 16:28:57 CST 2012 armv5tejl GNU/Linux
> > 
> > server:
> > 
> > Linux rngadam-think 3.5.0-17-generic #28-Ubuntu SMP Tue Oct 9 19:32:08
> > UTC 2012 i686 i686 i686 GNU/Linux
> > 
> > # exportfs -v
> > /home/rngadam/lophilo.nfs
> > <world>(rw,async,wdelay,no_root_squash,no_subtree_check)
> > /home/rngadam/lophilo
> > <world>(rw,wdelay,root_squash,all_squash,no_subtree_check,anonuid=0,anongid=0)
> > 
> > seems to have occurred while a bunch of faiilng lstat on long paths
> > were going on:
> > 
> > stat { [Error: ENOENT, lstat
> > '/home/lophilo/lophilo/lmc/users/rngadam/lophilojs-example.git/client/code/colorpicker/img/colorpicker/img/colorpicker/img/colorpicker/js/colorpicker/css/colorpicker']
> >   errno: 34,
> >   code: 'ENOENT',
> >   path: '/home/lophilo/lophilo/lmc/users/rngadam/lophilojs-example.git/client/code/colorpicker/img/colorpicker/img/colorpicker/img/colorpicker/js/colorpicker/css/colorpicker'
> > }
> > 
> 
> The warning is fairly harmless, but it does look scary. Neil Brown had
> a patch to fix it, but I don't think Trond ever took it or commented on
> it.
> 
> Trond, any thoughts on Neil's one-line patch here?
> 
>     https://lkml.org/lkml/2012/9/25/24
> 
> (Note that I still have my doubts as to whether CIFS or NFS ought to be
> manipulating or relying on the i_nlink like this, but the patch looks
> fairly harmless as an interim fix).
> 

Hi Trond,

I asked about this a while back and never got a response. I have a
few bugs open against Fedora on this and wouldn't mind laying this to
rest. Is there any reason not to use the nfs_drop_nlink() helper in
nfs_dentry_iput()?

-- 
Jeff Layton <jlayton@redhat.com>
