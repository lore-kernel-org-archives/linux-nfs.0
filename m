From: Stephan von Krawczynski <skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org>
Subject: Re: 2.6.31.4: Oops
Date: Tue, 27 Oct 2009 11:47:33 +0100
Message-ID: <20091027114733.ad438f9f.skraw@ithnet.com>
References: <20091014115306.2a87a7a4.skraw@ithnet.com>
	<20091018204950.7cc299ec.akpm@linux-foundation.org>
	<1255927823.5628.4.camel@heimdal.trondhjem.org>
	<20091019112126.f1376514.skraw@ithnet.com>
	<1256586596.15642.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-a04.ithnet.com ([217.64.83.99]:48842 "HELO ithnet.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752969AbZJ0Krd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Oct 2009 06:47:33 -0400
In-Reply-To: <1256586596.15642.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 26 Oct 2009 15:49:56 -0400
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2009-10-19 at 11:21 +0200, Stephan von Krawczynski wrote:
> > On Mon, 19 Oct 2009 13:50:23 +0900
> > Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> > 
> > > On Sun, 2009-10-18 at 20:49 -0700, Andrew Morton wrote:
> > > > (cc linux-nfs)
> > > > 
> > > > On Wed, 14 Oct 2009 11:53:06 +0200 Stephan von Krawczynski <skraw-DcQCyzbjH0jQT0dZR+AlfA@public.gmane.org> wrote:
> > > > 
> > > > > Hello all,
> > > > > 
> > > > > just received this one:
> > > > > 
> > > > > Oct 13 20:16:02 box kernel: BUG: unable to handle kernel paging request at ffffff98
> > > > > Oct 13 20:16:02 box kernel: IP: [<f827b2e4>] nfs_writepages+0x13/0xad [nfs]
> > > > > Oct 13 20:16:02 box kernel: *pde = 0042d067 *pte = 00000000
> > > > > Oct 13 20:16:02 box kernel: Oops: 0002 [#1]
> > > > > Oct 13 20:16:02 box kernel: last sysfs file: /sys/devices/pci0000:00/0000:00:1e.0/0000:03:08.0/subsystem_device
> > > > > Oct 13 20:16:02 box kernel: Modules linked in: speedstep_lib freq_table nfs lockd sunrpc e100 mii e1000
> > > > > Oct 13 20:16:02 box kernel:
> > > > > Oct 13 20:16:02 box kernel: Pid: 4638, comm: httpd2-prefork Not tainted (2.6.31.4 #1)
> > > > > Oct 13 20:16:02 box kernel: EIP: 0060:[<f827b2e4>] EFLAGS: 00010292 CPU: 0
> > > > > Oct 13 20:16:02 box kernel: EIP is at nfs_writepages+0x13/0xad [nfs]
> > > > > Oct 13 20:16:02 box kernel: EAX: f0d0f654 EBX: 0000000a ECX: 00000020 EDX: f6393ecc
> > > > > Oct 13 20:16:02 box kernel: ESI: f0d0f654 EDI: 00000000 EBP: ffffff98 ESP: f6393e38
> > > > > Oct 13 20:16:02 box kernel:  DS: 007b ES: 007b FS: 0000 GS: 0033 SS: 0068
> > > > > Oct 13 20:16:02 box kernel: Process httpd2-prefork (pid: 4638, ti=f6392000 task=f63f7850 task.ti=f6392000)
> > > > > Oct 13 20:16:03 box kernel: Stack:
> > > > > Oct 13 20:16:03 box kernel:  f6393ecc f0d0f654 00000000 c0161f93 002283a0 00000000 00000000 f6088052
> > > > > Oct 13 20:16:03 box kernel: <0> f4d0f7ec f6393e6c f715ca00 f827362e f700d900 f4d08a14 0000000a f0d0f654
> > > > > Oct 13 20:16:03 box kernel: <0> f6393ecc 00000020 f827c7ce 0000000a f6393ec4 f6393ef4 f0d0f654 f827c85e
> > > > > Oct 13 20:16:03 box kernel: Call Trace:
> > > > > Oct 13 20:16:03 box kernel:  [<c0161f93>] ? __link_path_walk+0x840/0x910
> > > > > Oct 13 20:16:03 box kernel:  [<f827362e>] ? __nfs_revalidate_inode+0x105/0x18a [nfs]
> > > > > Oct 13 20:16:03 box kernel:  [<f827c7ce>] ? __nfs_write_mapping+0xf/0x3b [nfs]
> > > > > Oct 13 20:16:03 box kernel:  [<f827c85e>] ? nfs_write_mapping+0x64/0x6c [nfs]
> > > > > Oct 13 20:16:03 box kernel:  [<c01e0341>] ? __copy_to_user_ll+0x3e/0x45
> > > > > Oct 13 20:16:03 box kernel:  [<f8273238>] ? nfs_getattr+0x34/0xaf [nfs]
> > > > > Oct 13 20:16:03 box kernel:  [<f8273204>] ? nfs_getattr+0x0/0xaf [nfs]
> > > > > Oct 13 20:16:03 box kernel:  [<c015dce1>] ? vfs_getattr+0x21/0x30
> > > > > Oct 13 20:16:03 box kernel:  [<c015dd6e>] ? vfs_fstatat+0x4d/0x61
> > > > > Oct 13 20:16:03 box kernel:  [<c015dda7>] ? vfs_lstat+0x13/0x15
> > > > > Oct 13 20:16:03 box kernel:  [<c015e2fc>] ? sys_lstat64+0xf/0x23
> > > > > Oct 13 20:16:03 box kernel:  [<c0102848>] ? sysenter_do_call+0x12/0x26
> > > > > Oct 13 20:16:03 box kernel: Code: c3 56 89 c6 53 e8 4a ff ff ff 89 c3 89 f0 e8 5b 0e ec c7 89 d8 5b 5e c3 55 57 56 53 83 ec 38 89 44 24 04 89 14 24 8b 38 8d 6f 98 <0f> ba 6f 98 04 19 c0 31 d2 85 c0 74 19 68 82 00 00 00 ba 04 00
> > > > > Oct 13 20:16:03 box kernel: EIP: [<f827b2e4>] nfs_writepages+0x13/0xad [nfs] SS:ESP 0068:f6393e38
> > > > > Oct 13 20:16:03 box kernel: CR2: 00000000ffffff98
> > > > > Oct 13 20:16:03 box kernel: ---[ end trace 8d9ba71dd690c760 ]---
> > > > > 
> > > 
> > > From the Oops, it looks as if mapping->host is a null pointer. I don't
> > > see how this can ever happen short of a memory scribble...
> > > 
> > > Stephan, have you tried turning on the slab debugging code?
> > > 
> > > Cheers
> > >   Trond
> > 
> > I have not up to now, but will do so. If I see further output I will come back.
> > You think it may be a dead RAM?
> 
> Are you by any chance running an NFSv4 client? If so, there is a known
> use-after-free bug in 2.6.31 (see
> http://bugzilla.kernel.org/show_bug.cgi?id=14249) that would need to be
> fixed before you do any more testing.
> 
> Alternatively, if you can reproduce this using NFSv3 only (i.e. reboot
> after changing _all_ your NFSv4 mounts in /etc/fstab into nfsv3 mounts)
> then it must be a different bug.
> 
> Cheers
>   Trond

Hi Trond,

this is NFSv3 only. There is no v4 involved or has ever been used in this
setup. We have seen another hang on the same box with same kernel lately, but
unfortunately there was no output generated. So I cannot tell if it was the
very same issue. 

-- 
Regards,
Stephan
