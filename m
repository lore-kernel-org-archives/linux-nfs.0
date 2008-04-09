From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] NLM: don't let lockd exit on unexpected svc_recv
	errors (try #2)
Date: Wed, 9 Apr 2008 13:53:38 -0400
Message-ID: <20080409175338.GI32475@fieldses.org>
References: <1207683608-17550-1-git-send-email-jlayton@redhat.com>
	<1207683608-17550-2-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1207683608-17550-2-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 08, 2008 at 03:40:08PM -0400, Jeff Layton wrote:
> When svc_recv returns an unexpected error, lockd will print a warning
> and exit. This problematic for several reasons. In particular, it will
> cause the reference counts for the thread to be wrong, and can lead to a
> potential BUG() call.
> 
> Rather than exiting on error from svc_recv, have the thread do a 1s
> sleep and then retry the loop. This is unlikely to cause any harm, and
> if the error turns out to be something temporary then it may be able to
> recover.

Both applied; thanks!--b.

> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  fs/lockd/svc.c |   18 ++++++++++++------
>  1 files changed, 12 insertions(+), 6 deletions(-)
> 
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index 66b5c98..cf977bb 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -112,7 +112,7 @@ static inline void clear_grace_period(void)
>  static int
>  lockd(void *vrqstp)
>  {
> -	int		err = 0;
> +	int		err = 0, preverr = 0;
>  	struct svc_rqst *rqstp = vrqstp;
>  	unsigned long grace_period_expire;
>  
> @@ -172,14 +172,20 @@ lockd(void *vrqstp)
>  		 * recvfrom routine.
>  		 */
>  		err = svc_recv(rqstp, timeout);
> -		if (err == -EAGAIN || err == -EINTR)
> +		if (err == -EAGAIN || err == -EINTR) {
> +			preverr = err;
>  			continue;
> +		}
>  		if (err < 0) {
> -			printk(KERN_WARNING
> -			       "lockd: terminating on error %d\n",
> -			       -err);
> -			break;
> +			if (err != preverr) {
> +				printk(KERN_WARNING "%s: unexpected error "
> +					"from svc_recv (%d)\n", __func__, err);
> +				preverr = err;
> +			}
> +			schedule_timeout_interruptible(HZ);
> +			continue;
>  		}
> +		preverr = err;
>  
>  		dprintk("lockd: request from %s\n",
>  				svc_print_addr(rqstp, buf, sizeof(buf)));
> -- 
> 1.5.3.6
> 
