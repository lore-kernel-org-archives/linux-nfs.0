From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] sunrpc: fix build-time warning
Date: Thu, 31 Dec 2009 20:54:54 -0500
Message-ID: <20091231205454.0f84f091@tupile.poochiereds.net>
References: <1262226195-27733-1-git-send-email-jlayton@redhat.com>
	<20091231091815.a1ea7e51.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: Trond Myklebust <trond.myklebust@fys.uio.no>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-kernel@vger.kernel.org, linux-nfs@vger.kernel.org
To: Randy Dunlap <rdunlap@xenotime.net>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:64517 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751531Ab0AAB4M (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 Dec 2009 20:56:12 -0500
In-Reply-To: <20091231091815.a1ea7e51.rdunlap@xenotime.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 31 Dec 2009 09:18:15 -0800
Randy Dunlap <rdunlap@xenotime.net> wrote:

> On Wed, 30 Dec 2009 21:23:15 -0500 Jeff Layton wrote:
> 
> > Commit 486bad2e40e938cd68fd853b7a9fa3115a9d3a4a introduced this warning
> > at build time on some 32-bit architectures:
> > 
> > net/sunrpc/auth_gss/auth_gss.c: In function 'gss_pipe_downcall':
> > net/sunrpc/auth_gss/auth_gss.c:660: warning: format '%ld' expects type 'long int', but argument 3 has type 'ssize_t
> > 
> > ...fix it by changing the length modifier in the printk.
> > 
> > Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  net/sunrpc/auth_gss/auth_gss.c |    2 +-
> >  1 files changed, 1 insertions(+), 1 deletions(-)
> > 
> > diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> > index 66cb89c..6de4f91 100644
> > --- a/net/sunrpc/auth_gss/auth_gss.c
> > +++ b/net/sunrpc/auth_gss/auth_gss.c
> > @@ -657,7 +657,7 @@ gss_pipe_downcall(struct file *filp, const char __user *src, size_t mlen)
> >  			break;
> >  		default:
> >  			printk(KERN_CRIT "%s: bad return from "
> > -				"gss_fill_context: %ld\n", __func__, err);
> > +				"gss_fill_context: %Zd\n", __func__, err);
> >  			BUG();
> >  		}
> >  		goto err_release_msg;
> > -- 
> 
> I have that almost-same patch in my (unposted) linux-next patch queue,
> so basically, ack, except that we try to use 'z' instead of 'Z' nowadays.
> 
> My quick kernel source tree count is 173 %Z to 966 %z.
> (Please don't anyone start a project of converting %Z to %z.)
> 

If you have a patch queued up for this with the preferred qualifier,
then I'm fine with dropping this one.

Cheers,
-- 
Jeff Layton <jlayton@redhat.com>
