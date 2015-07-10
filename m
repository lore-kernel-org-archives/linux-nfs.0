Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:33822 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754364AbbGJQHS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Jul 2015 12:07:18 -0400
Received: by ykax123 with SMTP id x123so19184689yka.1
        for <linux-nfs@vger.kernel.org>; Fri, 10 Jul 2015 09:07:17 -0700 (PDT)
Date: Fri, 10 Jul 2015 12:07:14 -0400
From: Jeff Layton <jeff.layton@primarydata.com>
To: William Dauchy <wdauchy@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jean Spector <jean@primarydata.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        stable@vger.kernel.org, Sasha Levin <sasha.levin@oracle.com>
Subject: Re: [PATCH] nfs: take extra reference to fl->fl_file when running a
 LOCKU operation
Message-ID: <20150710120714.53893586@tlielax.poochiereds.net>
In-Reply-To: <CAJ75kXb6FRN-DY+wtvUEi53pc=tqLjA12S1X5egc4eR5pBN_MA@mail.gmail.com>
References: <1435687950-22037-1-git-send-email-jeff.layton@primarydata.com>
	<20150701093547.116dd788@tlielax.poochiereds.net>
	<CAJ75kXYQ1+_1hRun-kUq=VH2Y3wM+2SEH0zd5-j7xsq9x+RSLA@mail.gmail.com>
	<20150702060827.66fc27f1@tlielax.poochiereds.net>
	<20150710110255.66fc6452@tlielax.poochiereds.net>
	<CAJ75kXb6FRN-DY+wtvUEi53pc=tqLjA12S1X5egc4eR5pBN_MA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 10 Jul 2015 17:56:57 +0200
William Dauchy <wdauchy@gmail.com> wrote:

> On Fri, Jul 10, 2015 at 5:02 PM, Jeff Layton
> <jeff.layton@primarydata.com> wrote:
> > So, William has done some testing and hit some problems with this
> > patch. I suspect that it's because we can end up running an unlock
> > after the filp->f_count has already gone to zero and are in __fput, so
> > we take an extra reference and end up with a use-after-free.
> >
> > I think it'd be best to revert this patch from all kernels for now
> > (mainline and stable). I don't think the one that changes the setlk
> > codepath is susceptible to this, but it's probably fine to hold off on
> > applying both until I can sort out a better way to fix this one.
> 
> I also think it's safer to revert both of them.
> 

Oh? Do you have some reason to suspect the setlk patch to be
problematic? If not, then I'd rather not revert that one (at least not
from mainline) since I don't think it's likely to be a problem and it
does fix a real bug. It's your call on what you do in stable of course.

Either way, I added the warning that I described before and got this,
so I do suspect that the unlck patch is the cause of the problem:

[  373.144955] ------------[ cut here ]------------
[  373.146000] WARNING: CPU: 1 PID: 897 at fs/nfs/nfs4proc.c:5489 nfs4_do_unlck+0x294/0x2e0 [nfsv4]()
[  373.147975] Modules linked in: cts rpcsec_gss_krb5 nfsv4(OE) dns_resolver nfs(OE) fscache xfs libcrc32c snd_hda_codec_generic snd_hda_intel snd_hda_codec snd_hda_core snd_hwdep ppdev snd_seq snd_seq_device snd_pcm snd_timer snd joydev soundcore e1000 virtio_balloon i2c_piix4 pvpanic parport_pc parport acpi_cpufreq nfsd nfs_acl lockd grace auth_rpcgss sunrpc virtio_console virtio_blk qxl drm_kms_helper ttm drm ata_generic pata_acpi serio_raw virtio_pci virtio_ring virtio
[  373.156863] CPU: 1 PID: 897 Comm: flock Tainted: G           OE   4.2.0-0.rc1.git2.1.fc23.x86_64 #1
[  373.158455] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  373.159496]  0000000000000000 000000003297e63c ffff8800cd27fad8 ffffffff81864405
[  373.160856]  0000000000000000 0000000000000000 ffff8800cd27fb18 ffffffff810ab446
[  373.162295]  ffff8800cd27faf8 ffff880118d17a00 ffff880118d17a80 0000000000000000
[  373.163682] Call Trace:
[  373.164130]  [<ffffffff81864405>] dump_stack+0x4c/0x65
[  373.165053]  [<ffffffff810ab446>] warn_slowpath_common+0x86/0xc0
[  373.166262]  [<ffffffff810ab57a>] warn_slowpath_null+0x1a/0x20
[  373.167544]  [<ffffffffa046f854>] nfs4_do_unlck+0x294/0x2e0 [nfsv4]
[  373.168627]  [<ffffffffa0477a25>] nfs4_proc_lock+0x2d5/0x880 [nfsv4]
[  373.169734]  [<ffffffffa042dfe8>] do_unlk+0xa8/0xc0 [nfs]
[  373.170676]  [<ffffffffa042e311>] nfs_flock+0x71/0xa0 [nfs]
[  373.171651]  [<ffffffff812c99e6>] locks_remove_flock+0xa6/0xf0
[  373.172660]  [<ffffffff812cc9da>] locks_remove_file+0x5a/0x100
[  373.173685]  [<ffffffff8126ff23>] __fput+0xd3/0x200
[  373.174508]  [<ffffffff8127009e>] ____fput+0xe/0x10
[  373.175356]  [<ffffffff810d093d>] task_work_run+0x8d/0xc0
[  373.176339]  [<ffffffff8101cadd>] do_notify_resume+0x8d/0x90
[  373.177315]  [<ffffffff8186dda6>] int_signal+0x12/0x17
[  373.178167] ---[ end trace b7fce2dedc7eda37 ]---

I'll see if I can cook up a better way to fix this. It's a little
tricky since in the event that the task had a signal pending, the filp
may be long gone by the time the reply to the LOCKU request comes in.

So, we may need to change the prototype of locks_remove_flock to take
an inode pointer and take a reference to that instead of the filp. That
should be safe, AFAICT since we definitely still hold a reference to
the inode at that point.

-- 
Jeff Layton <jeff.layton@primarydata.com>
