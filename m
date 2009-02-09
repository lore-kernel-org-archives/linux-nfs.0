From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: processes in D state too long too often
Date: Mon, 9 Feb 2009 16:27:51 -0500
Message-ID: <20090209212751.GK13636@fieldses.org>
References: <W396157575167661234039767@webmail27>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>
To: "Gary L. Grobe" <gary-QhKe0p0S2m1eoWH0uzbU5w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:37957 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754088AbZBIV1o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Feb 2009 16:27:44 -0500
In-Reply-To: <W396157575167661234039767@webmail27>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

(By the way, please try not to start new threads or drop people from the
cc.)

On Sat, Feb 07, 2009 at 08:49:27PM +0000, Gary L. Grobe wrote:
> > Then send us those traces. Please try to avoid wordwrapping them in
> the email.
> 
> Ok, so I run my simulations, and then run the following script. 
> 
> --- This was run on the master node
> echo w > /proc/sysrq-trigger
> dmesg -c -s 1000000 > foo
> 
> I've captured these stuck tasks on both the master and the slave node, on separate runs.

So the nfsd stacks are all identical:

> nfsd          D 00000001079318f8     0  5832      2
>  ffff880837a23c70 0000000000000046 0000000000000000 0000000000000002
>  ffff88083aef5950 ffff88083cda5790 ffff88083aef5b80 0000000437a23c80
>  00000000ffffffff 00000001079318fb 0000000000000000 0000000000000000
> Call Trace:
>  [<ffffffff8056e8e3>] schedule_timeout+0x8a/0xad
>  [<ffffffff80237e8b>] process_timeout+0x0/0x5
>  [<ffffffff8056e8de>] schedule_timeout+0x85/0xad
>  [<ffffffff80238178>] msleep+0x14/0x1e
>  [<ffffffff8030235d>] nfsd_vfs_write+0x221/0x2dd
>  [<ffffffff8028222b>] __dentry_open+0x14c/0x23b
>  [<ffffffff80302a93>] nfsd_write+0xc5/0xe2
>  [<ffffffff803003bd>] nfsd_proc_write+0xc5/0xde
>  [<ffffffff80307ac1>] decode_fh+0x1c/0x45
>  [<ffffffff802fe8f3>] nfsd_dispatch+0xde/0x1c2
>  [<ffffffff805456f5>] svc_process+0x408/0x6e7
>  [<ffffffff8056f920>] __down_read+0x12/0x93
>  [<ffffffff802fef26>] nfsd+0x1b7/0x285
>  [<ffffffff802fed6f>] nfsd+0x0/0x285
>  [<ffffffff80240d34>] kthread+0x47/0x73
>  [<ffffffff8022bd1d>] schedule_tail+0x27/0x5f
>  [<ffffffff8020c109>] child_rip+0xa/0x11
>  [<ffffffff80240ced>] kthread+0x0/0x73
>  [<ffffffff8020c0ff>] child_rip+0x0/0x11

Presumably that's the msleep(10) in nfsd_vfs_write().

That wouldn't explain the same nfsd thread waiting for several seconds,
though.  Or was it just that that several seconds during which different
nfsd threads were stuck in D, not necessarily the same ones?

What does your /etc/exports file look like on the server, and what are
the mount options on the client?

You could try turning off that msleep() with no_wdelay, but it may not
help.

The more likely explanation is that you just switched to a more recent
distro where "sync" (as opposed to "async") is the option.  Depending on
workload, "async" may improve performance a great deal, at the expense
of possible data corruption on server reboot!

If you're doing a lot of writing and using NFSv2, then switching to
NFSv3 may give you performance close to the "async" performance without
the corruption worries.

--b.
