Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:42589 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756788AbaD1TZE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 28 Apr 2014 15:25:04 -0400
From: Nix <nix@esperi.org.uk>
To: NFS list <linux-nfs@vger.kernel.org>
Cc: Linux-Netdev <netdev@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: Unix-domain sockets hanging on 3.14.x (was Re: possible 3.14.1 lockd problem (?) causing nfsd hangs)
References: <87oazpp2m7.fsf@spindle.srvr.nix>
	<87ppk1sbzp.fsf@spindle.srvr.nix>
	<20140428154648.GA31788@order.stressinduktion.org>
Date: Mon, 28 Apr 2014 19:55:51 +0100
In-Reply-To: <20140428154648.GA31788@order.stressinduktion.org> (Hannes
	Frederic Sowa's message of "Mon, 28 Apr 2014 17:46:48 +0200")
Message-ID: <87ha5dp9l4.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 28 Apr 2014, Hannes Frederic Sowa uttered the following:

> On Mon, Apr 28, 2014 at 04:35:38PM +0100, Nix wrote:
>> /proc/$pid/stack of the two communicating ssh daemons was instructive:
>> 
>> [<ffffffff814e3512>] unix_wait_for_peer+0x9f/0xbc
>> [<ffffffff814e5d48>] unix_dgram_sendmsg+0x41b/0x534
>
> This one is a dgram socket...
>
>> [<ffffffff8146618f>] sock_sendmsg+0x84/0x9e
>> [<ffffffff81467f3d>] SyS_sendto+0x10e/0x13f
>> [<ffffffff815770e2>] system_call_fastpath+0x16/0x1b
>> [<ffffffffffffffff>] 0xffffffffffffffff
>> spindle:/var/log.real/by-facility# cat /proc/5941/stack
>> [<ffffffff814e493a>] unix_stream_recvmsg+0x289/0x6d5
>
> ...and that's a stream receiver.
>
>> [<ffffffff814673e0>] sock_aio_read.part.12+0xf0/0xff
>> [<ffffffff8146740b>] sock_aio_read+0x1c/0x28
>> [<ffffffff811388fd>] do_sync_read+0x59/0x78
>> [<ffffffff81138d8b>] vfs_read+0xa2/0x13f
>> [<ffffffff81139699>] SyS_read+0x47/0x8b
>> [<ffffffff81577259>] tracesys+0xd0/0xd5
>> [<ffffffffffffffff>] 0xffffffffffffffff
>
> Are you sure those are the communicating tasks?

Normally I'd say yes. This time I'd say probably not. I am very much not
at my best right now.

I'll wait for it to implode and try the same thing again. On past form I
won't have to wait very many days...

(this time, there was a six-hour interval between boot and
misbehaviour. Whatever the misbehaviour *is*.)

One more instance I didn't share because I only have one end of it:
starting up ISC dhcpd 4.2.4 also hung unexpectedly (which it did not
after rebooting):

[<ffffffff814e3512>] unix_wait_for_peer+0x9f/0xbc
[<ffffffff814e5d48>] unix_dgram_sendmsg+0x41b/0x534
[<ffffffff8146618f>] sock_sendmsg+0x84/0x9e
[<ffffffff81467f3d>] SyS_sendto+0x10e/0x13f
[<ffffffff815770e2>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff

The common factor in these hangs is definitely unix_wait_for_peer. The
question is, what are they talking to? (In theory this could be a
userspace bug... but what common userspace factor is there between the
NFS server, OpenSSH, and ISC dhcpd? If it helps, named pipes may well be
suffering from the same malaise: /sbin/shutdown from sysvinit also hangs
and I have to /sbin/reboot -f instead. I'll check next time it hits, but
I'll bet it's trying to talk over /dev/initctl and getting nowhere.)
