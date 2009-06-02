From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 5/6] nfs-utils: add IPv6 support to nfsd
Date: Tue, 2 Jun 2009 14:55:37 -0400
Message-ID: <20090602145537.04fdec57@tlielax.poochiereds.net>
References: <1243943029-6400-1-git-send-email-jlayton@redhat.com>
	<1243943029-6400-6-git-send-email-jlayton@redhat.com>
	<8CA624B3-9BA6-4110-8A9B-CFF50B70A288@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:40259 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780AbZFBSzp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Jun 2009 14:55:45 -0400
In-Reply-To: <8CA624B3-9BA6-4110-8A9B-CFF50B70A288@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2 Jun 2009 11:35:18 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

Forgot a couple of comments from the earlier email:

> > 		case 'H':
> > -			if (inet_addr(optarg) != INADDR_NONE) {
> > +			/*
> > +			 * for now, this only handles one -H option. Use the
> > +			 * first one specified.
> > +			 */  
> 
> Interesting comment.  Did the old version allow you to specify more  
> than one?  Can you run rpc.nfsd more than once, specifying a different  
> "-H" on each?

The only option that matters once nfsd is up is the number of threads
-- any others are ignored. This applies to the -H option as well, so
it'll only matter for the first run of rpc.nfsd. You could specify -H
multiple times on a single nfsd run, but only the last one would
matter. With this patch, I changed it to be the first one since that
seemed more intuitive to me.

We could eventually allow nfsd to take multiple -H arguments, but
that's really outside the scope of this set.

> > +
> > +	xlog_open("nfsd");  
> 
> How about "rpc.nfsd" or even argv[0] ?

rpc.nfsd is probably easier. basename(argv[0]) is probably the best
thing though. I'll fix it up to use that.

> > +	/*
> > +	 * KLUDGE ALERT:
> > +	 * Some kernels let nfsd kernel threads inherit open files
> > +	 * from the program that spawns them (i.e. us).  So close
> > +	 * everything before spawning kernel threads.  --Chip
> > +	 */
> > 	xlog_syslog(1);
> > 	xlog_stderr(0);
> > 	fd = open("/dev/null", O_RDWR);
> > 	if (fd == -1)
> > -		perror("/dev/null");
> > +		xlog(L_ERROR, "unable to open /dev/null: %s", strerror(errno));
> 
> ("%m") does the same thing as ("%s", strerror(errno))
> 

Nice...ok I'll change it (and other spots if there are any).

> >
> > 	else {
> > 		(void) dup2(fd, 0);
> > 		(void) dup2(fd, 1);
> 
> Should you check the return code from these?
> 

The existing code doesn't. If we want to change that it should prob be
a separate patch. I wonder though whether we need to do all of this
stuff with /dev/null. Stupid question: is there some reason we can't
just close stdin/stdout/stderr?

-- 
Jeff Layton <jlayton@redhat.com>
