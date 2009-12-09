From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] gssd: have gssd deal with scopeid field in upcall
Date: Wed, 9 Dec 2009 13:50:50 -0500
Message-ID: <20091209185050.GA23234@fieldses.org>
References: <1260305091-19523-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1260305091-19523-1-git-send-email-jlayton@redhat.com>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/options/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Dec 08, 2009 at 03:44:51PM -0500, Jeff Layton wrote:
> Recent kernels (2.6.32) have started displaying the scopeid for some
> addresses in the upcall.

Does this mean we lost compatibility with old gssd's?

(Would it be better to keep the "address" line the same (if that's the
problematic line), and add a new line that old gssd's can avoid?)

Or are the new addresses only going to occur in cases that would have
stumped old gssd's anyway?  (In which case, how did old gssd's fail?)

--b.

> gssd doesn't know how to deal with them. Change
> gssd to use getaddrinfo instead of inet_pton since that can deal with
> scopeid's in addresses. That also allows us to elminate the port
> conversion in read_service_info.
> 
> If getaddrinfo returns an address with a non-zero sin6_scope_id however,
> reject it. getnameinfo ignores that field and just uses the sin6_addr
> part when resolving. But, two addresses that differ only in
> sin6_scope_id could refer to completely different hosts.
> 
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
>  utils/gssd/gssd_proc.c |   60 ++++++++++++++++++++++++++++--------------------
>  1 files changed, 35 insertions(+), 25 deletions(-)
> 
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 33a31c3..795e06c 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -108,7 +108,7 @@ int pollsize;  /* the size of pollaray (in pollfd's) */
>  
>  /*
>   * convert a presentation address string to a sockaddr_storage struct. Returns
> - * true on success and false on failure.
> + * true on success or false on failure.
>   *
>   * Note that we do not populate the sin6_scope_id field here for IPv6 addrs.
>   * gssd nececessarily relies on hostname resolution and DNS AAAA records
> @@ -120,26 +120,43 @@ int pollsize;  /* the size of pollaray (in pollfd's) */
>   * not really feasible at present.
>   */
>  static int
> -addrstr_to_sockaddr(struct sockaddr *sa, const char *addr, const int port)
> +addrstr_to_sockaddr(struct sockaddr *sa, const char *node, const char *port)
>  {
> -	struct sockaddr_in	*s4 = (struct sockaddr_in *) sa;
> -#ifdef IPV6_SUPPORTED
> -	struct sockaddr_in6	*s6 = (struct sockaddr_in6 *) sa;
> -#endif /* IPV6_SUPPORTED */
> +	int rc;
> +	struct addrinfo *res;
> +	struct addrinfo hints = { .ai_flags = AI_NUMERICHOST | AI_NUMERICSERV };
>  
> -	if (inet_pton(AF_INET, addr, &s4->sin_addr)) {
> -		s4->sin_family = AF_INET;
> -		s4->sin_port = htons(port);
> -#ifdef IPV6_SUPPORTED
> -	} else if (inet_pton(AF_INET6, addr, &s6->sin6_addr)) {
> -		s6->sin6_family = AF_INET6;
> -		s6->sin6_port = htons(port);
> +#ifndef IPV6_SUPPORTED
> +	hints.ai_family = AF_INET;
>  #endif /* IPV6_SUPPORTED */
> -	} else {
> -		printerr(0, "ERROR: unable to convert %s to address\n", addr);
> +
> +	rc = getaddrinfo(node, port, &hints, &res);
> +	if (rc) {
> +		printerr(0, "ERROR: unable to convert %s|%s to sockaddr: %s\n",
> +			 node, port, rc == EAI_SYSTEM ? strerror(errno) :
> +						gai_strerror(rc));
>  		return 0;
>  	}
>  
> +#ifdef IPV6_SUPPORTED
> +	/*
> +	 * getnameinfo ignores the scopeid. If the address turns out to have
> +	 * a non-zero scopeid, we can't use it -- the resolved host might be
> +	 * completely different from the one intended.
> +	 */
> +	if (res->ai_addr->sa_family == AF_INET6) {
> +		struct sockaddr_in6 *sin6 = (struct sockaddr_in6 *)res->ai_addr;
> +		if (sin6->sin6_scope_id) {
> +			printerr(0, "ERROR: address %s has non-zero "
> +				    "sin6_scope_id!\n", node);
> +			freeaddrinfo(res);
> +			return 0;
> +		}
> +	}
> +#endif /* IPV6_SUPPORTED */
> +
> +	memcpy(sa, res->ai_addr, res->ai_addrlen);
> +	freeaddrinfo(res);
>  	return 1;
>  }
>  
> @@ -197,11 +214,10 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
>  	char		program[16];
>  	char		version[16];
>  	char		protoname[16];
> -	char		cb_port[128];
> +	char		port[128];
>  	char		*p;
>  	int		fd = -1;
>  	int		numfields;
> -	int		port = 0;
>  
>  	*servicename = *servername = *protocol = NULL;
>  
> @@ -230,9 +246,9 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
>  		goto fail;
>  	}
>  
> -	cb_port[0] = '\0';
> +	port[0] = '\0';
>  	if ((p = strstr(buf, "port")) != NULL)
> -		sscanf(p, "port: %127s\n", cb_port);
> +		sscanf(p, "port: %127s\n", port);
>  
>  	/* check service, program, and version */
>  	if (memcmp(service, "nfs", 3) != 0)
> @@ -249,12 +265,6 @@ read_service_info(char *info_file_name, char **servicename, char **servername,
>  			goto fail;
>  	}
>  
> -	if (cb_port[0] != '\0') {
> -		port = atoi(cb_port);
> -		if (port < 0 || port > 65535)
> -			goto fail;
> -	}
> -
>  	if (!addrstr_to_sockaddr(addr, address, port))
>  		goto fail;
>  
> -- 
> 1.6.5.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
