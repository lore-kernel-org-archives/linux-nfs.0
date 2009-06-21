From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [pnfs] [PATCH] nfsd41: Do not renew state on error
Date: Sun, 21 Jun 2009 17:27:02 +0300
Message-ID: <4A3E4336.7060904@panasas.com>
References: <> <1245467296-23871-1-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: bfields@fieldses.org, bhalevy-C4P08NqkoRlAfugRpC6u6w@public.gmane.org,
	linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-66.z220-152-67.customer.algx.net ([67.152.220.66]:23006
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751929AbZFUO1F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Jun 2009 10:27:05 -0400
In-Reply-To: <1245467296-23871-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Jun. 20, 2009, 6:08 +0300, Ricardo Labiaga <Ricardo.Labiaga@netapp.com> wrote:
> nfsd4_sequence() should not renew the client state if the session was not
> found or if there was a bad slot.  This will also avoid dereferencing a
> null session pointer.

Thanks.  I'll merge that onto my nfsd41-for-2.6.31 branch.
I was thinking whether the spin_unlock should be done on
the err: label and separate it from the success path.
I'll look into that along with reworking the state lock
as renewing the client (or actually marking it for renew)
will no longer need the lock.

Benny

> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> ---
>  fs/nfsd/nfs4state.c |   12 ++++++++----
>  1 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index c845365..e239c6e 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1425,12 +1425,16 @@ nfsd4_sequence(struct svc_rqst *rqstp,
>  	spin_lock(&sessionid_lock);
>  	status = nfserr_badsession;
>  	session = find_in_sessionid_hashtbl(&seq->sessionid);
> -	if (!session)
> -		goto out;
> +	if (!session) {
> +		spin_unlock(&sessionid_lock);
> +		goto err;
> +	}
>  
>  	status = nfserr_badslot;
> -	if (seq->slotid >= session->se_fchannel.maxreqs)
> -		goto out;
> +	if (seq->slotid >= session->se_fchannel.maxreqs) {
> +		spin_unlock(&sessionid_lock);
> +		goto err;
> +	}
>  
>  	slot = &session->se_slots[seq->slotid];
>  	dprintk("%s: slotid %d\n", __func__, seq->slotid);
