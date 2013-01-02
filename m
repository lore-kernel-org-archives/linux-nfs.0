Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:45946 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752995Ab3ABSVu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jan 2013 13:21:50 -0500
Date: Wed, 2 Jan 2013 13:21:47 -0500
To: Erik Slagter <erik@slagter.name>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS client large rsize/wsize (tcp?) problems
Message-ID: <20130102182147.GA25450@fieldses.org>
References: <50E0393E.7040204@slagter.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50E0393E.7040204@slagter.name>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Dec 30, 2012 at 01:53:18PM +0100, Erik Slagter wrote:
> Hello All,
> 
> I am almost complete NOOB on this matter, so please be gentle ;-)

Hah!  Hah!  Hah!

> I
> do believe there is some sort of problem inside the NFS code though.
> 
> Background: I have:
>  - linux server x86_64, vanilla kernel 3.6.7 sharing a few exports
>  - several set-top-boxes running linux, arch is mipsel32, they're
> almost vanilla, but they have prioprietary closed source drivers for
> the DVB frontends:
>    * MaxDigital XP1000, kernel 3.5.1
>    * DMM DM8000, kernel 3.2.0
>    * VU+ Ultimo, kernel 3.1.1
> 
> These all suffer from the same problem. When they have a share
> mounted with default parameters, using tcp, they crash sooner or
> later, notably after heavy share access. The dm8000 has it's gui
> killed by the OOM-killer whilst the xp1000 and the ultimo simply
> lock up.
> 
> The OOM-killer reports it needs blocks of 128k (probably for NFS,
> but it doesn't say it), but can't find them.

Details?  (Could you show us the log messages?)  Anything else
interesting in the logs before then?  (E.g. any "order-n allocation
failed" messages?)

> For the other stb'es
> it's not clear as they lock up.
> 
> I've "discovered" a few interesting things:
>  - adding swap to the dm8000 makes the problem almost go away,
> although without NFS it definitely doesn't need swap, ever.
>  - when I ran my laptop (x86_64!) with a slightly older kernel
> (2.6.35 iirc) from a rescue cd, at a certain point I also got nasty
> dmesg reports and the "dd" proces got stuck in D state, this was
> reproducable over reboots.

Why do you believe that's the same problem?

>  - all clients work flawlessly (over extended perdiods of time) if
> mounted using udp and smaller rsize/wsize values (max 32k). Tcp
> seems to work as well, as long as the size values are kept under
> 32k.
>  - the x86_64 laptop also worked fine when mounted this way
>  - so apparently it's not a stb/mipsel32/proprietary driver issue.
>  - stb's running older kernels (notably 2.6.18) don't suffer from
> this problem

OK, thanks for the reports, let us know i you're able to narrow it down
farther.  It's not familiar off the top of my head.

--b.

> 
> Can please anyone enlighten me? I can't find similar reports other
> than from fellow stb users.
> 
> Thanks!
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
