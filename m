Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:39811 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756227Ab2JWBds (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 22 Oct 2012 21:33:48 -0400
Date: Mon, 22 Oct 2012 21:33:43 -0400
To: Nix <nix@esperi.org.uk>
Cc: linux-kernel@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>,
        Peng Tao <bergwolf@gmail.com>, Trond.Myklebust@netapp.com,
        gregkh@linuxfoundation.org, linux-nfs@vger.kernel.org
Subject: Re: Heads-up: 3.6.2 / 3.6.3 NFS server panic: 3.6.2+ regression?
Message-ID: <20121023013343.GB6370@fieldses.org>
References: <87objupjlr.fsf@spindle.srvr.nix>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87objupjlr.fsf@spindle.srvr.nix>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 22, 2012 at 05:17:04PM +0100, Nix wrote:
> I just had a panic/oops on upgrading from 3.6.1 to 3.6.3, after weeks of
> smooth operation on 3.6.1: one of the NFS changes that went into one of
> the two latest stable kernels appears to be lethal after around half an
> hour of uptime. The oops came from NFSv4, IIRC (relying on memory since
> my camera was recharging and there is no netconsole from that box
> because it is where the netconsole logs go, so I'll have to reproduce it
> later today). The machine is an NFSv3 server only at present, with no
> NFSv4 running (though NFSv4 is built in).

Note recent clients may try to negotiate NFSv4 by default, so it's
possible to use it without knowing.

You didn't change anything else about your server or clients recently?

> This is just a heads-up, not intended to be sufficient to track it down
> unless it is instantly obvious: more later, including a .config dump and
> proper oops report if it turns out to be reproducible. I just have to
> recover from the usual panic-induced fs corruption and take a backup
> first.

Thanks.

I don't see an obvious candidate on a quick skim of v3.6.1..v3.6.3
commits, but of course I could be missing something.

--b.
