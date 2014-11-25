Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay3-d.mail.gandi.net ([217.70.183.195]:47460 "EHLO
	relay3-d.mail.gandi.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751663AbaKYSxX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 25 Nov 2014 13:53:23 -0500
Date: Tue, 25 Nov 2014 10:53:10 -0800
From: josh@joshtriplett.org
To: David Miller <davem@davemloft.net>
Cc: rdunlap@infradead.org, pieter@boesman.nl, alexander.h.duyck@intel.com,
        viro@zeniv.linux.org.uk, ast@plumgrid.com, akpm@linux-foundation.org,
        beber@meleeweb.net, catalina.mocanu@gmail.com, dborkman@redhat.com,
        edumazet@google.com, ebiederm@xmission.com, fabf@skynet.be,
        fuse-devel@lists.sourceforge.net, geert@linux-m68k.org,
        hughd@google.com, iulia.manda21@gmail.com, JBeulich@suse.com,
        bfields@fieldses.org, jlayton@poochiereds.net,
        linux-api@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org,
        mcgrof@suse.com, mattst88@gmail.com, mgorman@suse.de, mst@redhat.com,
        miklos@szeredi.hu, netdev@vger.kernel.org, oleg@redhat.com,
        Paul.Durrant@citrix.com, paulmck@linux.vnet.ibm.com,
        pefoley2@pefoley.com, tgraf@suug.ch, therbert@google.com,
        trond.myklebust@primarydata.com, willemb@google.com,
        xiaoguangrong@linux.vnet.ibm.com, zhenglong.cai@cs2c.com.cn
Subject: Re: [PATCH v4 0/7] kernel tinification: optionally compile out
 splice family of syscalls (splice, vmsplice, tee and sendfile)
Message-ID: <20141125185310.GA24891@cloud>
References: <1416870079-15254-1-git-send-email-pieter@boesman.nl>
 <5474ABB6.3030400@infradead.org>
 <20141125.121305.2094097848188324942.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141125.121305.2094097848188324942.davem@davemloft.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 25, 2014 at 12:13:05PM -0500, David Miller wrote:
> From: Randy Dunlap <rdunlap@infradead.org>
> Date: Tue, 25 Nov 2014 08:17:58 -0800
> 
> > Is the splice family of syscalls the only one that tiny has identified
> > for optional building or can we expect similar treatment for other
> > syscalls?
> > 
> > Why will many embedded systems not need these syscalls?  You know
> > exactly what apps they run and you are positive that those apps do
> > not use splice?
> 
> I think starting to compile out system calls is a very slippery
> slope we should not begin the journey down.
> 
> This changes the forward facing interface to userspace.

It's not a "slippery slope"; it's been our standard practice for ages.
We started down that road long, long ago, when we first introduced
Kconfig and optional/modular features.  /dev/* are user-facing
interfaces, yet you can compile them out or make them modular.  /sys/*
and/proc/* are user-facing interfaces, yet you can compile part or all
of them out.  Filesystem names passed to mount are user-facing
interfaces, yet you can compile them out.  (Not just things like ext4;
think FUSE or overlayfs, which some applications will build upon and
require.)  Some prctls are optional, new syscalls like BPF or inotify or
process_vm_{read,write}v are optional, hardware interfaces are optional,
control groups are optional, containers and namespaces are optional,
checkpoint/restart is optional, KVM is optional, kprobes are optional,
kmsg is optional, /dev/port is optional, ACL support is optional, USB
support (as used by libusb) is optional, sound interfaces are optional,
GPU interfaces are optional, even futexes are optional.

For every single one of those, userspace programs or libraries may
depend on that functionality, and summarily exit if it doesn't exist,
perhaps with a warning that you need to enable options in your kernel,
or perhaps with a simple "Function not implemented" or "No such file or
directory".

Out of the entire list above and the many more where that came from,
what makes syscalls unique?  What's wildly different between
open("/dev/foo", ...) returning an error and sys_foo returning an error?
What makes syscalls so special out of the entire list above?  We're not
breaking the ability to run old userspace on a new kernel, which *must*
be supported, and that includes not just syscalls but all user-facing
interfaces; we don't break userspace.  But we've *never* guaranteed that
you can run old userspace on a new *allnoconfig* kernel.

All of these features will remain behind CONFIG_EXPERT, and all of them
warn that you can only use them if your userspace can cope.

I've actually been thinking of introducing a new CONFIG_ALL_SYSCALLS,
under which all the "enable support for foo syscall" can live, rather
than just piling all of them directly under CONFIG_EXPERT; that option
would then repeat in very clear terms the warning that if you disable
that option and then disable specific syscalls, you need to know exactly
what your target userspace uses.  That would group together this whole
family of options, and make it clearer what the implications are.

- Josh Triplett
