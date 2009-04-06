From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/5] nfs-utils: store the address given in the upcall
 for later use
Date: Mon, 6 Apr 2009 12:31:43 -0400
Message-ID: <20090406123143.1d0671e6@tleilax.poochiereds.net>
References: <1238938983-7347-1-git-send-email-jlayton@redhat.com>
	<1238938983-7347-3-git-send-email-jlayton@redhat.com>
	<A1DB402A-E0EA-49BC-99F0-D086FF04B063@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org, kwc@citi.umich.edu
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:51535 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752439AbZDFQbv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 6 Apr 2009 12:31:51 -0400
In-Reply-To: <A1DB402A-E0EA-49BC-99F0-D086FF04B063@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 6 Apr 2009 11:35:50 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> On Apr 5, 2009, at 9:43 AM, Jeff Layton wrote:
> > The current upcall could be more efficient. We first convert the  
> > address
> > to a hostname, and then later when we set up the RPC client, we do a
> > hostname lookup to convert it back to an address.
> >
> > Begin to change this by keeping the address in the clnt_info that we  
> > get
> > out of the upcall. Since a sockaddr has a port field, we can also
> > eliminate the port from the clnt_info.
> >
> > Finally, switch to getnameinfo() instead of gethostbyaddr(). We'll  
> > need
> > to use that call anyway when we add support for IPv6.
> 
> gethostbyaddr(3) supports AF_INET6, too, by the way.
> 
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > utils/gssd/gssd.h      |    2 +-
> > utils/gssd/gssd_proc.c |   92 ++++++++++++++++++++++++++++++++++++++ 
> > +--------
> > 2 files changed, 77 insertions(+), 17 deletions(-)
> >
> > diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
> > index 082039a..3c52f46 100644
> > --- a/utils/gssd/gssd.h
> > +++ b/utils/gssd/gssd.h
> > @@ -83,7 +83,7 @@ struct clnt_info {
> > 	int			krb5_poll_index;
> > 	int			spkm3_fd;
> > 	int			spkm3_poll_index;
> > -	int			port;
> > +	struct sockaddr_storage addr;
> > };
> >
> > void init_client_list(void);
> > diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> > index 509946e..be17019 100644
> > --- a/utils/gssd/gssd_proc.c
> > +++ b/utils/gssd/gssd_proc.c
> > @@ -102,10 +102,65 @@ struct pollfd * pollarray;
> >
> > int pollsize;  /* the size of pollaray (in pollfd's) */
> >
> > +/*
> > + * convert an address string to a sockaddr_storage struct. Returns  
> > true
> > + * on success and false on failure.
> 
> I usually use the term "presentation address string" since that  
> specifically means an IP address expressed as a C string.  I guess  
> that's pretty obvious because you use inet_pton() here.
> 

Sounds reasonable.

> > + */
> > +static int
> > +addrstr_to_sockaddr(struct sockaddr *sa, const char *addr, const  
> > int port)
> > +{
> > +	struct sockaddr_in	*s4 = (struct sockaddr_in *) sa;
> > +
> > +	if (inet_pton(AF_INET, addr, &s4->sin_addr)) {
> > +		s4->sin_family = AF_INET;
> > +		s4->sin_port = htons(port);
> > +	} else {
> > +		printerr(0, "ERROR: unable to convert %s to address\n", addr);
> > +		return 0;
> > +	}
> 
> I've handled these with a switch statement, as you do later in  
> populate_port().  It's merely a question about consistent coding  
> style, but any reason not to take that approach here?
> 

Yes. switch statements are really only suitable when you have a simple
value to compare against. We're not comparing the address family here
because it's not yet known. We have to try and convert this opaque
string to an address first.

In the last patch, I add an "else if" where we try to convert it to an
ipv6 addr, but we can't really do "try this and if that fails then try
this" in the context of a switch.

In other places I try to use switches where it's suitable...

> > +
> > +	return 1;
> > +}
> > +
> > +/*
> > + * convert a sockaddr to a hostname
> > + */
> > +static char *
> > +sockaddr_to_hostname(const struct sockaddr *sa, const char *addr)
> > +{
> > +	socklen_t		addrlen;
> > +	int			err;
> > +	char 			*hostname;
> > +	char			hbuf[NI_MAXHOST];
> > +
> > +	switch (sa->sa_family) {
> > +	case AF_INET:
> > +		addrlen = sizeof(struct sockaddr_in);
> > +		break;
> > +	default:
> > +		printerr(0, "ERROR: unrecognized addr family %d\n",
> > +			 sa->sa_family);
> > +		return NULL;
> > +	}
> > +
> > +	err = getnameinfo(sa, addrlen, hbuf, sizeof(hbuf), NULL, 0,
> > +			  NI_NAMEREQD);
> > +	if (err) {
> > +		printerr(0, "ERROR: unable to resolve %s to hostname: %s\n",
> > +			 addr, gai_strerror(err));
> > +		return NULL;
> > +	}
> 
> getnameinfo(3) can return EAI_SYSTEM, in which case the real error  
> value is stored in errno  Browsing the gai_strerror(3) implementation  
> in glibc-2.7 seems to show that it's just a simple static char table  
> lookup, so it might be good to handle EAI_SYSTEM explicitly here.
> 
> Looks like you already do that in populate_port().
> 

Good catch. Will fix...

> > +
> > +	hostname = strdup(hbuf);
> > +
> > +	return hostname;
> > +}
> > +
> > /* XXX buffer problems: */
> > static int
> > read_service_info(char *info_file_name, char **servicename, char  
> > **servername,
> > -		  int *prog, int *vers, char **protocol, int *port) {
> > +		  int *prog, int *vers, char **protocol,
> > +		  struct sockaddr *addr) {
> > #define INFOBUFLEN 256
> > 	char		buf[INFOBUFLEN + 1];
> > 	static char	dummy[128];
> > @@ -117,10 +172,9 @@ read_service_info(char *info_file_name, char  
> > **servicename, char **servername,
> > 	char		protoname[16];
> > 	char		cb_port[128];
> > 	char		*p;
> > -	in_addr_t	inaddr;
> > 	int		fd = -1;
> > -	struct hostent	*ent = NULL;
> > 	int		numfields;
> > +	int		port = 0;
> >
> > 	*servicename = *servername = *protocol = NULL;
> >
> > @@ -160,21 +214,26 @@ read_service_info(char *info_file_name, char  
> > **servicename, char **servername,
> > 	if((*prog != 100003) || ((*vers != 2) && (*vers != 3) && (*vers !=  
> > 4)))
> > 		goto fail;
> >
> > -	/* create service name */
> > -	inaddr = inet_addr(address);
> > -	if (!(ent = gethostbyaddr(&inaddr, sizeof(inaddr), AF_INET))) {
> > -		printerr(0, "ERROR: can't resolve server %s name\n", address);
> > -		goto fail;
> > +	if (cb_port[0] != '\0') {
> > +		port = atoi(cb_port);
> > +		if (port < 0 || port > 65535)
> > +			goto fail;
> > 	}
> > -	if (!(*servername = calloc(strlen(ent->h_name) + 1, 1)))
> > +
> > +	if (!addrstr_to_sockaddr(addr, address, port))
> > +		goto fail;
> > +
> > +	*servername = sockaddr_to_hostname(addr, address);
> > +	if (*servername == NULL)
> > 		goto fail;
> > -	memcpy(*servername, ent->h_name, strlen(ent->h_name));
> > -	snprintf(buf, INFOBUFLEN, "%s@%s", service, ent->h_name);
> > +
> > +	nbytes = snprintf(buf, INFOBUFLEN, "%s@%s", service, *servername);
> > +	if (nbytes > INFOBUFLEN)
> > +		goto fail;
> > +
> > 	if (!(*servicename = calloc(strlen(buf) + 1, 1)))
> > 		goto fail;
> > 	memcpy(*servicename, buf, strlen(buf));
> > -	if (cb_port[0] != '\0')
> > -		*port = atoi(cb_port);
> >
> > 	if (!(*protocol = strdup(protoname)))
> > 		goto fail;
> > @@ -251,7 +310,7 @@ process_clnt_dir_files(struct clnt_info * clp)
> > 	if ((clp->servicename == NULL) &&
> > 	     read_service_info(info_file_name, &clp->servicename,
> > 				&clp->servername, &clp->prog, &clp->vers,
> > -				&clp->protocol, &clp->port))
> > +				&clp->protocol, (struct sockaddr *) &clp->addr))
> > 		return -1;
> > 	return 0;
> > }
> > @@ -599,8 +658,9 @@ int create_auth_rpc_client(struct clnt_info *clp,
> > 			 clp->servername, uid);
> > 		goto out_fail;
> > 	}
> > -	if (clp->port)
> > -		((struct sockaddr_in *)a->ai_addr)->sin_port = htons(clp->port);
> > +	if (((struct sockaddr_in) clp->addr).sin_port != 0)
> > +		((struct sockaddr_in *) a->ai_addr)->sin_port =
> > +				((struct sockaddr_in) clp->addr).sin_port;
> > 	if (a->ai_protocol == IPPROTO_TCP) {
> > 		if ((rpc_clnt = clnttcp_create(
> > 					(struct sockaddr_in *) a->ai_addr,
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com


-- 
Jeff Layton <jlayton@redhat.com>
