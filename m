Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47768 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753756Ab3KKN2W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Nov 2013 08:28:22 -0500
Date: Mon, 11 Nov 2013 08:26:41 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Vasily Kulikov <segoon@openwall.com>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org,
        Stanislav Kinsbursky <skinsbursky@parallels.com>, bfields@fieldses.org,
        bharrosh@panasas.com, devel@openvz.org, oleg@redhat.com
Subject: Re: [Devel] call_usermodehelper in containers
Message-ID: <20131111082641.048696f3@tlielax.poochiereds.net>
In-Reply-To: <20131111124321.GA18028@cachalot>
References: <20131111071825.62da01d1@tlielax.poochiereds.net>
	<20131111124321.GA18028@cachalot>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 11 Nov 2013 16:43:21 +0400
Vasily Kulikov <segoon@openwall.com> wrote:

> Hi Jeff,
> 
> On Mon, Nov 11, 2013 at 07:18 -0500, Jeff Layton wrote:
> > What's the correct approach to fix this? One possibility would be to
> > keep a kernel thread around that sits in the correct namespace(s) and
> > has the right privileges, and then use that to launch UMH programs.
> > That thread could be spawned whenever someone runs rpc.nfsd inside a
> > container.
> > 
> > Not very elegant, but it seems like something that would work.
> > 
> > Are there better approaches?
> 
> What's the reasoning behind this?  I mean, it is not very obvious what
> we should keep here.  Compare 2 cases:
> 
> 1) root process with all caps spawns new ns, then drops some of caps;
> 
> 2) root process with all caps drops some of his caps and then spawns new ns.
> 
> From the programmer's POV both cases are valid and lead to absolutely
> the same limitations inside of the new namespace.  However, from kernel
> POV they differ -- if save cap set when ns is created then in (1) we'll
> have cap'ed UMH, in (2) we'll have UMH with only several caps.  It might
> significantly influence on ability of UMH to do its job and ability of
> this limited ns to escape from the sandbox.
> 
> So, what semantic should UMH privileges have?
> 
> 
> Also, an orthogonal addition: you might want to keep only minimum
> information about capabilities or something -- keep only cap_t field in
> namespace structure without explicit kernel thread for each ns.  When UMH is
> created, just fill the required caps in it.
> 
> Thanks,
> 

I don't have a particular affinity for either approach.

I think from a safety POV, it's less error prone to spawn the UMH
programs as a descendent of the userland process that originally
started up nfsd. That way we ensure that it inherits all of the
limitations of the original task.

If we try instead to start with a process that is running with all
capabilities and then drop some of them selectively, then it seems
quite possible to miss something.

But...namespaces aren't really my "thing", and I might have the
terminology wrong or be missing some other crux of the issue.

-- 
Jeff Layton <jlayton@redhat.com>
