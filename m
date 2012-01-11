Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:48318 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756974Ab2AKQX0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Jan 2012 11:23:26 -0500
Message-ID: <1326299003.17212.7.camel@lade.trondhjem.org>
Subject: Re: [PATCH 0/5] NFS: create blocklayout pipe per network namesapce
 context
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Pavel Emelianov <xemul@parallels.com>, "neilb@suse.de" <neilb@suse.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        James Bottomley <jbottomley@parallels.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "devel@openvz.org" <devel@openvz.org>
Date: Wed, 11 Jan 2012 11:23:23 -0500
In-Reply-To: <4F0C35F3.7060508@parallels.com>
References: <20111129090754.20730.64567.stgit@localhost6.localdomain6>
		 <1325285705.10984.4.camel@lade.trondhjem.org>
	 <1325797111.11084.22.camel@lade.trondhjem.org>
	 <4F0C35F3.7060508@parallels.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2012-01-10 at 16:58 +0400, Stanislav Kinsbursky wrote: 
> 06.01.2012 00:58, Trond Myklebust пишет:
> > The second problem that was highlighted was the fact that as they stand
> > today, these patchsets do not allow for bisection. When we hit the Oops,
> > I had Bryan try to bisect where the problem arose. He ended up pointing
> > at the patch "SUNRPC: handle RPC client pipefs dentries by network
> > namespace aware routine", which is indeed the cause, but which is one of
> > the _dependencies_ for all the PipeFS notifier patches that fix the
> > problem.
> >
> 
> I'm confused here. Does this means, that I have to fix patch "SUNRPC: handle RPC 
> client pipefs dentries by network namespace aware routine" to make it able to 
> bisect?

What I mean is that currently, I have various ways to Oops the kernel
when I apply "SUNRPC: handle RPC client pipefs dentries by network
namespace aware routine" before all these other followup patches are
applied.

One way to could fix this, might be to add dummy versions of
rpc_pipefs_notifier_register()/unregister() so that "NFS: idmap PipeFS
notifier introduced" and the other such patches can be applied without
compilation errors or Oopses before the "handle RPC client pipefs
dentries..." patch is applied. The latter could then enable the real
rpc_pipefs_notifier_register()/....

The point is to not have these patches add _known_ bugs to the kernel at
any point, so that someone who is trying to track down an unknown bug
via "git bisect" doesn't have to also cope with these avoidable
issues...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

