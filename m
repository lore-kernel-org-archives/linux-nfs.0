Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:40619 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751535Ab2K0Obc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 27 Nov 2012 09:31:32 -0500
Date: Tue, 27 Nov 2012 09:31:31 -0500
From: "bfields@fieldses.org" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>
Subject: Re: NFSd threads amount policy in containers context
Message-ID: <20121127143131.GC27142@fieldses.org>
References: <50B3941D.9030202@parallels.com>
 <20121126220849.GA18186@fieldses.org>
 <50B4740A.6000302@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <50B4740A.6000302@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 27, 2012 at 12:04:26PM +0400, Stanislav Kinsbursky wrote:
> 27.11.2012 02:08, bfields@fieldses.org пишет:
> >On Mon, Nov 26, 2012 at 08:09:01PM +0400, Stanislav Kinsbursky wrote:
> >>Hello.
> >>I would like to discuss how to control NFSd threads amount from
> >>container environment (is this particular case it means start of NFS
> >>server in network namespace different to init_net).
> >>
> >>So, I see three possible policies (let's assume, that there are two containers - one requested 3 NFSd threads and another one - 4 NFSd threads):
> >>1) start as many threads, as requested. I.e 7 threads for specified
> >>case (simplest case, but probably this is to much - 100 containers
> >>will start ~800 threads by default).
> >>2) start maximum number of requested threads. I.e. 4 threads for
> >>specified case (if NFSd server in container, requested 4 threads,
> >>will be stopped, then 3 thread will left working; will require some
> >>way to manage - rb tree of sorted list).
> >>3) There could be some other (more flexible) policy: combine second
> >>one with running of one more thread for each second and further
> >>network namespace, started NFS server. I.e.:
> >>1 net ns: 3 threads request = 3 threads started
> >>2 net ns: 4 threads request = 4 + 1 (per-net thread: 1 net ns) = 5 threads started
> >>3 net ns: 8 threads request = 8 + 2 (per-net threads: 2 net ns) = 10 threads started
> >>
> >>Bruce and community, what do you think about all this?
> >
> >I agree that options 2 or 3 seem more likely to be optimal.
> >
> >However, looking at the problems with, for example, getting race-free
> >shutdown correct: I'd *strongly* prefer that we start with 1, because I
> >think it will be simplest to get right.
> >
> >I'd rather put off figuring out how to scale to hundreds of containers
> >until after we demonstrate something simple and obviously correct.
> >
> 
> Ok. Then I think we could implement even a better and simpler solution:
> make the whole nfsd_serv per network namespace.
> This solution is easy to implement, non-racy on shutdown and will
> give us a rather easy way to apply scheduler policy to NFSd threads
> (this will be most probably required in future).
> Does it sounds good to you?

Yes, that sounds good, thanks!

--b.
