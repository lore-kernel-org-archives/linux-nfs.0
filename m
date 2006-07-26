From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH 005 of 9] knfsd: Be more selective in which sockets lockd listens on.
Date: Wed, 26 Jul 2006 15:17:14 -0400
Message-ID: <20060726191714.GE31172@fieldses.org>
References: <20060725114207.21779.patches@notabene> <1060725015447.21957@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@osdl.org>, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751113AbWGZTRX@vger.kernel.org>
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060725015447.21957@suse.de>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

On Tue, Jul 25, 2006 at 11:54:47AM +1000, NeilBrown wrote:
> @@ -112,6 +114,7 @@ lockd(struct svc_rqst *rqstp)
>  	 * Let our maker know we're running.
>  	 */
>  	nlmsvc_pid = current->pid;
> +	nlmsvc_serv = serv;

Nitpick: any reason not to just get rid of the local variable "serv"
after that?

> @@ -224,8 +259,10 @@ lockd_up(void)
>  	/*
>  	 * Check whether we're already up and running.
>  	 */
> -	if (nlmsvc_pid)
> +	if (nlmsvc_pid) {
> +		error = make_socks(nlmsvc_serv, proto);
>  		goto out;

...

> +	if ((error = make_socks(serv, proto)) < 0) {
>  		if (warned++ == 0) 
>  			printk(KERN_WARNING
>  				"lockd_up: makesock failed, error=%d\n", error);

The warning is printk'ed a little inconsistently.  (If we care, maybe it
should just go inside make_socks?)

By the way, why don't most callers use the error returned from
lockd_up()?

> diff .prev/fs/nfsd/nfssvc.c ./fs/nfsd/nfssvc.c
> --- .prev/fs/nfsd/nfssvc.c	2006-07-24 15:14:31.000000000 +1000
> +++ ./fs/nfsd/nfssvc.c	2006-07-24 15:15:04.000000000 +1000
> @@ -134,6 +134,9 @@ static int killsig = 0; /* signal that w
>  static void nfsd_last_thread(struct svc_serv *serv)
>  {
>  	/* When last nfsd thread exits we need to do some clean-up */
> +	struct svc_sock *svsk;
> +	list_for_each_entry(svsk, &serv->sv_permsocks, sk_list)
> +		lockd_down();

So I guess it's a minor point, but: we take the trouble to only open tcp
or udp sockets as necessary, but then won't close them down till all the
mounts and nfsd's go away at which point we close them all down.

Would it be that bad just to always listen on both?

--b.
