Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49665 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753208Ab3LFSAp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 6 Dec 2013 13:00:45 -0500
Date: Fri, 6 Dec 2013 13:00:44 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] Do not enter setup_callback_client when finding
 backchannel failed
Message-ID: <20131206180044.GB9020@fieldses.org>
References: <5295C982.1030904@gmail.com>
 <20131202145917.GF1960@fieldses.org>
 <529D4617.6080505@gmail.com>
 <20131204171052.GE14646@fieldses.org>
 <529FE070.4030306@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <529FE070.4030306@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 05, 2013 at 10:09:52AM +0800, Kinglong Mee wrote:
> On 12/05/2013 01:10 AM, J. Bruce Fields wrote:
> > On Tue, Dec 03, 2013 at 10:46:47AM +0800, Kinglong Mee wrote:
> >> On 12/02/2013 10:59 PM, J. Bruce Fields wrote:
> >>> On Wed, Nov 27, 2013 at 06:29:22PM +0800, Kinglong Mee wrote:
> >>>> If finding backchannel failed, nfsd should not enter setup_callback_client.
> >>>>
> >>>> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
> >>>> ---
> >>>>  fs/nfsd/nfs4callback.c | 4 ++--
> >>>>  1 file changed, 2 insertions(+), 2 deletions(-)
> >>>>
> >>>> diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
> >>>> index 7f05cd1..755d6d6 100644
> >>>> --- a/fs/nfsd/nfs4callback.c
> >>>> +++ b/fs/nfsd/nfs4callback.c
> >>>> @@ -664,7 +664,7 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
> >>>>  		args.authflavor = clp->cl_cred.cr_flavor;
> >>>>  		clp->cl_cb_ident = conn->cb_ident;
> >>>>  	} else {
> >>>> -		if (!conn->cb_xprt)
> >>>> +		if (!conn->cb_xprt || !ses)
> >>>
> >>> It looks to me like ses should be set whenenver conn is.  Do you have
> >>> reason to believe the contrary?
> >>
> >> No. It just a double check as conn->cb_xprt.
> >> I will drop it in v2 of this path.
> >>
> >>>
> >>>>  			return -EINVAL;
> >>>>  		clp->cl_cb_conn.cb_xprt = conn->cb_xprt;
> >>>>  		clp->cl_cb_session = ses;
> >>>> @@ -982,7 +982,7 @@ static void nfsd4_process_cb_update(struct nfsd4_callback *cb)
> >>>>  	}
> >>>>  	spin_unlock(&clp->cl_lock);
> >>>>  
> >>>> -	err = setup_callback_client(clp, &conn, ses);
> >>>> +	err = c ? setup_callback_client(clp, &conn, ses) : -ENOENT;
> >>>
> >>> But, whoops, yes, this looks like a good fix.  (Have you hit this
> >>> failure in practice?)  
> >>
> >> Yes. When destroying the last session from client, nfsd4_probe_callback_sync
> >> will be called in function nfsd4_destroy_session.
> >>
> >> As that, callback client will be update in function nfsd4_process_cb_update,
> >> so __nfsd4_find_backchannel always failed with returning NULL.
> > 
> > On second thoughts, why is that actually a problem?
> > setup_callback_client() will fail and you'll get an unnecessary printk
> > from nfsd4_mark_cb_down, I guess. 
> 
> Yes, that's right. setup_callback_client will failed with －EINVAL.
> This patch just changes the logic, function returns immediately when finding backchannel failed,
> instead of enter setup_callback_client.
> 
> >  Is that the only problem?
> 
> Yes, this path only focus the logic problem. 

Apologies, I'm still not sure I understand:

As far as I can tell, the *only* way that your patch changes behavior is
to change the error passed to nfsd4_mark_cb_path down.

Is that right, or am I missing some other problem which this fixes?

--b.
