From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 2/2] NFS: Fix the mapping of the NFSERR_SERVERFAULT
 error
Date: Mon, 08 Feb 2010 10:12:42 -0500
Message-ID: <1265641962.5235.31.camel@localhost>
References: <1265409793-18314-1-git-send-email-Trond.Myklebust@netapp.com>
	 <1265409793-18314-2-git-send-email-Trond.Myklebust@netapp.com>
	 <4B6CA5EE.8080104@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:42435 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753017Ab0BHPNc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 8 Feb 2010 10:13:32 -0500
In-Reply-To: <4B6CA5EE.8080104@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-02-05 at 18:12 -0500, Chuck Lever wrote: 
> On 02/05/2010 05:43 PM, Trond Myklebust wrote:
> > It was recently pointed out that the NFSERR_SERVERFAULT error, which is
> > designed to inform the user of a serious internal error on the server, was
> > being mapped to an error value that is internal to the kernel.
> >
> > This patch maps it to the error EREMOTEIO, which is exported to userland
> > through errno.h.
> >
> > Signed-off-by: Trond Myklebust<Trond.Myklebust@netapp.com>
> > Cc: stable@kernel.org
> > ---
> >   fs/nfs/mount_clnt.c |    2 +-
> >   fs/nfs/nfs2xdr.c    |    2 +-
> >   fs/nfs/nfs4xdr.c    |    6 +++---
> >   3 files changed, 5 insertions(+), 5 deletions(-)
> >
> > diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
> > index 0adefc4..59047f8 100644
> > --- a/fs/nfs/mount_clnt.c
> > +++ b/fs/nfs/mount_clnt.c
> > @@ -120,7 +120,7 @@ static struct {
> >   	{ .status = MNT3ERR_INVAL,		.errno = -EINVAL,	},
> >   	{ .status = MNT3ERR_NAMETOOLONG,	.errno = -ENAMETOOLONG,	},
> >   	{ .status = MNT3ERR_NOTSUPP,		.errno = -ENOTSUPP,	},
> > -	{ .status = MNT3ERR_SERVERFAULT,	.errno = -ESERVERFAULT,	},
> > +	{ .status = MNT3ERR_SERVERFAULT,	.errno = -EREMOTEIO,	},
> >   };
> >
> >   struct mountres {
> 
> The decode_status() and decode_fhs_status() functions return -EACCES if 
> they don't recognize the server's error code.  Should they return 
> -EREMOTEIO instead?

It might possibly be a bit more enlightening to the user, but that would
be a separate patch. I wouldn't see that fix as being particularly
critical: EACCES is a valid error code that can be returned to userland.

Cheers
  Trond
