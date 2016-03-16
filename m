Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:33518 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750919AbcCPQAV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Mar 2016 12:00:21 -0400
Date: Wed, 16 Mar 2016 12:00:17 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: William Dauchy <wdauchy@gmail.com>
Cc: NeilBrown <neilb@suse.com>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc/cache: drop reference when
 sunrpc_cache_pipe_upcall() detects a race
Message-ID: <20160316160017.GF11520@fieldses.org>
References: <87y49ylq76.fsf@notabene.neil.brown.name>
 <20160314203846.GA22276@fieldses.org>
 <CAJ75kXbNjwaf-QWQPq1=ooUxAPmA5qBEH9jGv+k92NEr-4eJXQ@mail.gmail.com>
 <20160315131959.GA419@fieldses.org>
 <87vb4nh406.fsf@notabene.neil.brown.name>
 <CAJ75kXaWqMSgjp4U=M5Jz7VUXt_yJTo31MTQV0fh1R1TV9_W7Q@mail.gmail.com>
 <20160316150510.GE11520@fieldses.org>
 <CAJ75kXZkt1rqZ9e9gBC1Feywr9w7Cuqscgd+6yWU5oqOmQvU+Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJ75kXZkt1rqZ9e9gBC1Feywr9w7Cuqscgd+6yWU5oqOmQvU+Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 16, 2016 at 04:38:55PM +0100, William Dauchy wrote:
> Hi Bruce,
> 
> Thank your for your reply.
> 
> On Wed, Mar 16, 2016 at 4:05 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> > Why is that?
> 
> It's indeed not really based on actual proof but based on the experience we had.
> Faced several bugs, and it appears we had less issues by backporting a
> few commits; e.g related to races, leaks, performances regressions. We
> did not spent enough time on it to actually show this commit was
> actually fixing an issue hit.
> 
> > Do you have a list?
> 
> I am currently trying to switch from v3.14 to v4.1 (nfs client). So
> even know it is off topic, those I have in mind:
> 0d2a970 SUNRPC: Fix a backchannel race
> 6851447 SUNRPC: Fix a backchannel deadlock
> 0993920 SUNRPC: Prevent SYN+SYNACK+RST storms
> 03c78827 SUNRPC: Fix races between socket connection and destroy code
> a41cbe8 Failing to send a CLOSE if file is opened WRONLY and server
> reboots on a 4.x mount
> 39d0d3b NFS: Fix a tracepoint NULL-pointer dereference
> 5e99b53 nfs4: reset states to use open_stateid when returning
> delegation voluntarily
> e92c1e0 NFSv4: Fix a nograce recovery hang
> 6b55970 nfs: Fix a memory leak when meeting an unsupported state protect
> 
> I am probably wrong on most of them but we had better stability after
> applying them and I probably forgot some.

Note options 2 and 3 in Documentation/stable_kernel_rules.txt.  You can
send a backport to stable@vger.kernel.org yourself.  When you do so,
please cc: the relevant maintainers (looks like Trond and Anna for the
above) and linux-nfs@vger.kernel.org, so they can ACK/NACK.

> > I don't expect *proof*, necessarily, but some sort of argument would be
> > helpful.
> 
> In my environment, if I hit this race, it is not acceptable to not
> being able to unmount the filesystem.

OK.  I'd be interested in your use case if you get the chance.

--b.
