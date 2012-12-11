Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:55206 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753500Ab2LKQQg (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Dec 2012 11:16:36 -0500
Date: Tue, 11 Dec 2012 11:16:33 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Steve Dickson <steved@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] gssd: base the size of the fd array on the
 RLIMIT_NOFILE limit.
Message-ID: <20121211161633.GE3336@fieldses.org>
References: <20121128010939.2475.13123.stgit@notabene.brown>
 <20121128011123.2475.13691.stgit@notabene.brown>
 <20121128131054.GB11651@fieldses.org>
 <20121129113051.046bc658@notabene.brown>
 <20121211110228.0159fc4f@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20121211110228.0159fc4f@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 11, 2012 at 11:02:28AM +1100, NeilBrown wrote:
> On Thu, 29 Nov 2012 11:30:51 +1100 NeilBrown <neilb@suse.de> wrote:
> 
> > On Wed, 28 Nov 2012 08:10:55 -0500 "J. Bruce Fields" <bfields@fieldses.org>
> > wrote:
> > 
> > > On Wed, Nov 28, 2012 at 12:11:23PM +1100, Neil Brown wrote:
> > > > We have previously raised the size of the 'pollarray' once (32 -> 256)
> > > > and I have had another request to make it bigger.
> > > > Rather than changing the hard-coded value, make it depend on
> > > > RLIMIT_NOFILE.  This is an upper limit on the size of the array
> > > > that can be passed to poll() anyway.
> > > 
> > > Sounds like a good idea.
> > > 
> > > Just out of curiosity: how does it fail?  I guess mounts just start
> > > failing at some point--how do people find the workaround?
> > 
> > Error seems to be
> > 
> > rpcsec_gss: gss_init_sec_context: (major) Miscellaneous failure - (minor) Cannot contact any KDC for requested realm
> > 
> > in rpc.gssd logs.
> > 
> > I guess people could read the source to find the work around .... not ideal
> > though.  I guess we should get gssd to generate some more helpful message.
> > 
> > The seem to be further problems that the customer is experiencing so I might
> > wait until they are completely resolved to ensure I have complete
> > understanding before I propose a further patch.
> 
> The "further problem" was that krb5 libraries use select() in a way that does
> not support file descriptors higher than 1024.  This is fixed in the latest
> krb5 so that is no longer an issue.
> 
> I've been thinking about your question, and about how best to deliver a fix
> to customers, and I really think it should all "just work".
> i.e. the array that gssd should be sized dynamically and RLIMIT_NOFILE should
> be increased as needed.

Neat-o.

> I haven't tested this, but what do people think?   I don't have a problem
> changing the rlim_cur limit like this, but I wonder if it is OK to
> dynamically set rlim_max.

What would be the concern, that we'd be depriving an admin of the
ability to set a limit?

We could instead set only the current limit and set set the max to an
admin-configurable quantity (default very large) when we start gssd.

But that sounds more complicated, and off hand I can't think of a reason
an admin would want to do that.

--b.

> 
> Thoughts?
> 
> NeilBrown
> 
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index d01ba2f..3576a6f 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -389,18 +389,36 @@ static int
>  get_poll_index(int *ind)
>  {
>  	unsigned int i;
> +	struct pollfd *new_pollarray;
> +	struct rlimit rlim;
>  
>  	*ind = -1;
>  	for (i=0; i<pollsize; i++) {
>  		if (pollarray[i].events == 0) {
>  			*ind = i;
> -			break;
> +			return 0;
>  		}
>  	}
> -	if (*ind == -1) {
> +
> +	new_pollarray = realloc(pollarray, pollsize * 2 * sizeof(*pollarray));
> +	if (!new_pollarray) {
>  		printerr(0, "ERROR: No pollarray slots open\n");
>  		return -1;
>  	}
> +	pollarray = new_pollarray;
> +	memset(pollarray + pollsize, 0, sizeof(*pollarray) * pollsize);
> +	*ind = pollsize;
> +	pollsize *= 2;
> +
> +	/* We will need lots of file descriptors too */
> +	if (getrlimit(RLIMIT_NOFILE, &rlim) == 0) {
> +		if (rlim.rlim_cur < pollsize+20) {
> +			rlim.rlim_cur = pollsize + 20;
> +			if (rlim.rlim_max < rlim.rlim_cur)
> +				rlim.rlim_max = rlim.rlim_cur;
> +			setrlimit(RLIMIT_NOFILE, &rlim);
> +		}
> +	}
>  	return 0;
>  }
>  
> @@ -473,13 +491,9 @@ fail_keep_client:
>  void
>  init_client_list(void)
>  {
> -	struct rlimit rlim;
>  	TAILQ_INIT(&clnt_list);
>  	/* Eventually plan to grow/shrink poll array: */
>  	pollsize = FD_ALLOC_BLOCK;
> -	if (getrlimit(RLIMIT_NOFILE, &rlim) < 0 &&
> -	    rlim.rlim_cur != RLIM_INFINITY)
> -		pollsize = rlim.rlim_cur;
>  	pollarray = calloc(pollsize, sizeof(struct pollfd));
>  }
>  


