Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45365 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751047AbbJJNsP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 10 Oct 2015 09:48:15 -0400
Date: Sat, 10 Oct 2015 09:48:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH v5 00/20] nfsd: open file caching
Message-ID: <20151010134813.GA13463@fieldses.org>
References: <1444042962-6947-1-git-send-email-jeff.layton@primarydata.com>
 <20151008164225.GA496@fieldses.org>
 <20151008125529.3f30308e@synchrony.poochiereds.net>
 <20151008180400.GB496@fieldses.org>
 <20151010071923.435ce037@synchrony.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20151010071923.435ce037@synchrony.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Oct 10, 2015 at 07:19:23AM -0400, Jeff Layton wrote:
> On Thu, 8 Oct 2015 14:04:00 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Thu, Oct 08, 2015 at 12:55:29PM -0400, Jeff Layton wrote:
> > > My bad...it needs this patch. I'll roll this into the set before the
> > > next posting.
> > 
> > Oh, good, thanks.
> > 
> > Also, just seen on the server side--not sure what was going on at the
> > time.
> > 
> > There were a ton of these:
> > 
> > Oct 08 12:35:07 f21-1.fieldses.org kernel: ------------[ cut here ]------------
> > Oct 08 12:35:07 f21-1.fieldses.org kernel: WARNING: CPU: 1 PID: 584 at lib/list_debug.c:59 __list_del_entry+0x9e/0xc0()
> > Oct 08 12:35:07 f21-1.fieldses.org kernel: list_del corruption.  prev->next should be ffff88004cb23f80, but was b6a7e8df8948e4eb
> > Oct 08 12:35:07 f21-1.fieldses.org kernel: Modules linked in: rpcsec_gss_krb5 nfsd auth_rpcgss oid_registry nfs_acl lockd grace sunrpc
> > Oct 08 12:35:07 f21-1.fieldses.org kernel: CPU: 1 PID: 584 Comm: fsnotify_mark Not tainted 4.3.0-rc3-14186-g7619b8e #322
> > Oct 08 12:35:07 f21-1.fieldses.org kernel: Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140709_153950- 04/01/2014
> > Oct 08 12:35:07 f21-1.fieldses.org kernel:  ffffffff81f62683 ffff880071af3d50 ffffffff8160540c ffff880071af3d98
> > Oct 08 12:35:07 f21-1.fieldses.org kernel:  ffff880071af3d88 ffffffff81077692 ffff88004cb23f80 ffffffff8109c160
> > Oct 08 12:35:07 f21-1.fieldses.org kernel:  ffff880071af3e08 ffff880071af3e30 ffff88004cb23f70 ffff880071af3de8
> > Oct 08 12:35:07 f21-1.fieldses.org kernel: Call Trace:
> > Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff8160540c>] dump_stack+0x4e/0x82
> > Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff81077692>] warn_slowpath_common+0x82/0xc0
> > Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff8109c160>] ?  sort_range+0x20/0x30
> > Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff8107771c>] warn_slowpath_fmt+0x4c/0x50
> > Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff8162219e>] __list_del_entry+0x9e/0xc0
> > Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff811ef485>] fsnotify_mark_destroy+0x95/0x140
> > Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff810baa10>] ?  wait_woken+0x90/0x90
> > Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff811ef3f0>] ?  fsnotify_put_mark+0x30/0x30
> > Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff81098d6f>] kthread+0xef/0x110
> > Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff81a767dc>] ?  _raw_spin_unlock_irq+0x2c/0x50
> > Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff81098c80>] ?  kthread_create_on_node+0x200/0x200
> > Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff81a7748f>] ret_from_fork+0x3f/0x70
> > Oct 08 12:35:07 f21-1.fieldses.org kernel:  [<ffffffff81098c80>] ?  kthread_create_on_node+0x200/0x200
> > Oct 08 12:35:07 f21-1.fieldses.org kernel: ---[ end trace 687abd8552e06b32 ]---
> > 
> 
> Thanks for the bug report! I think I understand the problem now:
> 
> It's in the way this patchset embeds a fsnotify_mark inside the
> nfsd_file. The way fsnotify_destroy_mark works sort of requires that it
> be freed separately since it wants to traverse these objects under a
> srcu read lock. The rest of the stack traces are probably collateral
> damage from that mem corruption.
> 
> I think I'll have to change the code to allocate the fsnotify_mark objects
> separately. It may also be better to have just one mark per inode and
> have each nfsd_file take a reference to the mark. I'll need to stare at
> the code a bit longer to see what makes the most sense.

OK, thanks!

--b.
