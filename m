Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53609 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932683Ab3LDRKx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 4 Dec 2013 12:10:53 -0500
Date: Wed, 4 Dec 2013 12:10:52 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Do not enter setup_callback_client when finding
 backchannel failed
Message-ID: <20131204171052.GE14646@fieldses.org>
References: <5295C982.1030904@gmail.com>
 <20131202145917.GF1960@fieldses.org>
 <529D4617.6080505@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <529D4617.6080505@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 03, 2013 at 10:46:47AM +0800, Kinglong Mee wrote:
> On 12/02/2013 10:59 PM, J. Bruce Fields wrote:
> > On Wed, Nov 27, 2013 at 06:29:22PM +0800, Kinglong Mee wrote:
> >> If finding backchannel failed, nfsd should not enter setup_callback_client.
> >>
> >> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> >> ---
> >>  fs/nfsd/nfs4callback.c | 4 ++--
> >>  1 file changed, 2 insertions(+), 2 deletions(-)
> >>
> >> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> >> index 7f05cd1..755d6d6 100644
> >> --- a/fs/nfsd/nfs4callback.c
> >> +++ b/fs/nfsd/nfs4callback.c
> >> @@ -664,7 +664,7 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
> >>  		args.authflavor = clp->cl_cred.cr_flavor;
> >>  		clp->cl_cb_ident = conn->cb_ident;
> >>  	} else {
> >> -		if (!conn->cb_xprt)
> >> +		if (!conn->cb_xprt || !ses)
> > 
> > It looks to me like ses should be set whenenver conn is.  Do you have
> > reason to believe the contrary?
> 
> No. It just a double check as conn->cb_xprt.
> I will drop it in v2 of this path.
> 
> > 
> >>  			return -EINVAL;
> >>  		clp->cl_cb_conn.cb_xprt = conn->cb_xprt;
> >>  		clp->cl_cb_session = ses;
> >> @@ -982,7 +982,7 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
> >>  	}
> >>  	spin_unlock(&clp->cl_lock);
> >>  
> >> -	err = setup_callback_client(clp, &conn, ses);
> >> +	err = c ? setup_callback_client(clp, &conn, ses) : -ENOENT;
> > 
> > But, whoops, yes, this looks like a good fix.  (Have you hit this
> > failure in practice?)  
> 
> Yes. When destroying the last session from client, nfsd4_probe_callback_sync
> will be called in function nfsd4_destroy_session.
> 
> As that, callback client will be update in function nfsd4_process_cb_update,
> so __nfsd4_find_backchannel always failed with returning NULL.

On second thoughts, why is that actually a problem?
setup_callback_client() will fail and you'll get an unnecessary printk
from nfsd4_mark_cb_down, I guess.  Is that the only problem?

--b.

> (Ps: Maybe needs
> another patch to avoid updating callback connect when destroying the last session ?)
> 
> For debugging, add message when finding backchannel failed.
> Just testing mount/umount at client, the debug message will be print every umount.
> 
> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> index 7f05cd1..1be4c61 100644
> --- a/fs/nfsd/nfs4callback.c
> +++ b/fs/nfsd/nfs4callback.c
> @@ -979,6 +979,8 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
>                 svc_xprt_get(c->cn_xprt);
>                 conn.cb_xprt = c->cn_xprt;
>                 ses = c->cn_session;
> +       } else {
> +               printk("%s: found connet failed.\n", __func__);
>         }
>         spin_unlock(&clp->cl_lock);
> 
> > But I think we should probably adopt the sort of
> > control flow that's more idiomatic in the kernel:
> > 
> > 	c = __nfsd4_find_backchannel(clp)
> > 	if (!c)
> > 		goto out_unlock;
> > 	...
> > 	spin_unlock(&clp->cl_lock);
> > 	err = setup_callback_client(clp, &conn, ses);
> > 	if (err)
> > 		goto out_err;
> > 
> 
> OK, it is really better.
> 
> thanks,
> Kinglong Mee
> 
> > etc.
> > 
> > --b.
> > 
> >>  	if (err) {
> >>  		nfsd4_mark_cb_down(clp, err);
> >>  		return;
> >> -- 
> >> 1.8.4.2
> > 
> 
