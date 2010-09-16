Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from icebox.esperi.org.uk ([81.187.191.129]:38875 "EHLO
	mail.esperi.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753907Ab0IPUZE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Sep 2010 16:25:04 -0400
To: Thomas Gleixner <tglx@linutronix.de>
Cc: LKML <linux-kernel@vger.kernel.org>, Neil Brown <nfbrown@novell.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC] x86: hpet: Avoid the readback penalty
References: <tip-54ff7e595d763d894104d421b103a89f7becf47c@git.kernel.org>
	<alpine.LFD.2.00.1009151500060.2416@localhost6.localdomain6>
From: Nix <nix@esperi.org.uk>
Date: Thu, 16 Sep 2010 21:04:50 +0100
In-Reply-To: <alpine.LFD.2.00.1009151500060.2416@localhost6.localdomain6> (Thomas Gleixner's message of "Wed, 15 Sep 2010 15:11:57 +0200 (CEST)")
Message-ID: <87d3sdfo9p.fsf@spindle.srvr.nix>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 15 Sep 2010, Thomas Gleixner said:

> On Tue, 14 Sep 2010, tip-bot for Thomas Gleixner wrote:
>> x86: hpet: Work around hardware stupidity
>
> After my brain recovered from yesterdays exposure with the x86 timer
> horror, I came up with a different solution for this problem, which
> avoids the readback of the compare register completely. It works
> nicely on my affected ATI system, but needs some exposure to the other
> machines.
>
> Comments ?

Works for me. (I still have boot problems, but these seem to be
NFS-related: -ESTALE from an apparently random subset of my mount points
at initial mount time. Restarting rpc.mountd on the server fixes
it. This is with nfs-utils 1.2.2, but I see it right up to 60abb98, that
being the most recent version I tested. This doesn't happen if the
client is running 2.6.34.x, as far as I can tell. It also doesn't happen
with all my 2.6.35.x clients. Sigh. I hate bugs like this.)
