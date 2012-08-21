Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43012 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755277Ab2HUMZp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 21 Aug 2012 08:25:45 -0400
Date: Tue, 21 Aug 2012 08:25:44 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>, "neilb@suse.de" <neilb@suse.de>
Subject: Re: [PATCH v3] SUNRPC: protect service sockets lists during
 per-net shutdown
Message-ID: <20120821122544.GD9483@fieldses.org>
References: <20120703125851.3850.86782.stgit@localhost.localdomain>
 <20120724194036.GK8570@fieldses.org>
 <20120816192902.GB4385@fieldses.org>
 <50321A0D.1020904@parallels.com>
 <20120820145656.GB1411@fieldses.org>
 <50325384.9070506@parallels.com>
 <20120820165852.GF1411@fieldses.org>
 <503354A0.5010707@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <503354A0.5010707@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 21, 2012 at 01:28:00PM +0400, Stanislav Kinsbursky wrote:
> 20.08.2012 20:58, J. Bruce Fields пишет:
> >On Mon, Aug 20, 2012 at 07:11:00PM +0400, Stanislav Kinsbursky wrote:
> >>Currently, when you call kthread_create(), you add new job to
> >>kthreadd queue. Kthreadd is unique, starts right after init and
> >>lives in global initial environment. So, any kthread inherits
> >>namespaces from it.
> >>Of course, we can start one kthread per environment and change it's
> >>root or even network namespace in kthread function. But pid
> >>namespace of this kthread will remain global.
> >
> >OK.  But the current implementation will leave all the server threads in
> >the initial pid namespace, too.
> >
> >>It looks like not a big problem, when we shutdown kthread by some
> >>variable. But what about killable nfsd kthreads?
> >
> >And we're stuck with that problem either way too, aren't we?
> >
> 
> Yes, we are. But at least we are avoiding patching of task subsystem.
> 
> >>1) We can't kill them from nested pid namespace.
> >>2) How we will differ nfsd kthreads in initial pid namespace?
> >
> >I have to admit for my purposes I don't care too much about pid
> >namespaces or about signalling server threads.  It'd be nice to get
> >those things right but it wouldn't bother me that much not to.
> >
> >Another stupid idea: can we do our own implementation of something like
> >kthreadd just for the purpose of starting rpc server threads?  It
> >doesn't seem that complicated.
> >
> 
> Gm...
> This idea is not stupid. If I understand you right, you suggest to
> implement a service per network namespace (i.e. not only data, but
> also threads)?

Some way or another, yes, entirely separate threads for the different
namespaces would be clearer, I think.

And if we can't get them in the right pid namespaces, I'm not sure I
care.

--b.
