From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [Bug 14868] New: flood of "don't try to register things with
 the same name in the same directory." on upgrade to 2.6.32
Date: Thu, 31 Dec 2009 02:22:30 +0100
Message-ID: <1262222550.19917.14.camel@localhost>
References: <bug-14868-104@http.bugzilla.kernel.org/>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jens Axboe <jens.axboe@oracle.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org
To: bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:50387 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752279AbZLaBWu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 30 Dec 2009 20:22:50 -0500
In-Reply-To: <bug-14868-104-V0hAGp6uBxO456/isadD/XN4h3HLQggn@public.gmane.org/>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2009-12-24 at 02:44 +0000, bugzilla-daemon-590EEB7GvNiWaY/ihj7yzEB+6BGkLq7r@public.gmane.org
wrote: 
> http://bugzilla.kernel.org/show_bug.cgi?id=14868
> 
>            Summary: flood of "don't try to register things with the same
>                     name in the same directory." on upgrade to 2.6.32
>            Product: File System
>            Version: 2.5
>     Kernel Version: 2.6.32
>           Platform: All
>         OS/Version: Linux
>               Tree: Mainline
>             Status: NEW
>           Severity: normal
>           Priority: P1
>          Component: NFS
>         AssignedTo: trond.myklebust@fys.uio.no
>         ReportedBy: rercola-YxllIAoeIHiVc3sceRu5cw@public.gmane.org
>         Regression: No
> 
> 
> Was running 2.6.31 vanilla on Fedora 10, upgraded to vanilla 2.6.32, dmesg
> started getting flooded with messages of the form [see attachment 1]:
> ------------[ cut here ]------------
> WARNING: at fs/sysfs/dir.c:491 sysfs_add_one+0x100/0x117()
> Hardware name:
> sysfs: cannot create duplicate filename '/devices/virtual/bdi/0:32'
> Modules linked in: autofs4 coretemp hwmon nfs lockd nfs_acl auth_rpcgss sunrpc
> cachefiles fscache ipv6 cpufreq_ondemand acpi_cpufreq freq_table kvm_intel kvm
> snd_hda_intel snd_hda_codec snd_seq_dummy snd_seq_oss snd_usb_audio
> snd_seq_midi_event snd_seq snd_usb_lib uvcvideo ppdev firewire_ohci
> firewire_core snd_pcm_oss snd_mixer_oss crc_itu_t pcspkr snd_rawmidi videodev
> v4l1_compat v4l2_compat_ioctl32 i2c_i801 snd_pcm i2c_core snd_seq_device
> usb_storage iTCO_wdt iTCO_vendor_support snd_hwdep snd_timer parport_pc snd
> parport e1000e i82975x_edac edac_core soundcore snd_page_alloc raid1 [last
> unloaded: scsi_wait_scan]
> Pid: 20581, comm: mount.nfs Tainted: G        W  2.6.32-fun #1
> ...
> ---[ end trace b4d582dc9db911d1 ]---
> kobject_add_internal failed for 0:32 with -EEXIST, don't try to register things
> with the same name in the same directory.
> Pid: 20581, comm: mount.nfs Tainted: G        W  2.6.32-fun #1
> ...
> 
> The system is indeed using autofs, so I'd blame NFS-mounts  from FreeBSD for
> this, but it wasn't cropping up in 2.6.31.

It appears to be due to the per-bdi thread changes in 2.6.32. The
support for anonymous devices has a problem in that sysfs and debugfs
directories and files can be kept open by other processes even after the
device number gets deallocated.

> I've also attached the .config for the 2.6.31 and 2.6.32 kernels, in case it's
> something stupid I missed.


Are you perhaps running some daemon or process that is
accessing /sys/devices/virtual/bdi/0:32 and keeping it open beyond the
lifetime of the NFS mount?

Trond

