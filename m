Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60333 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751122AbaGPWF1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Jul 2014 18:05:27 -0400
Date: Wed, 16 Jul 2014 18:05:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfsd4: handle failure to find backchannel
Message-ID: <20140716220526.GG2397@fieldses.org>
References: <20140711211609.GA13656@fieldses.org>
 <53C13FE9.3080503@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53C13FE9.3080503@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 12, 2014 at 10:02:17PM +0800, Kinglong Mee wrote:
> On 7/12/2014 05:16, J. Bruce Fields wrote:
> > The local variable "ses" will be left NULL here in the case we fail to
> > find a connection.  Spotted by a coverity scan.
> >     
> > Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> > 
> > diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> > index 2c73cae9899d..fe22cd5c42d3 100644
> > --- a/fs/nfsd/nfs4callback.c
> > +++ b/fs/nfsd/nfs4callback.c
> > @@ -1001,14 +1001,18 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
> >  	}
> >  	spin_unlock(&clp->cl_lock);
> >  
> > +	if (!c)
> > +		goto out_no_connection;
> 
> Setting err to -EINVAL maybe better.
> Otherwise, nfsd4_mark_cb_down will be called with err == 0.
> 
> >  	err = setup_callback_client(clp, &conn, ses);
> 
> setup_callback_client also return -EINVAL when ses == NULL with conn.cb_xprt == NULL.

Thanks, yes, after looking over this carefully I don't believe we can
call setup_callback_client with ses NULL but conn->cb_xprt non-NULL, so
this is just a false positive from coverity.

Thanks for the review!

--b.

> 
> thanks,
> Kinglong Mee
> 
> > -	if (err) {
> > -		nfsd4_mark_cb_down(clp, err);
> > -		return;
> > -	}
> > +	if (err)
> > +		goto out_no_connection;
> >  	/* Yay, the callback channel's back! Restart any callbacks: */
> >  	list_for_each_entry(cb, &clp->cl_callbacks, cb_per_client)
> >  		run_nfsd4_cb(cb);
> > +	return;
> > +out_no_connection:
> > +	nfsd4_mark_cb_down(clp, err);
> > +	return;
> >  }
> >  
> >  static void nfsd4_do_callback_rpc(struct work_struct *w)
> > --
> > To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > 
