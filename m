Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:44759 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754308Ab2HTO47 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Aug 2012 10:56:59 -0400
Date: Mon, 20 Aug 2012 10:56:56 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "devel@openvz.org" <devel@openvz.org>, "neilb@suse.de" <neilb@suse.de>
Subject: Re: [PATCH v3] SUNRPC: protect service sockets lists during
 per-net shutdown
Message-ID: <20120820145656.GB1411@fieldses.org>
References: <20120703125851.3850.86782.stgit@localhost.localdomain>
 <20120724194036.GK8570@fieldses.org>
 <20120816192902.GB4385@fieldses.org>
 <50321A0D.1020904@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <50321A0D.1020904@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 20, 2012 at 03:05:49PM +0400, Stanislav Kinsbursky wrote:
> 16.08.2012 23:29, J. Bruce Fields пишет:
> >Looking back at this:
> >
> >	- adding the sv_lock looks like the right thing to do anyway
> >	  independent of containers, because svc_age_temp_xprts may
> >	  still be running.
> >
> >	- I'm increasingly unhappy about sharing rpc servers between
> >	  network namespaces.  Everything would be easier to understand
> >	  if they were independent.  Can we figure out how to do that?
> >
> 
> Could you, please, elaborate on your your unhappiness?

It seems like you're having to do a lot of work on each individual rpc
server (callback server, lockd, etc.) to make per-net startup/shutdown
work.  And then we still don't have it quite right (see the shutdown
races).)

In general whenever we have the opportunity to have entirely separate
data structures, I'd expect that to simplify things: it should eliminate
some locking and reference-counting issues.

> I.e. I don't like it too. But the problem here, is that rpc server
> is tied with kernel threads creation and destruction. And these
> threads can be only a part of initial pid namespace (because we have
> only one kthreadd). And we decided do not create new kernel thread
> per container when were discussing the problem last time.

There really should be some way to create a kernel thread in a specific
namespace, shouldn't there?

Until we have that, could the threads be taught to fix their namespace
on startup?  

--b.
