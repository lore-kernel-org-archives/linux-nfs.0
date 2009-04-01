From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/6] nfs-utils: store the address given in the upcall
	for later use
Date: Wed, 1 Apr 2009 13:06:00 -0400
Message-ID: <20090401130600.7cbe1be1@barsoom.rdu.redhat.com>
References: <1238595845-2186-1-git-send-email-jlayton@redhat.com>
	<1238595845-2186-3-git-send-email-jlayton@redhat.com>
	<8A187B5F-2B84-498E-9F05-43465BE8FECB@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <8A187B5F-2B84-498E-9F05-43465BE8FECB@oracle.com>
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

On Wed, 1 Apr 2009 12:58:09 -0400
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Apr 1, 2009, at 10:24 AM, Jeff Layton wrote:
> 
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
> >
> > Signed-off-by: Jeff Layton <jlayton@redhat.com>
> > ---
> > utils/gssd/gssd.h      |    2 +-
> > utils/gssd/gssd_proc.c |   90 ++++++++++++++++++++++++++++++++++++++ 
> > +--------
> > 2 files changed, 75 insertions(+), 17 deletions(-)
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
> > index 509946e..f5f3a0f 100644
> > --- a/utils/gssd/gssd_proc.c
> > +++ b/utils/gssd/gssd_proc.c
> > @@ -102,10 +102,70 @@ struct pollfd * pollarray;
> >
> > int pollsize;  /* the size of pollaray (in pollfd's) */
> >
> > +/*
> > + * convert an address string to a sockaddr_storage struct. Returns  
> > true
> > + * on success and false on failure.
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
> > +#define MAX_HOSTNAME_LEN 127
> 
> netdb.h provides NI_MAXHOST.  Since getnameinfo(3) is now required,  
> you can use that.  If this length maximum is required by the kernel  
> gss upcall API, then this should be defined in a more public place, I  
> think, as part of the interface specification.
> 

Thanks, I'll look at that.

> > +	char 			*hostname;
> > +	socklen_t		addrlen;
> > +	int			err;
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
> > +	hostname = calloc(1, MAX_HOSTNAME_LEN + 1);
> > +	if (!hostname) {
> > +		printerr(0, "ERROR: unable to allocate hostname string\n");
> > +		return NULL;
> > +	}
> 
> A simpler approach would be to perform the getnameinfo into a buffer  
> on the stack, then strdup it.
> 

Noted...

> > +
> > +	err = getnameinfo(sa, addrlen, hostname, MAX_HOSTNAME_LEN, NULL,
> > +			  0, NI_NAMEREQD);
> > +	if (err) {
> > +		free(hostname);
> > +		hostname = NULL;
> > +		printerr(0, "ERROR: unable to resolve %s to hostname: %s\n",
> > +			 addr, gai_strerror(err));
> > +	}
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
> > @@ -117,10 +177,9 @@ read_service_info(char *info_file_name, char  
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
> > @@ -160,21 +219,19 @@ read_service_info(char *info_file_name, char  
> > **servicename, char **servername,
> > 	if((*prog != 100003) || ((*vers != 2) && (*vers != 3) && (*vers !=  
> > 4)))
> > 		goto fail;
> >
> > -	/* create service name */
> > -	inaddr = inet_addr(address);
> > -	if (!(ent = gethostbyaddr(&inaddr, sizeof(inaddr), AF_INET))) {
> > -		printerr(0, "ERROR: can't resolve server %s name\n", address);
> > +	if (cb_port[0] != '\0')
> > +		port = atoi(cb_port);
> 
> Before passing this to addrstr_to_sockaddr, should we check that the  
> port value is in the proper range?
> 

Sounds reasonable.

> > +	if (!addrstr_to_sockaddr(addr, address, port))
> > 		goto fail;
> > -	}
> > -	if (!(*servername = calloc(strlen(ent->h_name) + 1, 1)))
> > +
> > +	*servername = sockaddr_to_hostname(addr, address);
> > +	if (*servername == NULL)
> > 		goto fail;
> > -	memcpy(*servername, ent->h_name, strlen(ent->h_name));
> > -	snprintf(buf, INFOBUFLEN, "%s@%s", service, ent->h_name);
> > +
> > +	snprintf(buf, INFOBUFLEN, "%s@%s", service, *servername);
> 
> You should check the return code here.  It should be not greater than  
> INFOBUFLEN.
> 

Do we really need to do this? Doesn't using snprintf guarantee that
it won't be?

> > 	if (!(*servicename = calloc(strlen(buf) + 1, 1)))
> > 		goto fail;
> > 	memcpy(*servicename, buf, strlen(buf));
> > -	if (cb_port[0] != '\0')
> > -		*port = atoi(cb_port);
> >
> > 	if (!(*protocol = strdup(protoname)))
> > 		goto fail;
> > @@ -251,7 +308,7 @@ process_clnt_dir_files(struct clnt_info * clp)
> > 	if ((clp->servicename == NULL) &&
> > 	     read_service_info(info_file_name, &clp->servicename,
> > 				&clp->servername, &clp->prog, &clp->vers,
> > -				&clp->protocol, &clp->port))
> > +				&clp->protocol, (struct sockaddr *) &clp->addr))
> > 		return -1;
> > 	return 0;
> > }
> > @@ -599,8 +656,9 @@ int create_auth_rpc_client(struct clnt_info *clp,
> > 			 clp->servername, uid);
> > 		goto out_fail;
> > 	}
> > -	if (clp->port)
> > -		((struct sockaddr_in *)a->ai_addr)->sin_port = htons(clp->port);
> > +	if (((struct sockaddr_in) clp->addr).sin_port != 0)
> > +		((struct sockaddr_in *) a->ai_addr)->sin_port =
> > +				((struct sockaddr_in) clp->addr).sin_port;
> 
> This might be an early opportunity to provide address family-agnostic  
> get_port() and set_port() helpers.
> 

I do that in a later patch with the populate_port() function. The only
reason I have the above is to keep things bisectable.

> >
> > 	if (a->ai_protocol == IPPROTO_TCP) {
> > 		if ((rpc_clnt = clnttcp_create(
> > 					(struct sockaddr_in *) a->ai_addr,
> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com


Thanks for the comments so far...
-- 
Jeff Layton <jlayton@redhat.com>
