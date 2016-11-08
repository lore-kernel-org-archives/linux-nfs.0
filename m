Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:38284 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932125AbcKHUni (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 8 Nov 2016 15:43:38 -0500
Date: Tue, 8 Nov 2016 15:36:12 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: Julia Lawall <Julia.Lawall@lip6.fr>, kernel-janitors@vger.kernel.org,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: constify reply_cache_stats_operations structure
Message-ID: <20161108203612.GD26589@fieldses.org>
References: <1472416615-24079-1-git-send-email-Julia.Lawall@lip6.fr>
 <1472468267.2597.0.camel@poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1472468267.2597.0.camel@poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 29, 2016 at 06:57:47AM -0400, Jeff Layton wrote:
> On Sun, 2016-08-28 at 22:36 +0200, Julia Lawall wrote:
> > reply_cache_stats_operations, of type struct file_operations, is
> > never
> > modified, so declare it as const.
> > 
> > Done with the help of Coccinelle.
> > 
> > Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>
> > 
> > ---
> >  fs/nfsd/nfsctl.c |    2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> > index 65ad016..3bc9693 100644
> > --- a/fs/nfsd/nfsctl.c
> > +++ b/fs/nfsd/nfsctl.c
> > @@ -217,7 +217,7 @@ static const struct file_operations
> > pool_stats_operations = {
> >  	.release	= nfsd_pool_stats_release,
> >  };
> >  
> > -static struct file_operations reply_cache_stats_operations = {
> > +static const struct file_operations reply_cache_stats_operations = {
> >  	.open		= nfsd_reply_cache_stats_open,
> >  	.read		= seq_read,
> >  	.llseek		= seq_lseek,
> > 
> 
> I'm pretty sure Bruce will pick this up for v4.9:

Except, for some reason it's been languishing in my inbox.  Apologies,
applying....

--b.

> 
> Reviewed-by: Jeff Layton <jlayton@poochiereds.net>
