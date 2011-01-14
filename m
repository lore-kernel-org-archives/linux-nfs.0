Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:55601 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752339Ab1ANTdc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Jan 2011 14:33:32 -0500
Date: Fri, 14 Jan 2011 14:33:28 -0500
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: break lease on unlink, link, and rename
Message-ID: <20110114193327.GA16942@fieldses.org>
References: <1294853809-10732-1-git-send-email-bfields@redhat.com>
 <1294853809-10732-3-git-send-email-bfields@redhat.com>
 <4D3007A1.6030405@cn.fujitsu.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D3007A1.6030405@cn.fujitsu.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jan 14, 2011 at 04:21:53PM +0800, Mi Jinlong wrote:
> 
> 
> J. Bruce Fields:
> > Any change to any of the links pointing to an entry should also break
> > delegations.
> > 
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > ---
> >  fs/nfsd/vfs.c |   27 +++++++++++++++++++++++----
> >  1 files changed, 23 insertions(+), 4 deletions(-)
> > 
> > diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> > index 839ed88..f31321a 100644
> > --- a/fs/nfsd/vfs.c
> > +++ b/fs/nfsd/vfs.c
> > @@ -272,6 +272,13 @@ out:
> >  	return err;
> >  }
> >  
> > +static int nfsd_break_lease(struct inode *inode)
> > +{
> > +	if (!S_ISREG(inode->i_mode))
> > +		return 0;
> > +	return break_lease(inode, O_WRONLY | O_NONBLOCK);
> 
> Hi Bruce,
> 
> break_lease will return -EWOULDBLOCK here if break success, not 0.
>   at __break_lease:
>    
>     1193  */
>     1194 int __break_lease(struct inode *inode, unsigned int mode)
>     1195 {
>          ... ...  
>     1253         if (i_have_this_lease || (mode & O_NONBLOCK)) {
>     1254                 error = -EWOULDBLOCK;
>     1255                 goto out;
>     1256         }
>           ... ... 
>     1283 out:
>     1284         unlock_flocks();
>     1285         if (!IS_ERR(new_fl))
>     1286                 locks_free_lock(new_fl);
>     1287         return error;
>     1288 }
> 
> If we just return the error -EWOULDBLOCK (which mapped to -EAGAIN) at
> nfsd_break_lease(), the NFS request will be drop for -EAGAIN is mapped
> to nfserr_dropit at nfserrno().

See my for-2.6.38-incoming branch (especially 062304a815fe and
surrounding).  I was getting tired of needing special handling for
EAGAIN and EWOULDBLOCK, so I removed that mapping and am setting a flag
on the rqstp instead to indicate the need to drop a request.

Does that look reasonable to you?

--b.

> As that, client will hang up about 60s
> until a retry success.
> 
> Maybe we should have a check here as:
> 
> -       return break_lease(inode, O_WRONLY | O_NONBLOCK);
> +       int status = break_lease(inode, O_WRONLY | O_NONBLOCK);
> +       return -EWOULDBLOCK == status ? 0 : status;
> 
> -- 
> ----
> thanks
> Mi Jinlong
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
