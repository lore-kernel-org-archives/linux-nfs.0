Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:33706 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752009Ab3KORtD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 15 Nov 2013 12:49:03 -0500
Date: Fri, 15 Nov 2013 12:48:58 -0500
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "chuck.lever@oracle.com" <chuck.lever@oracle.com>,
        "neilb@suse.de" <neilb@suse.de>,
        "steved@redhat.com" <steved@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 1/3] sunrpc: create a new dummy pipe for gssd to hold
 open
Message-ID: <20131115124858.1e3d2dd4@tlielax.poochiereds.net>
In-Reply-To: <1384534611.4046.8.camel@leira.trondhjem.org>
References: <1384431919-20921-1-git-send-email-jlayton@redhat.com>
	<1384431919-20921-2-git-send-email-jlayton@redhat.com>
	<1384534611.4046.8.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 15 Nov 2013 16:56:51 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Thu, 2013-11-14 at 07:25 -0500, Jeff Layton wrote:
> > rpc.gssd will naturally hold open any pipe named */clnt*/gssd that shows
> > up under rpc_pipefs. That behavior gives us a reliable mechanism to tell
> > whether it's actually running or not.
> > 
> > Create a new toplevel "gssd" directory in rpc_pipefs when it's mounted.
> > Under that directory create another directory called "clntXX", and then
> > within that a pipe called "gssd".
> > 
> > We'll never send an upcall along that pipe, and any downcall written to
> > it will just return -EINVAL.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> 
> Hi Jeff,
> 
> Don't you need something in rpc_kill_sb() in order to remove the pipe
> and the clntXX directory?
> 
> Also please see rpc_mkdir_populate() and rpc_mkdir_depopulate() for how
> you can simplify the creation/destruction of the clntXX+clntXX/gssd.
> 
> Cheers
>   Trond

The concerned me too when I was working on this patch, but I don't think
that's the case. Note that rpc_kill_sb() doesn't call rpc_depopulate() or
anything for the top level directories in files[] either, which puzzled
me until I dove in to figure out why...

Basically what happens is that we take a dentry reference to those when
they are instantiated and that keeps them pinned in memory. The last
thing that rpc_kill_sb() does is call kill_litter_super(), which calls
d_gencode() to put a reference on any dentry reachable from s->root.

After that, it calls generic_shutdown_super() which then calls
shrink_dcache_for_umount() to go through and purge all of the
dentries that are now at 0. At that point you should see "Dentry ...
still in use" messages if any still have a non-zero refcount. I've
tested mounting and unmounting rpc_pipefs with this set and I've never
seen those warnings pop.

So, I don't think we need to do any cleanup of them, but I will admit
that none of this is particularly obvious. ;)

-- 
Jeff Layton <jlayton@redhat.com>
