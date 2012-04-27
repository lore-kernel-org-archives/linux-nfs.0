Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:44591 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757350Ab2D0N3t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 09:29:49 -0400
Date: Fri, 27 Apr 2012 09:30:47 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Josh Boyer <jwboyer@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] NFSv4: Add modalias for "nfs4"
Message-ID: <20120427093047.121bd01b@corrin.poochiereds.net>
In-Reply-To: <20120427131031.GA13189@zod.bos.redhat.com>
References: <20120427131031.GA13189@zod.bos.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 27 Apr 2012 09:10:33 -0400
Josh Boyer <jwboyer@redhat.com> wrote:

> When NFSv4 is configured, the support goes into the nfs.ko module.
> However, nfs-utils seems to pass "nfs4" as the fileststem type for
> NFSv4 mounts.  If the nfs module is not already loaded, the kernel
> will eventually do a module request for "nfs4".  Apparently, this
> has worked until now as the distributions ship a module config file
> that manually aliases "nfs4" to "nfs".
> 
> There is really no need to do this, as the kernel can provide a
> module alias internally for nfs4.  This adds that.
> 
> Signed-off-by: Josh Boyer <jwboyer@redhat.com>
> ---
>  fs/nfs/nfs4proc.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 60d5f4c..d6929c3 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -6550,6 +6550,7 @@ const struct xattr_handler *nfs4_xattr_handlers[] = {
>  module_param(max_session_slots, ushort, 0644);
>  MODULE_PARM_DESC(max_session_slots, "Maximum number of outstanding NFSv4.1 "
>  		"requests the client will negotiate");
> +MODULE_ALIAS("nfs4");
>  
>  /*
>   * Local variables:

Looks reasonable to me.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
