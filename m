From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 03/10] nfs-utils: convert rpc.nfsd to use xlog()
Date: Wed, 3 Jun 2009 16:31:37 -0400
Message-ID: <20090603163137.15cd7b9a@tlielax.poochiereds.net>
References: <1244058763-10352-1-git-send-email-jlayton@redhat.com>
	<1244058763-10352-4-git-send-email-jlayton@redhat.com>
	<99D20D44-A4FC-43A5-B85A-F67B8EB166F4@oracle.com>
	<20090603162214.2aeed744@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48953 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753238AbZFCUbm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 3 Jun 2009 16:31:42 -0400
In-Reply-To: <20090603162214.2aeed744-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 3 Jun 2009 16:22:14 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> On Wed, 3 Jun 2009 16:01:24 -0400
> Chuck Lever <chuck.lever@oracle.com> wrote:
> 
> > > -	openlog("nfsd", LOG_PID, LOG_DAEMON);
> > > -	if ((error = nfssvc(port, count, versbits, minorvers4, protobits,  
> > > haddr)) < 0) {
> > > -		int e = errno;
> > > -		syslog(LOG_ERR, "nfssvc: %s", strerror(e));
> > > -		closelog();
> > > -	}
> > > +	if ((error = nfssvc(port, count, versbits, minorvers4, protobits,  
> > > haddr)) < 0)
> > > +		xlog(L_ERROR, "nfssvc (%m)");
> > 
> > Nit: Maybe get rid of the "nfssvc" here as well?
> > 
> 
> Well, the "nfssvc" here tells us that the nfssvc() call returned an
> error. Later patches will clean that up when I break up the nfssvc()
> interface. That said though, there's a bug there. %m isn't appropriate
> since errno isn't being set. Whoops!
> 

Ahh nm. In most cases, errno will be set on error. The exception is if
the code ended up using the legacy nfsctl() call. In that case, I don't
think it gets set. Hopefully that's rare enough not to matter much.


-- 
Jeff Layton <jlayton@redhat.com>
