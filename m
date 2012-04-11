Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34527 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933457Ab2DKWRb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Apr 2012 18:17:31 -0400
Date: Wed, 11 Apr 2012 18:17:29 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: Jeff Layton <jlayton@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH][RFC] nfsd/lockd: have locks_in_grace take a sb arg
Message-ID: <20120411221729.GG31706@fieldses.org>
References: <20120410093900.20209d00@tlielax.poochiereds.net>
 <4F84493C.1040303@parallels.com>
 <20120410144505.58bca0b9@corrin.poochiereds.net>
 <4F855864.8050509@parallels.com>
 <20120411074822.0054eb36@tlielax.poochiereds.net>
 <4F85825E.4060104@parallels.com>
 <20120411171919.GA29903@fieldses.org>
 <4F85C15D.5060408@parallels.com>
 <20120411182218.GB31025@fieldses.org>
 <4F85DA84.8010703@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <4F85DA84.8010703@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 11, 2012 at 11:24:52PM +0400, Stanislav Kinsbursky wrote:
> 11.04.2012 22:22, J. Bruce Fields написал:
> >>>  What would happen, if we will have situation like below:
> >>>  >  	mountd A	mountd B
> >>>  >  	pid_ns		pid_ns
> >>>  	|		  |
> >>>  	mnt_ns		mnt_ns
> >>>  	|		  |
> >>>  	-----	net_ns ----
> >>>  >  Is it possible, BTW?
> >>>  It yes, that is such construction valid?
> >Looks like a mess, no.  I'd expect there to be only one rpc.mountd
> >running per network namespace.
> 
> Then we have to prevent such situations somehow.
> Or it is done already?

If there's a way to prevent it, great, otherwise I think we just tell
people not to do that, and make sure any distro scripts (or whatever)
don't do that.

Actually, my statement above isn't quite right: we do allow running
multiple rpc.mountd processes in one network namespace (see the
--num-threads option to rpc.mountd, which is sometimes necessary for
performance).  But they should all be in the same namespaces and be
using the same configuration.

--b.
