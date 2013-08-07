Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:36753 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932387Ab3HGVBg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Aug 2013 17:01:36 -0400
From: Nix <nix@esperi.org.uk>
To: "Myklebust\, Trond" <Trond.Myklebust@netapp.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        Toralf =?utf-8?Q?F=C3=B6rster?= <toralf.foerster@gmx.de>,
        Oleg Nesterov <oleg@redhat.com>, NFS list <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        "dhowells\@redhat.com" <dhowells@redhat.com>
Subject: Re: [3.10.4] NFS locking panic, plus persisting NFS shutdown panic from 3.9.*
References: <8761vlv4z9.fsf@spindle.srvr.nix>
	<20130805084436.69ee4415@corrin.poochiereds.net>
	<87siyotcri.fsf@spindle.srvr.nix>
	<20130805110427.509db424@tlielax.poochiereds.net>
	<20130805111106.73d6ab90@tlielax.poochiereds.net>
	<87zjswrvaq.fsf@spindle.srvr.nix>
	<1375719301.7337.14.camel@leira.trondhjem.org>
	<20130805133739.21654ecb@tlielax.poochiereds.net>
	<1375726682.7337.29.camel@leira.trondhjem.org>
	<20130805143311.4ae59067@tlielax.poochiereds.net>
	<1375755693.7337.42.camel@leira.trondhjem.org>
	<87iozhst0s.fsf@spindle.srvr.nix>
	<1375889252.6488.1.camel@leira.trondhjem.org>
Date: Wed, 07 Aug 2013 22:01:25 +0100
In-Reply-To: <1375889252.6488.1.camel@leira.trondhjem.org> (Trond Myklebust's
	message of "Wed, 7 Aug 2013 15:27:31 +0000")
Message-ID: <87iozhmd0a.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7 Aug 2013, Trond Myklebust said:

> On Wed, 2013-08-07 at 11:18 +0100, Nix wrote:
>> On 6 Aug 2013, Trond Myklebust verbalised:
>> > True. How about something like the following instead. Note the change to
>> > the original patch...
>> 
>> Well, with those applied I could reboot without a panic for the first
>> time since 3.8.x: looking good. I'll give it a reboot or two with a
>> system that's not hot from booting though.
>
> Could you please also try applying only the 1/2 patch, to see if that
> suffices to quell the shutdown panic?

It doesn't suffice. I see this severely truncated oops:

[  115.799092] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
[  115.800284] IP: [<ffffffff81165ec6>] path_init+0x11c/0x36f
[  115.801463] PGD 0 
[  115.802625] Oops: 0000 [#1] PREEMPT SMP 
[  115.803805] Modules linked in: [last unloaded: microcode] 
[  115.804995] CPU: 3 PID: 1191 Comm: sleep Not tainted 3.10.5-05317-g3c9f6fa-dirty #2
[  115.806207] Hardware name: System manufacturer System Product Name/P8H61-MX USB3, BIOS 0506 08/10/2012
[  115.807453] task: ffff8804189a0000 ti: ffff8803f74d6000 task.ti: ffff8803f74d6000

-- 
NULL && (void)
