From: Frans Pop <elendil@planet.nl>
Subject: Re: Error mounting FC8 NFS server with 2.6.31-rc3 NFSv4 client.
Date: Tue, 21 Jul 2009 22:24:30 +0200
Message-ID: <200907212224.32205.elendil@planet.nl>
References: <4A64EB1F.4000602@candelatech.com> <200907212123.08790.elendil@planet.nl> <1248206076.21343.30.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Cc: greearb@candelatech.com, linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756186AbZGUUYg@vger.kernel.org>
In-Reply-To: <1248206076.21343.30.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tuesday 21 July 2009, Trond Myklebust wrote:
> On Tue, 2009-07-21 at 21:23 +0200, Frans Pop wrote:
> > Trond Myklebust wrote:
> > > Ah... You have NFS_V4_1 enabled despite the Kconfig warning... Does
> > > the bug occur when you turn this off too?
> >
> > Eh, no. In my case both client and server are 2.6.30 which did not
> > yet have NFS_V4_1 (and in all my .31 configs I did disable it).
>
> ...and you are seeing the state manager running when you try to mount
> an NFSv4 partition using the 2.6.30 client?

Per my previous message, I think there may be two related issues:
- mount hanging when no NFS4 root is defined, reproducible on .30
- state errors occurring in that situation, which may have been
  introduced with .31

I've just checked and when I saw the state errors I was running .31-rc3 on
the client, and partially also on the server. I saw error 2, 5 and 10022.
See log below.

I first switched back to .30 on the server to see if that fixed the mount
problem (it didn't) and later also switched back to .30 on the client.

(Sorry for the kernel version confusion, but I've been working on
different issues requiring frequent reboots; but I hope the info helps.)

Cheers,
FJP

Log from the client:
Jul 19 20:10:16 aragorn kernel: Linux version 2.6.31-rc3
[...]
Jul 20 00:44:45 aragorn kernel: Error: state manager failed on NFSv4 server thorin with error 2
Jul 20 00:49:27 aragorn kernel: Error: state manager failed on NFSv4 server thorin with error 10022
Jul 20 00:52:30 aragorn kernel: Error: state manager failed on NFSv4 server thorin with error 10022
Jul 20 00:55:30 aragorn kernel: Error: state manager failed on NFSv4 server thorin with error 10022
Jul 20 00:59:39 aragorn kernel: Error: state manager failed on NFSv4 server thorin with error 10022
Jul 20 01:01:15 aragorn kernel: Error: state manager failed on NFSv4 server thorin with error 10022
[... server rebooted from 2.6.31-rc3 to 2.6.30 ...]
Jul 20 01:06:37 aragorn kernel: Error: state manager failed on NFSv4 server thorin with error 10022
Jul 20 01:09:37 aragorn kernel: Error: state manager failed on NFSv4 server thorin with error 10022
Jul 20 01:12:37 aragorn kernel: Error: state manager failed on NFSv4 server thorin with error 10022
Jul 20 01:15:37 aragorn kernel: Error: state manager failed on NFSv4 server thorin with error 10022
Jul 20 01:18:37 aragorn kernel: Error: state manager failed on NFSv4 server thorin with error 10022
Jul 20 01:23:52 aragorn kernel: Error: state manager failed on NFSv4 server thorin with error 5


Unrelated, but I just noticed the following on the server (with 2.6.30);
not sure what exactly triggered that, maybe a stop/start of the NFS services:

Jul 20 01:23:22 thorin kernel: RPC: Unregistered udp transport module.
Jul 20 01:23:22 thorin kernel: RPC: Unregistered tcp transport module.
Jul 20 01:23:22 thorin kernel: nfsd: failed to unregister auth.unix.gid cache
Jul 20 01:23:22 thorin kernel: ------------[ cut here ]------------
Jul 20 01:23:22 thorin kernel: WARNING: at /home/fjp/projects/kernel/linux-2.6/fs/proc/generic.c:847 
remove_proc_entry+0x164/0x1b0()
Jul 20 01:23:22 thorin kernel: remove_proc_entry: removing non-empty directory 'net/rpc', leaking at least 'auth.unix.gid'
Jul 20 01:23:22 thorin kernel: Modules linked in: ipv6 exportfs sunrpc(-) dm_mod loop evdev ehci_hcd usbcore mv643xx_eth libphy 
gpio_keys [last unloaded: auth_rpcgss]
Jul 20 01:23:22 thorin kernel: [<c002ab6c>] (unwind_backtrace+0x0/0xd4) from [<c003fd78>] (warn_slowpath_common+0x4c/0x68)
Jul 20 01:23:22 thorin kernel: [<c003fd78>] (warn_slowpath_common+0x4c/0x68) from [<c003fdd0>] (warn_slowpath_fmt+0x28/0x38)
Jul 20 01:23:22 thorin kernel: [<c003fdd0>] (warn_slowpath_fmt+0x28/0x38) from [<c00e43c4>] (remove_proc_entry+0x164/0x1b0)
Jul 20 01:23:22 thorin kernel: [<c00e43c4>] (remove_proc_entry+0x164/0x1b0) from [<c00628b8>] (sys_delete_module+0x1d0/0x230)
Jul 20 01:23:22 thorin kernel: [<c00628b8>] (sys_delete_module+0x1d0/0x230) from [<c0024ce0>] (ret_fast_syscall+0x0/0x2c)
Jul 20 01:23:22 thorin kernel: ---[ end trace b5320efdfa0e8be3 ]---
