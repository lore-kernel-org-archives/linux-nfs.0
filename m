Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailout-de.gmx.net ([213.165.64.23]:55590 "HELO
	mailout-de.gmx.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1757210Ab2FEOVb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2012 10:21:31 -0400
Message-ID: <4FCE15E6.7090006@gmx.de>
Date: Tue, 05 Jun 2012 16:21:26 +0200
From: =?ISO-8859-1?Q?Toralf_F=F6rster?= <toralf.foerster@gmx.de>
MIME-Version: 1.0
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
CC: Ondrej Zary <linux@rainbow-software.org>, Hugh Dickins <hughd@google.com>,
        Kernel development list <linux-kernel@vger.kernel.org>,
        Dave Jones <davej@redhat.com>, Hans de Bruin <jmdebruin@xmsnet.nl>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        richard -rw- weinberger <richard.weinberger@gmail.com>
Subject: Re: [bisected commit 0fc9d10] NFS-server corruption with 3.4
References: <201206051116.17711.linux@rainbow-software.org> <4FCE0A83.4050502@openvz.org>
In-Reply-To: <4FCE0A83.4050502@openvz.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/05/2012 03:32 PM, Konstantin Khlebnikov wrote:
> 
> [all reporters added to CC] let's keep all in one thread
> 
> In attachment two patches which might help to debug this regression:

Hi Konstantin,

the output after applying your 2 patches om top of current git tree is
shown below. FWIW reverting commit 0fc9d10 on top of 99becf1 solves the
issue for me.


2012-06-05T16:12:29.745+02:00 n22 kernel: ------------[ cut here
]------------
2012-06-05T16:12:29.746+02:00 n22 kernel: WARNING: at mm/filemap.c:940
find_get_pages_contig+0x16a/0x1a0()
2012-06-05T16:12:29.746+02:00 n22 kernel: Hardware name: 6474B84
2012-06-05T16:12:29.746+02:00 n22 kernel: Modules linked in: loop fuse
dm_mod usblp hid_generic hid_cherry i915 usbhid hid fbcon font bitblit
softcursor drm_kms_helper drm fb fbdev intel_agp cfbcopyarea
i2c_algo_bit intel_gtt 8250_pci 8250 cfbimgblt i2c_i801 sr_mod
thinkpad_acpi hwmon video acpi_cpufreq nvram ac thermal sg evdev psmouse
serial_core i2c_core cdrom agpgart button battery mperf processor wmi
cfbfillrect [last unloaded: microcode]
2012-06-05T16:12:29.746+02:00 n22 kernel: Pid: 2359, comm: loop0 Not
tainted 3.5.0-rc1-00037-g99becf1-dirty #21
2012-06-05T16:12:29.746+02:00 n22 kernel: Call Trace:
2012-06-05T16:12:29.746+02:00 n22 kernel: [<c102e632>]
warn_slowpath_common+0x72/0xa0
2012-06-05T16:12:29.746+02:00 n22 kernel: [<c10c07aa>] ?
find_get_pages_contig+0x16a/0x1a0
2012-06-05T16:12:29.746+02:00 n22 kernel: [<c10c07aa>] ?
find_get_pages_contig+0x16a/0x1a0
2012-06-05T16:12:29.746+02:00 n22 kernel: [<c102e682>]
warn_slowpath_null+0x22/0x30
2012-06-05T16:12:29.746+02:00 n22 kernel: [<c10c07aa>]
find_get_pages_contig+0x16a/0x1a0
2012-06-05T16:12:29.746+02:00 n22 kernel: [<c11240fc>] ?
splice_to_pipe+0xec/0x1f0
2012-06-05T16:12:29.746+02:00 n22 kernel: [<c1124907>]
__generic_file_splice_read+0xe7/0x550
2012-06-05T16:12:29.746+02:00 n22 kernel: [<c1062508>] ?
load_balance+0x88/0x5a0
2012-06-05T16:12:29.746+02:00 n22 kernel: [<c105e6b4>] ?
update_cfs_load+0x284/0x290
2012-06-05T16:12:29.746+02:00 n22 kernel: [<f8494db4>] ?
transfer_none+0x54/0x80 [loop]
2012-06-05T16:12:29.746+02:00 n22 kernel: [<f84945ba>] ?
lo_splice_actor+0xaa/0xe0 [loop]
2012-06-05T16:12:29.747+02:00 n22 kernel: [<c1123430>] ?
page_cache_pipe_buf_release+0x20/0x20
2012-06-05T16:12:29.747+02:00 n22 kernel: [<c1124e0c>]
generic_file_splice_read+0x9c/0x100
2012-06-05T16:12:29.747+02:00 n22 kernel: [<c1124d70>] ?
__generic_file_splice_read+0x550/0x550
2012-06-05T16:12:29.747+02:00 n22 kernel: [<c11238f5>]
do_splice_to+0x65/0x80
2012-06-05T16:12:29.747+02:00 n22 kernel: [<c1123b65>]
splice_direct_to_actor+0xb5/0x1f0
2012-06-05T16:12:29.747+02:00 n22 kernel: [<f8494c40>] ?
loop_thread+0x510/0x510 [loop]
2012-06-05T16:12:29.747+02:00 n22 kernel: [<f84948b1>]
loop_thread+0x181/0x510 [loop]
2012-06-05T16:12:29.747+02:00 n22 kernel: [<f84945f0>] ?
lo_splice_actor+0xe0/0xe0 [loop]
2012-06-05T16:12:29.747+02:00 n22 kernel: [<f8494730>] ?
do_lo_send_write+0xe0/0xe0 [loop]
2012-06-05T16:12:29.747+02:00 n22 kernel: [<c104cacc>] kthread+0x7c/0x90
2012-06-05T16:12:29.747+02:00 n22 kernel: [<c104ca50>] ?
flush_kthread_worker+0xb0/0xb0
2012-06-05T16:12:29.747+02:00 n22 kernel: [<c1379cbe>]
kernel_thread_helper+0x6/0x10
2012-06-05T16:12:29.747+02:00 n22 kernel: ---[ end trace
00cc617101264b7f ]---
2012-06-05T16:12:29.784+02:00 n22 kernel: ------------[ cut here
]------------
2012-06-05T16:12:29.785+02:00 n22 kernel: WARNING: at mm/filemap.c:940
find_get_pages_contig+0x16a/0x1a0()
2012-06-05T16:12:29.785+02:00 n22 kernel: Hardware name: 6474B84
2012-06-05T16:12:29.785+02:00 n22 kernel: Modules linked in: loop fuse
dm_mod usblp hid_generic hid_cherry i915 usbhid hid fbcon font bitblit
softcursor drm_kms_helper drm fb fbdev intel_agp cfbcopyarea
i2c_algo_bit intel_gtt 8250_pci 8250 cfbimgblt i2c_i801 sr_mod
thinkpad_acpi hwmon video acpi_cpufreq nvram ac thermal sg evdev psmouse
serial_core i2c_core cdrom agpgart button battery mperf processor wmi
cfbfillrect [last unloaded: microcode]
2012-06-05T16:12:29.785+02:00 n22 kernel: Pid: 2359, comm: loop0
Tainted: G        W    3.5.0-rc1-00037-g99becf1-dirty #21
2012-06-05T16:12:29.785+02:00 n22 kernel: Call Trace:
2012-06-05T16:12:29.785+02:00 n22 kernel: [<c102e632>]
warn_slowpath_common+0x72/0xa0
2012-06-05T16:12:29.785+02:00 n22 kernel: [<c10c07aa>] ?
find_get_pages_contig+0x16a/0x1a0
2012-06-05T16:12:29.785+02:00 n22 kernel: [<c10c07aa>] ?
find_get_pages_contig+0x16a/0x1a0
2012-06-05T16:12:29.785+02:00 n22 kernel: [<c102e682>]
warn_slowpath_null+0x22/0x30
2012-06-05T16:12:29.785+02:00 n22 kernel: [<c10c07aa>]
find_get_pages_contig+0x16a/0x1a0
2012-06-05T16:12:29.785+02:00 n22 kernel: [<c11240fc>] ?
splice_to_pipe+0xec/0x1f0
2012-06-05T16:12:29.785+02:00 n22 kernel: [<c1124907>]
__generic_file_splice_read+0xe7/0x550
2012-06-05T16:12:29.785+02:00 n22 kernel: [<c10610d5>] ?
enqueue_entity+0xd5/0x210
2012-06-05T16:12:29.785+02:00 n22 kernel: [<c10599e5>] ?
check_preempt_curr+0x65/0x90
2012-06-05T16:12:29.785+02:00 n22 kernel: [<c1059a40>] ?
ttwu_do_wakeup+0x30/0x110
2012-06-05T16:12:29.785+02:00 n22 kernel: [<f8494db4>] ?
transfer_none+0x54/0x80 [loop]
2012-06-05T16:12:29.785+02:00 n22 kernel: [<f84945ba>] ?
lo_splice_actor+0xaa/0xe0 [loop]
2012-06-05T16:12:29.785+02:00 n22 kernel: [<c1123430>] ?
page_cache_pipe_buf_release+0x20/0x20
2012-06-05T16:12:29.785+02:00 n22 kernel: [<c1124e0c>]
generic_file_splice_read+0x9c/0x100
2012-06-05T16:12:29.786+02:00 n22 kernel: [<c1124d70>] ?
__generic_file_splice_read+0x550/0x550
2012-06-05T16:12:29.786+02:00 n22 kernel: [<c11238f5>]
do_splice_to+0x65/0x80
2012-06-05T16:12:29.786+02:00 n22 kernel: [<c1123b65>]
splice_direct_to_actor+0xb5/0x1f0
2012-06-05T16:12:29.786+02:00 n22 kernel: [<f8494c40>] ?
loop_thread+0x510/0x510 [loop]
2012-06-05T16:12:29.786+02:00 n22 kernel: [<f84948b1>]
loop_thread+0x181/0x510 [loop]
2012-06-05T16:12:29.786+02:00 n22 kernel: [<f84945f0>] ?
lo_splice_actor+0xe0/0xe0 [loop]
2012-06-05T16:12:29.786+02:00 n22 kernel: [<f8494730>] ?
do_lo_send_write+0xe0/0xe0 [loop]
2012-06-05T16:12:29.786+02:00 n22 kernel: [<c104cacc>] kthread+0x7c/0x90
2012-06-05T16:12:29.786+02:00 n22 kernel: [<c104ca50>] ?
flush_kthread_worker+0xb0/0xb0
2012-06-05T16:12:29.786+02:00 n22 kernel: [<c1379cbe>]
kernel_thread_helper+0x6/0x10
2012-06-05T16:12:29.786+02:00 n22 kernel: ---[ end trace
00cc617101264b80 ]---
2012-06-05T16:12:29.801+02:00 n22 kernel: ------------[ cut here
]------------
2012-06-05T16:12:29.802+02:00 n22 kernel: WARNING: at mm/filemap.c:940
find_get_pages_contig+0x16a/0x1a0()
2012-06-05T16:12:29.802+02:00 n22 kernel: Hardware name: 6474B84
2012-06-05T16:12:29.802+02:00 n22 kernel: Modules linked in: loop fuse
dm_mod usblp hid_generic hid_cherry i915 usbhid hid fbcon font bitblit
softcursor drm_kms_helper drm fb fbdev intel_agp cfbcopyarea
i2c_algo_bit intel_gtt 8250_pci 8250 cfbimgblt i2c_i801 sr_mod
thinkpad_acpi hwmon video acpi_cpufreq nvram ac thermal sg evdev psmouse
serial_core i2c_core cdrom agpgart button battery mperf processor wmi
cfbfillrect [last unloaded: microcode]
2012-06-05T16:12:29.802+02:00 n22 kernel: Pid: 2359, comm: loop0
Tainted: G        W    3.5.0-rc1-00037-g99becf1-dirty #21
2012-06-05T16:12:29.802+02:00 n22 kernel: Call Trace:
2012-06-05T16:12:29.802+02:00 n22 kernel: [<c102e632>]
warn_slowpath_common+0x72/0xa0
2012-06-05T16:12:29.802+02:00 n22 kernel: [<c10c07aa>] ?
find_get_pages_contig+0x16a/0x1a0
2012-06-05T16:12:29.802+02:00 n22 kernel: [<c10c07aa>] ?
find_get_pages_contig+0x16a/0x1a0
2012-06-05T16:12:29.802+02:00 n22 kernel: [<c102e682>]
warn_slowpath_null+0x22/0x30
2012-06-05T16:12:29.802+02:00 n22 kernel: [<c10c07aa>]
find_get_pages_contig+0x16a/0x1a0
2012-06-05T16:12:29.802+02:00 n22 kernel: [<c11240fc>] ?
splice_to_pipe+0xec/0x1f0
2012-06-05T16:12:29.802+02:00 n22 kernel: [<c1124907>]
__generic_file_splice_read+0xe7/0x550
2012-06-05T16:12:29.802+02:00 n22 kernel: [<c1062508>] ?
load_balance+0x88/0x5a0
2012-06-05T16:12:29.802+02:00 n22 kernel: [<c105e6b4>] ?
update_cfs_load+0x284/0x290
2012-06-05T16:12:29.802+02:00 n22 kernel: [<f8494db4>] ?
transfer_none+0x54/0x80 [loop]
2012-06-05T16:12:29.802+02:00 n22 kernel: [<f84945ba>] ?
lo_splice_actor+0xaa/0xe0 [loop]
2012-06-05T16:12:29.802+02:00 n22 kernel: [<c1123430>] ?
page_cache_pipe_buf_release+0x20/0x20
2012-06-05T16:12:29.802+02:00 n22 kernel: [<c1124e0c>]
generic_file_splice_read+0x9c/0x100
2012-06-05T16:12:29.802+02:00 n22 kernel: [<c1124d70>] ?
__generic_file_splice_read+0x550/0x550
2012-06-05T16:12:29.803+02:00 n22 kernel: [<c11238f5>]
do_splice_to+0x65/0x80
2012-06-05T16:12:29.803+02:00 n22 kernel: [<c1123b65>]
splice_direct_to_actor+0xb5/0x1f0
2012-06-05T16:12:29.803+02:00 n22 kernel: [<f8494c40>] ?
loop_thread+0x510/0x510 [loop]
2012-06-05T16:12:29.803+02:00 n22 kernel: [<f84948b1>]
loop_thread+0x181/0x510 [loop]
2012-06-05T16:12:29.803+02:00 n22 kernel: [<f84945f0>] ?
lo_splice_actor+0xe0/0xe0 [loop]
2012-06-05T16:12:29.803+02:00 n22 kernel: [<f8494730>] ?
do_lo_send_write+0xe0/0xe0 [loop]
2012-06-05T16:12:29.803+02:00 n22 kernel: [<c104cacc>] kthread+0x7c/0x90
2012-06-05T16:12:29.803+02:00 n22 kernel: [<c104ca50>] ?
flush_kthread_worker+0xb0/0xb0
2012-06-05T16:12:29.803+02:00 n22 kernel: [<c1379cbe>]
kernel_thread_helper+0x6/0x10
2012-06-05T16:12:29.803+02:00 n22 kernel: ---[ end trace
00cc617101264b81 ]---
2012-06-05T16:12:30.038+02:00 n22 kernel: ------------[ cut here
]------------
2012-06-05T16:12:30.039+02:00 n22 kernel: WARNING: at mm/filemap.c:940
find_get_pages_contig+0x16a/0x1a0()
2012-06-05T16:12:30.039+02:00 n22 kernel: Hardware name: 6474B84
2012-06-05T16:12:30.039+02:00 n22 kernel: Modules linked in: loop fuse
dm_mod usblp hid_generic hid_cherry i915 usbhid hid fbcon font bitblit
softcursor drm_kms_helper drm fb fbdev intel_agp cfbcopyarea
i2c_algo_bit intel_gtt 8250_pci 8250 cfbimgblt i2c_i801 sr_mod
thinkpad_acpi hwmon video acpi_cpufreq nvram ac thermal sg evdev psmouse
serial_core i2c_core cdrom agpgart button battery mperf processor wmi
cfbfillrect [last unloaded: microcode]
2012-06-05T16:12:30.039+02:00 n22 kernel: Pid: 2359, comm: loop0
Tainted: G        W    3.5.0-rc1-00037-g99becf1-dirty #21
2012-06-05T16:12:30.039+02:00 n22 kernel: Call Trace:
2012-06-05T16:12:30.039+02:00 n22 kernel: [<c102e632>]
warn_slowpath_common+0x72/0xa0
2012-06-05T16:12:30.039+02:00 n22 kernel: [<c10c07aa>] ?
find_get_pages_contig+0x16a/0x1a0
2012-06-05T16:12:30.039+02:00 n22 kernel: [<c10c07aa>] ?
find_get_pages_contig+0x16a/0x1a0
2012-06-05T16:12:30.039+02:00 n22 kernel: [<c102e682>]
warn_slowpath_null+0x22/0x30
2012-06-05T16:12:30.039+02:00 n22 kernel: [<c10c07aa>]
find_get_pages_contig+0x16a/0x1a0
2012-06-05T16:12:30.039+02:00 n22 kernel: [<c11240fc>] ?
splice_to_pipe+0xec/0x1f0
2012-06-05T16:12:30.039+02:00 n22 kernel: [<c1124907>]
__generic_file_splice_read+0xe7/0x550
2012-06-05T16:12:30.039+02:00 n22 kernel: [<c106ec6f>] ? ktime_get+0x5f/0xe0
2012-06-05T16:12:30.039+02:00 n22 kernel: [<c105182e>] ?
hrtimer_interrupt+0x16e/0x2a0
2012-06-05T16:12:30.039+02:00 n22 kernel: [<c1035e5c>] ? irq_exit+0x5c/0xa0
2012-06-05T16:12:30.039+02:00 n22 kernel: [<c1379e49>] ?
smp_apic_timer_interrupt+0x59/0x88
2012-06-05T16:12:30.039+02:00 n22 kernel: [<c1062508>] ?
load_balance+0x88/0x5a0
2012-06-05T16:12:30.039+02:00 n22 kernel: [<c13792cd>] ?
apic_timer_interrupt+0x31/0x38
2012-06-05T16:12:30.040+02:00 n22 kernel: [<c120d97f>] ? memcpy+0x1f/0x40
2012-06-05T16:12:30.040+02:00 n22 kernel: [<f8494db4>] ?
transfer_none+0x54/0x80 [loop]
2012-06-05T16:12:30.040+02:00 n22 kernel: [<f84945ba>] ?
lo_splice_actor+0xaa/0xe0 [loop]
2012-06-05T16:12:30.040+02:00 n22 kernel: [<c1123430>] ?
page_cache_pipe_buf_release+0x20/0x20
2012-06-05T16:12:30.040+02:00 n22 kernel: [<c1124e0c>]
generic_file_splice_read+0x9c/0x100
2012-06-05T16:12:30.040+02:00 n22 kernel: [<c1124d70>] ?
__generic_file_splice_read+0x550/0x550
2012-06-05T16:12:30.040+02:00 n22 kernel: [<c11238f5>]
do_splice_to+0x65/0x80
2012-06-05T16:12:30.040+02:00 n22 kernel: [<c1123b65>]
splice_direct_to_actor+0xb5/0x1f0
2012-06-05T16:12:30.040+02:00 n22 kernel: [<f8494c40>] ?
loop_thread+0x510/0x510 [loop]
2012-06-05T16:12:30.040+02:00 n22 kernel: [<f84948b1>]
loop_thread+0x181/0x510 [loop]
2012-06-05T16:12:30.040+02:00 n22 kernel: [<f84945f0>] ?
lo_splice_actor+0xe0/0xe0 [loop]
2012-06-05T16:12:30.040+02:00 n22 kernel: [<f8494730>] ?
do_lo_send_write+0xe0/0xe0 [loop]
2012-06-05T16:12:30.040+02:00 n22 kernel: [<c104cacc>] kthread+0x7c/0x90
2012-06-05T16:12:30.040+02:00 n22 kernel: [<c104ca50>] ?
flush_kthread_worker+0xb0/0xb0
2012-06-05T16:12:30.040+02:00 n22 kernel: [<c1379cbe>]
kernel_thread_helper+0x6/0x10
2012-06-05T16:12:30.040+02:00 n22 kernel: ---[ end trace
00cc617101264b82 ]---


-- 
MfG/Sincerely
Toralf Förster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
