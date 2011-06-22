Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43373 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751599Ab1FVWxL convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 18:53:11 -0400
Subject: Re: Issue with Race Condition on NFS4 with KRB
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Joshua Scoggins <theoretically.x64@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Wed, 22 Jun 2011 18:53:10 -0400
In-Reply-To: <BANLkTin0HnH7rufrHJGgEuPc-ZPjkZe3iw@mail.gmail.com>
References: <BANLkTik9J3qcdPcp+DdfRq9kj+DMKnjKZw@mail.gmail.com>
	 <1308767449.14997.10.camel@lade.trondhjem.org>
	 <BANLkTimyCA0QyF1TNc0SU2GYobOt-sAsNQ@mail.gmail.com>
	 <1308769054.14997.18.camel@lade.trondhjem.org>
	 <BANLkTi=b1UJzYinAeW2VJj2AHzsAnwUpGg@mail.gmail.com>
	 <1308779507.25875.7.camel@lade.trondhjem.org>
	 <BANLkTin0HnH7rufrHJGgEuPc-ZPjkZe3iw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1308783190.25875.25.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-06-22 at 15:40 -0700, Joshua Scoggins wrote: 
> The patch isn't applying to the 2.6.39 kernel sources.

It does for me:

[trondmy@lade linux-2.6]$ git checkout v2.6.39
HEAD is now at 61c4f2c... Linux 2.6.39
[trondmy@lade linux-2.6]$ git am ~/Desktop/bugfixes/0001-SUNRPC-Fix-a-potential-race-in-between-xprt_complete.patch
Applying: SUNRPC: Fix a potential race in between xprt_complete_rqst and xprt_transmit
[trondmy@lade linux-2.6]$ 

Are you perhaps using some distro kernel instead of the regular one from
Linus' repository?

Cheers
  Trond

> -Josh
> 
> On Wed, Jun 22, 2011 at 2:51 PM, Trond Myklebust
> <Trond.Myklebust@netapp.com> wrote:
> > On Wed, 2011-06-22 at 12:18 -0700, Joshua Scoggins wrote:
> >> According to the it guys they are running solaris 10 as the server platform.
> >
> > Ok. That should not be subject to the race I was thinking of...
> >
> >> On Wed, Jun 22, 2011 at 11:57 AM, Trond Myklebust
> >> <Trond.Myklebust@netapp.com> wrote:
> >> > On Wed, 2011-06-22 at 11:37 -0700, Joshua Scoggins wrote:
> >> >> Here are our mount options from auto.master
> >> >>
> >> >> /user -fstype=nfs4,sec=krb5p,noresvport,noatime
> >> >> /group -fstype=nfs4,sec=krb5p,noresvport,noatime
> >> >>
> >> >> As for the server, we don't control it. It's actually run by the
> >> >> campus wide it department we are just lab support for CS. I can
> >> >> potentially get the server information but I need to know what you want
> >> >> specifically as they're pretty paranoid about giving out information about
> >> >> their servers.
> >> >
> >> > I would just want to know _what_ server platform you are running
> >> > against. I know of at least one server bug that might explain what you
> >> > are seeing, and I'd like to eliminate that as a possibility.
> >> >
> >> > Trond
> >> >
> >> >> Joshua Scoggins
> >> >>
> >> >> On Wed, Jun 22, 2011 at 11:30 AM, Trond Myklebust
> >> >> <Trond.Myklebust@netapp.com> wrote:
> >> >> > On Wed, 2011-06-22 at 11:21 -0700, Joshua Scoggins wrote:
> >> >> >> Hello,
> >> >> >>
> >> >> >> We are trying to update our linux images in our CS lab and have it a
> >> >> >> bit of an issue. We are
> >> >> >> using nfs to load user home folder. While testing the new image we
> >> >> >> found that the nfs4 module will
> >> >> >>  crash when using firefox 3.6.17 for an extended period of time. Some
> >> >> >> research via google yielded that
> >> >> >> it's a potential race condition specific to nfs with krb auth with
> >> >> >> newer kernels. Our old image doesn't have
> >> >> >> this issue and it seems that its due to it running a far older kernel version.
> >> >> >>
> >> >> >> We have two images and both are having this problem. One is running
> >> >> >> 2.6.39 and the other is 2.6.38.
> >> >> >> Here is what dmesg spit out from the machine running 2.6.39 on one occasion:
> >> >> >>
> >> >> >> [  678.632061] ------------[ cut here ]------------
> >> >> >> [  678.632068] WARNING: at net/sunrpc/clnt.c:1567 call_decode+0xb2/0x69c()
> >> >> >> [  678.632070] Hardware name: OptiPlex 755
> >> >> >> [  678.632072] Modules linked in: nvidia(P) scsi_wait_scan
> >> >> >> [  678.632078] Pid: 3882, comm: kworker/0:2 Tainted: P
> >> >> >> 2.6.39-gentoo-r1 #1
> >> >> >> [  678.632080] Call Trace:
> >> >> >> [  678.632086]  [<ffffffff81035b20>] warn_slowpath_common+0x80/0x98
> >> >> >> [  678.632091]  [<ffffffff8117231e>] ? nfs4_xdr_dec_readdir+0xba/0xba
> >> >> >> [  678.632094]  [<ffffffff81035b4d>] warn_slowpath_null+0x15/0x17
> >> >> >> [  678.632097]  [<ffffffff81426f48>] call_decode+0xb2/0x69c
> >> >> >> [  678.632101]  [<ffffffff8142d2b5>] __rpc_execute+0x78/0x24b
> >> >> >> [  678.632104]  [<ffffffff8142d4c9>] ? rpc_execute+0x41/0x41
> >> >> >> [  678.632107]  [<ffffffff8142d4d9>] rpc_async_schedule+0x10/0x12
> >> >> >> [  678.632111]  [<ffffffff8104a49d>] process_one_work+0x1d9/0x2e7
> >> >> >> [  678.632114]  [<ffffffff8104c402>] worker_thread+0x133/0x24f
> >> >> >> [  678.632118]  [<ffffffff8104c2cf>] ? manage_workers+0x18d/0x18d
> >> >> >> [  678.632121]  [<ffffffff8104f6a0>] kthread+0x7d/0x85
> >> >> >> [  678.632125]  [<ffffffff8145e314>] kernel_thread_helper+0x4/0x10
> >> >> >> [  678.632128]  [<ffffffff8104f623>] ? kthread_worker_fn+0x13a/0x13a
> >> >> >> [  678.632131]  [<ffffffff8145e310>] ? gs_change+0xb/0xb
> >> >> >> [  678.632133] ---[ end trace 6bfae002a63e020e ]---
> >
> > Looking at the code, there is only one way I can see for that warning to
> > occur, and that is if we put the request back on the 'xprt->recv' list
> > after it has already received a reply from the server.
> >
> > Can you reproduce the problem with the attached patch?
> >
> > Trond
> >
> > --
> > Trond Myklebust
> > Linux NFS client maintainer
> >
> > NetApp
> > Trond.Myklebust@netapp.com
> > www.netapp.com
> >
> >

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

