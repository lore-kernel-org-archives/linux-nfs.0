From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 3/6] nfs-utils: skip getaddrinfo in
 create_auth_rpc_client unless we need port
Date: Wed, 1 Apr 2009 13:47:39 -0400
Message-ID: <20090401134739.01b72029@barsoom.rdu.redhat.com>
References: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
	<1238595845-2186-4-git-send-email-jlayton@redhat.com>
	<F913F7D5-DCEE-4F40-B9C8-52DC1053A61A@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, kwc@citi.umich.edu
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48346 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753309AbZDARrt (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 1 Apr 2009 13:47:49 -0400
In-Reply-To: <F913F7D5-DCEE-4F40-B9C8-52DC1053A61A@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 1 Apr 2009 13:11:04 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Apr 1, 2009, at 10:24 AM, Jeff Layton wrote:
> 
> > We already have the server's address from the upcall, so we don't  
> > really
> > need to look it up again. Move the getaddrinfo call in
> > create_auth_rpc_client to a new function. Skip it if we already have  
> > the
> > port in the sockaddr that we saved from the info in the upcall. If
> > we need to get the port, don't bother looking up the hostname, just do
> > the getaddrinfo with AI_NUMERICHOST set.
> >
> > This should reduce the amount of lookups that are needed.
> >
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > utils/gssd/gssd_proc.c |  134 ++++++++++++++++++++++++++++ 
> > +-------------------
> > 1 files changed, 81 insertions(+), 53 deletions(-)
> >
> > diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> > index f5f3a0f..4d54c40 100644
> > --- a/utils/gssd/gssd_proc.c
> > +++ b/utils/gssd/gssd_proc.c
> > @@ -538,6 +538,76 @@ out_err:
> > }
> >
> > /*
> > + * Determine the port from the servicename and set the right field  
> > in the
> > + * sockaddr. This is mostly a no-op with newer kernels that send  
> > the port
> > + * in the upcall. Returns true on success and false on failure.
> > + */
> > +static int
> > +populate_port(struct sockaddr *sa, char *servicename, int socktype,
> > +	      int protocol)
> 
> I think you can guess the socktype from the protocol setting, so maybe  
> you don't need @socktype.  Actually, for AI_NUMERICHOST I don't think  
> protocol and socktype are even relevant.
> 

It seems to me that getaddrinfo() needs to have some way to know
whether you want the tcp or udp port for the service. I'm not sure
whether it uses the ai_socktype or ai_protocol to determine this
(probably the protocol), but I figure it doesn't hurt to set both.

> > +{
> > +	struct sockaddr_in	*s4 = (struct sockaddr_in *) sa;
> > +	char			node[INET_ADDRSTRLEN];
> > +	char			service[64];
> > +	char			*at_sign;
> > +	int			errcode;
> > +	struct addrinfo		*a = NULL;
> > +	struct addrinfo		ai_hints = { .ai_family	  = sa->sa_family,
> > +					     .ai_socktype = socktype,
> > +					     .ai_protocol = protocol,
> > +					     .ai_flags    = AI_NUMERICHOST };
> > +
> > +	switch (sa->sa_family) {
> > +	case AF_INET:
> > +		if (s4->sin_port != 0) {
> > +			printerr(2, "DEBUG: port already set to %d\n",
> > +				 ntohs(s4->sin_port));
> > +			return 1;
> > +		}
> > +		if (!inet_ntop(AF_INET, &s4->sin_addr, node,
> > +				sizeof(struct sockaddr_in)))
> > +			return 0;
> > +		break;
> > +	default:
> > +		printerr(0, "ERROR: unsupported address family %d\n",
> > +			    sa->sa_family);
> > +		return 0;
> > +	}
> > +
> > +	/* extract the service name from clp->servicename */
> > +	if ((at_sign = strchr(servicename, '@')) == NULL) {
> > +		printerr(0, "WARNING: servicename (%s) not formatted as "
> > +			"expected with service@host\n", servicename);
> > +		return 0;
> > +	}
> > +	if ((at_sign - servicename) >= sizeof(service)) {
> > +		printerr(0, "WARNING: service portion of servicename (%s) "
> > +			"is too long!\n", servicename);
> > +		return 0;
> > +	}
> > +	strncpy(service, servicename, at_sign - servicename);
> > +	service[at_sign - servicename] = '\0';
> > +
> > +	errcode = getaddrinfo(node, service, &ai_hints, &a);
> > +	if (errcode) {
> > +		printerr(0, "WARNING: Error from getaddrinfo for service "
> > +			 "'%s': %s\n", service,
> > +			 errcode == EAI_SYSTEM ? strerror(errno) :
> > +						 gai_strerror(errcode));
> > +		return 0;
> > +	}
> 
> Not sure what's going on with "node" here.  You should be able to pass  
> NULL for the nodename, and just get an ANYADDR sockaddr back with the  
> port set.
> 

Looks like that's correct. I'll plan to fix it to do that in the next
release.

I'll also have a look at nfs_get_rpcclient(). I think I looked at it
before and decided it wasn't suitable for this, but I don't recall the
reason. Maybe I can change it so that it is.

-- 
Jeff Layton <jlayton@redhat.com>
