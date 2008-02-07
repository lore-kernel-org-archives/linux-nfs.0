From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: Wondering about NLM_HOST_MAX ... doesn't anyone understand this code?
Date: Thu, 7 Feb 2008 11:17:55 -0500
Message-ID: <8D04CC58-DF98-47FB-872A-792976AA7316@oracle.com>
References: <18346.31720.497379.823879@notabene.brown>
Mime-Version: 1.0 (Apple Message framework v753)
Content-Type: text/plain; charset=US-ASCII; delsp=yes; format=flowed
Cc: linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:28371 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756564AbYBGQSG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 7 Feb 2008 11:18:06 -0500
In-Reply-To: <18346.31720.497379.823879-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Neil-

I don't have a problem with removing the variant expiry behavior --  
in fact, I think it might be better if NLM host garbage collection  
was done only under memory pressure.

But see below.

On Feb 6, 2008, at 10:32 PM, Neil Brown wrote:
> Hi,
>  I've been looking at NLM_HOST_MAX in fs/lockd/host.c, as we have a
>  patch in SLES that makes it configurable, and the patch needs to
>  either go upstream or out the window...
>
>  But the code that uses NLM_HOST_MAX is weird!  Look:
>
> #define NLM_HOST_EXPIRE		((nrhosts > NLM_HOST_MAX)? 300 * HZ : 120  
> * HZ)
> #define NLM_HOST_COLLECT	((nrhosts > NLM_HOST_MAX)? 120 * HZ :  60  
> * HZ)
>
> So if the number of hosts is more than the maximum (64), we *increase*
> the expiry time and the garbage collection interval.
> You would think they should be decreased when we have exceeded the
> max, so we can get rid of more old entries more quickly.  But no, they
> are increased.
>
> And in the code where we add a host to the list of hosts:
>
> 	if (++nrhosts > NLM_HOST_MAX)
> 		next_gc = 0;
>
>
> So when we go over the limit, we garbage collect straight away, but
> almost certainly do nothing because we've just given every host an
> extra 3 minutes that it is allowed to live.
>
> We could change the '>' to '<' which would make the code make sense at
> least, but I don't think we want to.  A server could easily have more
> than 64 clients doing lock requests, and we don't want to make life
> harder for clients just because there are more of them.
>
> I think we should just get rid of NLM_HOST_MAX altogether.  Old hosts
> will still go away in a few minutes and pushing them out quickly
> shouldn't be needed.
>
> So: any comments on the above or on the patch below.  I've chosen to
> go with "discard hosts older than 5 minutes every 2 minutes" rather
> than "discard hosts older than 2 minutes every minute" even though the
> latter is what would have been in effect most of the time, as it seems
> more like what was intended.
>
> Thanks,
> NeilBrown
>
>
> Signed-off-by: Neil Brown <neilb@suse.de>
>
> ### Diffstat output
>  ./fs/lockd/host.c |    8 ++------
>  1 file changed, 2 insertions(+), 6 deletions(-)
>
> diff .prev/fs/lockd/host.c ./fs/lockd/host.c
> --- .prev/fs/lockd/host.c	2008-02-07 14:20:54.000000000 +1100
> +++ ./fs/lockd/host.c	2008-02-07 14:23:38.000000000 +1100
> @@ -19,12 +19,11 @@
>
>
>  #define NLMDBG_FACILITY		NLMDBG_HOSTCACHE
> -#define NLM_HOST_MAX		64
>  #define NLM_HOST_NRHASH		32
>  #define NLM_ADDRHASH(addr)	(ntohl(addr) & (NLM_HOST_NRHASH-1))
>  #define NLM_HOST_REBIND		(60 * HZ)
> -#define NLM_HOST_EXPIRE		((nrhosts > NLM_HOST_MAX)? 300 * HZ : 120  
> * HZ)
> -#define NLM_HOST_COLLECT	((nrhosts > NLM_HOST_MAX)? 120 * HZ :  60  
> * HZ)
> +#define NLM_HOST_EXPIRE		(300 * HZ)
> +#define NLM_HOST_COLLECT	(120 * HZ)
>
>  static struct hlist_head	nlm_hosts[NLM_HOST_NRHASH];
>  static unsigned long		next_gc;
> @@ -142,9 +141,6 @@ nlm_lookup_host(int server, const struct
>  	INIT_LIST_HEAD(&host->h_granted);
>  	INIT_LIST_HEAD(&host->h_reclaim);
>
> -	if (++nrhosts > NLM_HOST_MAX)
> -		next_gc = 0;
> -

AFAICT this is the only place where nrhosts is bumped.  So you should  
either get rid of nrhosts all together, or leave in a ++nrhosts;  
somewhere.

>  out:
>  	mutex_unlock(&nlm_host_mutex);
>  	return host;

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
