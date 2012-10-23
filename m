Return-Path: linux-nfs-owner@vger.kernel.org
Received: from icebox.esperi.org.uk ([81.187.191.129]:49637 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745Ab2JWOZF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 23 Oct 2012 10:25:05 -0400
From: Nix <nix@esperi.org.uk>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-kernel@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>,
        Peng Tao <bergwolf@gmail.com>, Trond.Myklebust@netapp.com,
        gregkh@linuxfoundation.org, linux-nfs@vger.kernel.org
Subject: Re: Heads-up: 3.6.2 / 3.6.3 NFS server panic: 3.6.2+ regression?
References: <87objupjlr.fsf@spindle.srvr.nix>
	<20121023013343.GB6370@fieldses.org>
Date: Tue, 23 Oct 2012 15:07:59 +0100
In-Reply-To: <20121023013343.GB6370@fieldses.org> (J. Bruce Fields's message
	of "Mon, 22 Oct 2012 21:33:43 -0400")
Message-ID: <87mwzdnuww.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 23 Oct 2012, J. Bruce Fields uttered the following:

> On Mon, Oct 22, 2012 at 05:17:04PM +0100, Nix wrote:
>> I just had a panic/oops on upgrading from 3.6.1 to 3.6.3, after weeks of
>> smooth operation on 3.6.1: one of the NFS changes that went into one of
>> the two latest stable kernels appears to be lethal after around half an
>> hour of uptime. The oops came from NFSv4, IIRC (relying on memory since
>> my camera was recharging and there is no netconsole from that box
>> because it is where the netconsole logs go, so I'll have to reproduce it
>> later today). The machine is an NFSv3 server only at present, with no
>> NFSv4 running (though NFSv4 is built in).
>
> Note recent clients may try to negotiate NFSv4 by default, so it's
> possible to use it without knowing.

Every NFS import from all this server's clients has 'vers=3' forced on
(for now, until I get around to figuring out what if anything needs to
be done to move to NFSv4: it may be the answer is 'nothing' but I tread
quite carefully with this server, since my $HOME is there).

/proc/fs/nfsfs/volumes on the clients confirms that everything is v3.

> You didn't change anything else about your server or clients recently?

Nope (other than upgrading the clients to 3.6.3 in concert). Running
3.6.1 here on that server now and 3.6.3 on all the clients, and no crash
in over a day.

nfs-utils is a bit old, 1.2.6-rc6, I should probably upgrade it...

> I don't see an obvious candidate on a quick skim of v3.6.1..v3.6.3
> commits, but of course I could be missing something.

I'll try rebooting into it again soon, and get an oops report if it
should happen again (and hopefully less filesystem corruption this time,
right after a reboot into a new kernel was clearly the wrong time to
move a bunch of directories around).

Sorry for the continuing lack of useful information... I'll try to fix
that shortly (once with a report of a false alarm, since I really want
this stable kernel: my server is affected by the tx stalls fixed by
3468e9d and I'm getting tired of the frequent 1s lags talking to it: I
could just apply that one fix, but I'd rather track this down properly).
