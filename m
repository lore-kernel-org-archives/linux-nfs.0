Return-Path: linux-nfs-owner@vger.kernel.org
Received: from order.stressinduktion.org ([87.106.68.36]:45199 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755968AbaD1Pqu (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2014 11:46:50 -0400
Date: Mon, 28 Apr 2014 17:46:48 +0200
From: Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Nix <nix@esperi.org.uk>
Cc: NFS list <linux-nfs@vger.kernel.org>,
        Linux-Netdev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: Unix-domain sockets hanging on 3.14.x (was Re: possible 3.14.1 lockd problem (?) causing nfsd hangs)
Message-ID: <20140428154648.GA31788@order.stressinduktion.org>
References: <87oazpp2m7.fsf@spindle.srvr.nix> <87ppk1sbzp.fsf@spindle.srvr.nix>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <87ppk1sbzp.fsf@spindle.srvr.nix>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 28, 2014 at 04:35:38PM +0100, Nix wrote:
> /proc/$pid/stack of the two communicating ssh daemons was instructive:
> 
> [<ffffffff814e3512>] unix_wait_for_peer+0x9f/0xbc
> [<ffffffff814e5d48>] unix_dgram_sendmsg+0x41b/0x534

This one is a dgram socket...

> [<ffffffff8146618f>] sock_sendmsg+0x84/0x9e
> [<ffffffff81467f3d>] SyS_sendto+0x10e/0x13f
> [<ffffffff815770e2>] system_call_fastpath+0x16/0x1b
> [<ffffffffffffffff>] 0xffffffffffffffff
> spindle:/var/log.real/by-facility# cat /proc/5941/stack
> [<ffffffff814e493a>] unix_stream_recvmsg+0x289/0x6d5

...and that's a stream receiver.

> [<ffffffff814673e0>] sock_aio_read.part.12+0xf0/0xff
> [<ffffffff8146740b>] sock_aio_read+0x1c/0x28
> [<ffffffff811388fd>] do_sync_read+0x59/0x78
> [<ffffffff81138d8b>] vfs_read+0xa2/0x13f
> [<ffffffff81139699>] SyS_read+0x47/0x8b
> [<ffffffff81577259>] tracesys+0xd0/0xd5
> [<ffffffffffffffff>] 0xffffffffffffffff

Are you sure those are the communicating tasks?

Bye,

  Hannes

