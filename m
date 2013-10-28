Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:54731 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754034Ab3J1Srg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 14:47:36 -0400
Date: Mon, 28 Oct 2013 14:47:32 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: return -EBUSY on remount when new options can't be
 applied
Message-ID: <20131028144732.6bc5f73f@tlielax.poochiereds.net>
In-Reply-To: <1382985630.3314.3.camel@leira.trondhjem.org>
References: <1382363554-6587-1-git-send-email-jlayton@redhat.com>
	<1382985630.3314.3.camel@leira.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 28 Oct 2013 18:40:32 +0000
"Myklebust, Trond" <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2013-10-21 at 09:52 -0400, Jeff Layton wrote:
> > Currently the kernel returns -EINVAL, which makes it hard to
> > distinguish this situation from the case where an invalid mount option
> > was specified.
> > 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> >  fs/nfs/super.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> > index 3f5a7a8..cebdb26 100644
> > --- a/fs/nfs/super.c
> > +++ b/fs/nfs/super.c
> > @@ -2156,7 +2156,7 @@ nfs_compare_remount_data(struct nfs_server *nfss,
> >  	    data->nfs_server.addrlen != nfss->nfs_client->cl_addrlen ||
> >  	    !rpc_cmp_addr((struct sockaddr *)&data->nfs_server.address,
> >  			  (struct sockaddr *)&nfss->nfs_client->cl_addr))
> > -		return -EINVAL;
> > +		return -EBUSY;
> >  
> >  	return 0;
> >  }
> 
> The problem is that EBUSY also has a different meaning when it comes to
> remount. According to the manpage it means the source "cannot be
> remounted read-only, because it still holds files open for writing."
> 
> So, as far as I can see, this is a case of pick your poison...
> 

Yes, there is no great return code for this, sadly. The same manpage
says this for -EINVAL, which isn't exactly correct either:

"Or,  a  remount  (MS_REMOUNT) was  attempted,  but  source  was not
already mounted on target."

-EBUSY certainly isn't perfect but it does seem a little closer to the
mark, IMO. That said, I don't feel terribly strongly about it if you
think we ought to keep it as-is.

-- 
Jeff Layton <jlayton@redhat.com>
