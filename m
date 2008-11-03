From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: assertion (!sk->sk_forward_alloc) failed at net/ipv4/af_inet.c (157)
Date: Mon, 3 Nov 2008 14:01:26 +0100
Message-ID: <20081103130126.GA17802@janus>
References: <20080814152421.GA8056@janus>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:40305 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754262AbYKCODE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Nov 2008 09:03:04 -0500
In-Reply-To: <20080814152421.GA8056@janus>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

FYI,

On Thu, Aug 14, 2008 at 05:24:21PM +0200, Frank van Maarseveen wrote:
> There are not many reports of this but it seems related to stopping the
> NFS server. I'm seeing them occasionally on system shutdown right after
> 
> 	nfsd: last server has exited 
> 	nfsd: unexporting all filesystems 
> 
> kernels: 2.6.25, 2.6.26

Add 2.6.27.3 to the list, this time with a call stack:

kernel: nfsd: last server has exited, flushing export cache
kernel: ------------[ cut here ]------------
kernel: WARNING: at net/ipv4/af_inet.c:154 inet_sock_destruct+0x154/0x1b0()
kernel: Modules linked in: [last unloaded: vmthrottle]
kernel: Pid: 3683, comm: nfsd Not tainted 2.6.27.3-x193 #1
kernel:  [<c0612335>] ? printk+0x18/0x1b
kernel:  [<c0143144>] warn_on_slowpath+0x54/0x80
kernel:  [<c0197adc>] ? slab_pad_check+0x3c/0x120
last message repeated 2 times
kernel:  [<c0197ff8>] ? check_object+0xd8/0x200
kernel:  [<c0594304>] inet_sock_destruct+0x154/0x1b0
kernel:  [<c0528498>] ? sk_common_release+0x28/0xb0
kernel:  [<c05283a6>] sk_free+0x16/0xe0
kernel:  [<c052850f>] sk_common_release+0x9f/0xb0
kernel:  [<c058aeb8>] udp_lib_close+0x8/0x10
kernel:  [<c0593d46>] inet_release+0x36/0x60
kernel:  [<c0525a1b>] sock_release+0x1b/0x80
kernel:  [<c0525aa1>] sock_close+0x21/0x40
kernel:  [<c019e5be>] __fput+0xbe/0x180
kernel:  [<c019e69f>] fput+0x1f/0x30
kernel:  [<c05e0684>] svc_sock_free+0x24/0x60
kernel:  [<c0614d75>] ? _spin_unlock_bh+0x25/0x30
kernel:  [<c05eb273>] svc_xprt_free+0x33/0x50
kernel:  [<c05eb240>] ? svc_xprt_free+0x0/0x50
kernel:  [<c02bf78d>] kref_put+0x2d/0x70
kernel:  [<c05ea5d8>] svc_close_xprt+0x48/0x60
kernel:  [<c05ea643>] svc_close_all+0x53/0x70
kernel:  [<c05dfba8>] svc_destroy+0x58/0x150
kernel:  [<c05dfd31>] ? svc_exit_thread+0x91/0xb0
kernel:  [<c05dfd40>] svc_exit_thread+0xa0/0xb0
kernel:  [<c02446ad>] nfsd+0x23d/0x2a0
kernel:  [<c0244470>] ? nfsd+0x0/0x2a0
kernel:  [<c01576bc>] kthread+0x3c/0x70
kernel:  [<c0157680>] ? kthread+0x0/0x70
kernel:  [<c011d96b>] kernel_thread_helper+0x7/0x1c
kernel:  =======================
kernel: ---[ end trace c639dded2f02505e ]---
kernel: Kernel logging (proc) stopped.

-- 
Frank
