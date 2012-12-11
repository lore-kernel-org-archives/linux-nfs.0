Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52335 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752883Ab2LKO4W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Dec 2012 09:56:22 -0500
Date: Tue, 11 Dec 2012 09:56:21 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, devel@openvz.org
Subject: Re: [Devel] [PATCH 2/6] nfsd: swap fs root in NFSd kthreads
Message-ID: <20121211145621.GA3336@fieldses.org>
References: <20121206153204.30693.11408.stgit@localhost.localdomain>
 <20121206153447.30693.54128.stgit@localhost.localdomain>
 <20121210202842.GB17350@fieldses.org>
 <50C73C60.8060405@parallels.com>
 <50C73F58.1080005@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <50C73F58.1080005@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 11, 2012 at 06:12:40PM +0400, Stanislav Kinsbursky wrote:
> UID: 9899
> 
> 11.12.2012 18:00, Stanislav Kinsbursky пишет:
> >11.12.2012 00:28, J. Bruce Fields пишет:
> >>On Thu, Dec 06, 2012 at 06:34:47PM +0300, Stanislav Kinsbursky wrote:
> >>>NFSd does lookup. Lookup is done starting from current->fs->root.
> >>>NFSd is a kthread, cloned by kthreadd, and thus have global (but luckely
> >>>unshared) root.
> >>>So we have to swap root to those, which process, started NFSd, has. Because
> >>>that process can be in a container with it's own root.
> >>
> >>This doesn't sound right to me.
> >>
> >>Which lookups exactly do you see being done relative to
> >>current->fs->root ?
> >>
> >
> >Ok, you are right. I was mistaken here.
> >This is not a exactly lookup, but d_path() problem in svc_export_request().
> >I.e. without root swapping, d_path() will give not local export path (like "/export")
> >but something like this "/root/containers_root/export".
> >
> 
> We, actually, can do it less in less aggressive way.
> I.e. instead root swap and current svc_export_request() implementation:
> 
> void svc_export_request(...)
> {
> 	<snip>
>         pth = d_path(&exp->ex_path, *bpp, *blen);
> 	<snip>
> }
> 
> we can do something like this:
> 
> void svc_export_request(...)
> {
> 	struct nfsd_net *nn = ...
> 	<snip>
> 	spin_lock(&dcache_lock);
>         pth = __d_path(&exp->ex_path, &nn->root, *bpp, *blen);
> 	spin_unlock(&dcache_lock);
> 	<snip>
> }

That looks simpler, but I still don't understand why we need it.

I'm confused about how d_path works; I would have thought that
filesystem namespaces would have their own vfsmount trees and hence that
the (vfsmount, dentry) would be enough to specify the path.  Is the root
argument for the case of chroot?  Do we care about that?

Also, svc_export_request is called from mountd's read of
/proc/net/rpc/nfsd.export/channel.  If mountd's root is wrong, then
nothing's going to work anyway.

--b.
