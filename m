From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 2/6] nfs-utils: store the address given in the upcall for
	later use
Date: Wed, 11 Mar 2009 17:41:05 -0400
Message-ID: <515F0543-F164-4E2D-B68B-5521FCDBEB79@oracle.com>
References: <1236789782-8867-1-git-send-email-jlayton@redhat.com>
	<1236789782-8867-3-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1236789782-8867-3-git-send-email-jlayton@redhat.com>
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

On Mar 11, 2009, at 12:42 PM, Jeff Layton wrote:
> The current upcall is rather inefficient. We first convert the address
> to a hostname, and then later when we set up the RPC client, we do a
> hostname lookup to convert it back to an address.
>
> Begin to change this by keeping the address in the clnt_info that we
> get out of the upcall. Since a sockaddr has a port field, we can also
> eliminate the port from the clnt_info.
>
> Finally, switch to getnameinfo() instead of gethostbyaddr(). We'll
> need to use that call anyway when we switch to using IPv6.
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> utils/gssd/gssd.h      |    2 +-
> utils/gssd/gssd_proc.c |  105 +++++++++++++++++++++++++++++++++++++++ 
> +-------
> 2 files changed, 90 insertions(+), 17 deletions(-)
>
> diff --git a/utils/gssd/gssd.h b/utils/gssd/gssd.h
> index 082039a..20f52ff 100644
> --- a/utils/gssd/gssd.h
> +++ b/utils/gssd/gssd.h
> @@ -83,7 +83,7 @@ struct clnt_info {
> 	int			krb5_poll_index;
> 	int			spkm3_fd;
> 	int			spkm3_poll_index;
> -	int			port;
> +	struct sockaddr_storage *addr;

By convention, if you want to store a pointer to an socket address,  
"struct sockaddr *" is appropriate.  If you want to allocate memory to  
store the socket address in this field, "struct sockaddr_storage" is  
appropriate.

I think you will be better off with:

	struct sockaddr_storage addr;

and skipping the extra memory allocation.

> };
>
> void init_client_list(void);
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 509946e..4f05040 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -102,10 +102,80 @@ struct pollfd * pollarray;
>
> int pollsize;  /* the size of pollaray (in pollfd's) */
>
> +/*
> + * convert an address string to a sockaddr_storage struct
> + */
> +static struct sockaddr_storage *
> +addrstr_to_sockaddr(const char *addr, const int port)
> +{
> +	struct sockaddr_storage *ss;
> +	struct sockaddr_in	*s4;
> +
> +	ss = calloc(1, sizeof(struct sockaddr_storage));
> +	if (!ss) {
> +		printerr(0, "ERROR: unable to allocate storage to convert "
> +			    "address %s\n", addr);
> +		goto out;
> +	}
> +
> +	s4 = (struct sockaddr_in *) ss;
> +
> +	if (inet_pton(AF_INET, addr, &s4->sin_addr)) {
> +		s4->sin_family = AF_INET;
> +		s4->sin_port = htons(port);
> +	} else {
> +		printerr(0, "ERROR: unable to convert %s to address\n", addr);
> +		free(ss);
> +		ss = NULL;
> +	}
> +out:
> +	return ss;
> +}
> +
> +/*
> + * convert a sockaddr to a hostname
> + */
> +static char *
> +sockaddr_to_hostname(const struct sockaddr *sa, const char *addr)
> +{
> +#define MAX_HOSTNAME_LEN 127
> +	char 			*hostname;
> +	socklen_t		addrlen;
> +	int			err;
> +
> +	switch (sa->sa_family) {
> +	case AF_INET:
> +		addrlen = sizeof(struct sockaddr_in);
> +		break;
> +	default:
> +		printerr(0, "ERROR: unrecognized addr family %d\n",
> +			 sa->sa_family);
> +		return NULL;
> +	}
> +
> +	hostname = calloc(1, MAX_HOSTNAME_LEN + 1);
> +	if (!hostname) {
> +		printerr(0, "ERROR: unable to allocate hostname string\n");
> +		return NULL;
> +	}
> +
> +	err = getnameinfo(sa, addrlen, hostname, MAX_HOSTNAME_LEN, NULL,
> +			  0, NI_NAMEREQD);
> +	if (err) {
> +		free(hostname);
> +		hostname = NULL;
> +		printerr(0, "ERROR: unable to resolve %s to hostname: %s\n",
> +			 addr, gai_strerror(err));
> +	}
> +
> +	return hostname;
> +}
> +
> /* XXX buffer problems: */
> static int
> read_service_info(char *info_file_name, char **servicename, char  
> **servername,
> -		  int *prog, int *vers, char **protocol, int *port) {
> +		  int *prog, int *vers, char **protocol,
> +		  struct sockaddr_storage **addr) {
> #define INFOBUFLEN 256
> 	char		buf[INFOBUFLEN + 1];
> 	static char	dummy[128];
> @@ -117,12 +187,12 @@ read_service_info(char *info_file_name, char  
> **servicename, char **servername,
> 	char		protoname[16];
> 	char		cb_port[128];
> 	char		*p;
> -	in_addr_t	inaddr;
> 	int		fd = -1;
> -	struct hostent	*ent = NULL;
> 	int		numfields;
> +	int		port = 0;
>
> 	*servicename = *servername = *protocol = NULL;
> +	*addr = NULL;
>
> 	if ((fd = open(info_file_name, O_RDONLY)) == -1) {
> 		printerr(0, "ERROR: can't open %s: %s\n", info_file_name,
> @@ -160,21 +230,20 @@ read_service_info(char *info_file_name, char  
> **servicename, char **servername,
> 	if((*prog != 100003) || ((*vers != 2) && (*vers != 3) && (*vers !=  
> 4)))
> 		goto fail;
>
> -	/* create service name */
> -	inaddr = inet_addr(address);
> -	if (!(ent = gethostbyaddr(&inaddr, sizeof(inaddr), AF_INET))) {
> -		printerr(0, "ERROR: can't resolve server %s name\n", address);
> +	if (cb_port[0] != '\0')
> +		port = atoi(cb_port);
> +	*addr = addrstr_to_sockaddr(address, port);
> +	if (*addr == NULL)
> 		goto fail;
> -	}
> -	if (!(*servername = calloc(strlen(ent->h_name) + 1, 1)))
> +
> +	*servername = sockaddr_to_hostname((struct sockaddr *) *addr,  
> address);
> +	if (*servername == NULL)
> 		goto fail;
> -	memcpy(*servername, ent->h_name, strlen(ent->h_name));
> -	snprintf(buf, INFOBUFLEN, "%s@%s", service, ent->h_name);
> +
> +	snprintf(buf, INFOBUFLEN, "%s@%s", service, *servername);
> 	if (!(*servicename = calloc(strlen(buf) + 1, 1)))
> 		goto fail;
> 	memcpy(*servicename, buf, strlen(buf));
> -	if (cb_port[0] != '\0')
> -		*port = atoi(cb_port);
>
> 	if (!(*protocol = strdup(protoname)))
> 		goto fail;
> @@ -185,7 +254,9 @@ fail:
> 	free(*servername);
> 	free(*servicename);
> 	free(*protocol);
> +	free(*addr);
> 	*servicename = *servername = *protocol = NULL;
> +	*addr = NULL;
> 	return -1;
> }
>
> @@ -205,6 +276,7 @@ destroy_client(struct clnt_info *clp)
> 	free(clp->servicename);
> 	free(clp->servername);
> 	free(clp->protocol);
> +	free(clp->addr);
> 	free(clp);
> }
>
> @@ -251,7 +323,7 @@ process_clnt_dir_files(struct clnt_info * clp)
> 	if ((clp->servicename == NULL) &&
> 	     read_service_info(info_file_name, &clp->servicename,
> 				&clp->servername, &clp->prog, &clp->vers,
> -				&clp->protocol, &clp->port))
> +				&clp->protocol, &clp->addr))
> 		return -1;
> 	return 0;
> }
> @@ -599,8 +671,9 @@ int create_auth_rpc_client(struct clnt_info *clp,
> 			 clp->servername, uid);
> 		goto out_fail;
> 	}
> -	if (clp->port)
> -		((struct sockaddr_in *)a->ai_addr)->sin_port = htons(clp->port);
> +	if (((struct sockaddr_in *) clp->addr)->sin_port != 0)
> +		((struct sockaddr_in *) a->ai_addr)->sin_port =
> +				((struct sockaddr_in *) clp->addr)->sin_port;
> 	if (a->ai_protocol == IPPROTO_TCP) {
> 		if ((rpc_clnt = clnttcp_create(
> 					(struct sockaddr_in *) a->ai_addr,
> -- 
> 1.6.0.6
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
