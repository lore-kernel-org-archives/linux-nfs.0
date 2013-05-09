Return-Path: linux-nfs-owner@vger.kernel.org
Received: from youngberry.canonical.com ([91.189.89.112]:60065 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753181Ab3EIPNy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 May 2013 11:13:54 -0400
Date: Thu, 9 May 2013 10:13:33 -0500
From: Serge Hallyn <serge.hallyn@ubuntu.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Serge Hallyn <serge.hallyn@canonical.com>,
        linux-security-module@vger.kernel.org, linux-nfs@vger.kernel.org,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] security: cap_inode_getsecctx returning garbage
Message-ID: <20130509151333.GA2211@tp>
References: <20130509014329.GH23747@fieldses.org>
 <20130509054926.GA31134@tp>
 <20130509140820.GB9316@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130509140820.GB9316@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Quoting J. Bruce Fields (bfields@fieldses.org):
> On Thu, May 09, 2013 at 12:49:26AM -0500, Serge Hallyn wrote:
> > Quoting J. Bruce Fields (bfields@fieldses.org):
> > > From: "J. Bruce Fields" <bfields@redhat.com>
> > > 
> > > We shouldn't be returning success from this function without also
> > > filling in the return values ctx and ctxlen.
> > > 
> > > Note currently this doesn't appear to cause bugs since the only
> > > inode_getsecctx caller I can find is fs/sysfs/inode.c, which only calls
> > > this if security_inode_setsecurity succeeds.  Assuming
> > > security_inode_setsecurity is set to cap_inode_setsecurity whenever
> > > inode_getsecctx is set to cap_inode_getsecctx, this function can never
> > > actually called.
> > > 
> > > So I noticed this only because the server labeled NFS patches add a real
> > > caller.
> > > 
> > > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > 
> > Thanks, the comment in include/linux/security.h doesn't mention the
> > return value at all, but based on the other implementations this looks
> > right.
> > 
> > Acked-by: Serge E. Hallyn <serge.hallyn@ubuntu.com>
> 
> Thanks!  Hm, would something like this help clarify?:
> 
> @@ -1412,7 +1412,8 @@ static inline void security_free_mnt_opts(struct security_mnt_opts *opts)
>   * 	@ctxlen contains the length of @ctx.
>   *
>   * @inode_getsecctx:
> - *	Returns a string containing all relevant security context information
> + *	On success, fills out @ctx and @ctxlen with the security context
> + *	for the given @inode.

...  and returns 0.

That would be great, thanks!

Acked-by: Serge E. Hallyn <serge.hallyn@ubuntu.com>

>   *
>   * 	@inode we wish to get the security context of.
>   *	@ctx is a pointer in which to place the allocated security context.
> 
> --b.
