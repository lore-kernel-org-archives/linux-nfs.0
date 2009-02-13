From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: Re: [NLM] 2.6.27.14 breakage when grace period expires
Date: Fri, 13 Feb 2009 12:04:55 +0100
Message-ID: <20090213110455.GA19939@janus>
References: <20090211203703.GA9662@janus> <20090211203948.GD27686@fieldses.org> <20090212142830.GA28107@janus> <1234451789.7190.38.camel@heimdal.trondhjem.org> <20090212153634.GB28107@janus> <1234462647.7190.53.camel@heimdal.trondhjem.org> <20090212182943.GA1945@janus> <1234465837.7190.62.camel@heimdal.trondhjem.org> <20090212191607.GA3108@janus> <1234470251.7190.102.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Frank van Maarseveen <frankvm@frankvm.com>,
	"Mr. Charles Edward Lever" <Chuck.Lever@oracle.com>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Linux NFS mailing list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from frankvm.xs4all.nl ([80.126.170.174]:39748 "EHLO
	janus.localdomain" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751992AbZBMLE6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Feb 2009 06:04:58 -0500
In-Reply-To: <1234470251.7190.102.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Feb 12, 2009 at 03:24:11PM -0500, Trond Myklebust wrote:
> 
> Hmm... I wonder if the problem isn't just that we're failing to cancel
> the lock request when the process is signalled. Can you try the
> following patch?
> 
> --------------------------------------------------------------------
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> NLM/lockd: Always cancel blocked locks when exiting early from nlmclnt_lock
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/lockd/clntproc.c |    9 +++++++--
>  1 files changed, 7 insertions(+), 2 deletions(-)
> 
> 
> diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
> index 31668b6..f956d1e 100644
> --- a/fs/lockd/clntproc.c
> +++ b/fs/lockd/clntproc.c
> @@ -542,9 +542,14 @@ again:
>  		status = nlmclnt_call(cred, req, NLMPROC_LOCK);
>  		if (status < 0)
>  			break;
> -		/* Did a reclaimer thread notify us of a server reboot? */
> -		if (resp->status ==  nlm_lck_denied_grace_period)
> +		/* Is the server in a grace period state?
> +		 * If so, we need to reset the resp->status, and
> +		 * retry...
> +		 */
> +		if (resp->status ==  nlm_lck_denied_grace_period) {
> +			resp->status = nlm_lck_blocked;
>  			continue;
> +		}
>  		if (resp->status != nlm_lck_blocked)
>  			break;
>  		/* Wait on an NLM blocking lock */

Patch tried but didn't make any difference. Note that there isn't any ^C
or any other signal involved. The client runs three loops in the shell

	while :; do lck -w /mnt/locktest 2; done

and every "lck" opens the file, obtains an exclusive write lock (waits
if necessary), calls sleep(2), closes the fd (releasing the lock) and
goes exit.

The "lck" which ends up unlocking during grace terminates normally but
one of the others gets a "fcntl: No locks available" when trying to
obtain the lock.


Question: shouldn't the server drop the lock after a sequence like:

201 122.033767  server:  NLM  V4 GRANTED_MSG Call (Reply In 202) FH:0xcafa61cc svid:116 pos:0-0
202 122.034066  client:  NLM  V4 GRANTED_MSG Reply (Call In 201)
205 122.034665  client:  NLM  V4 GRANTED_RES Call (Reply In 206) NLM_DENIED
206 122.034753  server:  NLM  V4 GRANTED_RES Reply (Call In 205)

?

-- 
Frank
