From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 1/1] nfsd41: renew_client() needs to be called with the
	client_mutex held
Date: Thu, 18 Jun 2009 13:31:18 -0400
Message-ID: <20090618173118.GF9679@fieldses.org>
References: <1245289845-12118-1-git-send-email-Ricardo.Labiaga@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: bhalevy@panasas.com, pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:51244 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184AbZFRRbR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 18 Jun 2009 13:31:17 -0400
In-Reply-To: <1245289845-12118-1-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jun 17, 2009 at 06:50:45PM -0700, Ricardo Labiaga wrote:
> renew_client() manipulates the client queue for lease renewal.  Need to
> obtain the client_mutex before manipulating it.
> 
> Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
> ---
>  fs/nfsd/nfs4state.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 4cb5d1d..18258d7 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -1537,7 +1537,9 @@ replay_cache:
>  	 * Hold a session reference until done processing the compound:
>  	 * nfsd4_put_session called only if the cstate slot is set.
>  	 */
> +	nfs4_lock_state();
>  	renew_client(session->se_client);
> +	nfs4_unlock_state();
>  	nfsd4_get_session(session);
>  out:
>  	spin_unlock(&sessionid_lock);

We can't take a mutex while handling a spinlock.  (And you should have
gotten warnings about this--not sure what kernel hacking config options
you may need turned on for that.)

Possible hack: add a spinlock that for now will just cover the client
lru?

--b.
