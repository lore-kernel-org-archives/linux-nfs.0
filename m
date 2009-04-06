From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 5/5] nfs-utils: add IPv6 code to gssd
Date: Mon, 6 Apr 2009 11:35:21 -0400
Message-ID: <BCFA87B8-22EA-4ABB-87B5-38DAB2621579@oracle.com>
References: <1238938983-7347-1-git-send-email-jlayton@redhat.com>
	<1238938983-7347-6-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <nfsv4-bounces@linux-nfs.org>
In-Reply-To: <1238938983-7347-6-git-send-email-jlayton@redhat.com>
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

On Apr 5, 2009, at 9:43 AM, Jeff Layton wrote:
> All of the pieces to handle IPv6 are now in place. Add IPv6-specific
> code wrapped in the proper #ifdef's so that IPv6 support works when
> it's enabled at build-time.
>
> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> utils/gssd/gssd_proc.c |   34 ++++++++++++++++++++++++++++++++++
> 1 files changed, 34 insertions(+), 0 deletions(-)
>
> diff --git a/utils/gssd/gssd_proc.c b/utils/gssd/gssd_proc.c
> index 1f7dadd..8a595c2 100644
> --- a/utils/gssd/gssd_proc.c
> +++ b/utils/gssd/gssd_proc.c
> @@ -111,10 +111,18 @@ static int
> addrstr_to_sockaddr(struct sockaddr *sa, const char *addr, const int  
> port)
> {
> 	struct sockaddr_in	*s4 = (struct sockaddr_in *) sa;
> +#ifdef IPV6_SUPPORTED
> +	struct sockaddr_in6	*s6 = (struct sockaddr_in6 *) sa;
> +#endif /* IPV6_SUPPORTED */
>
> 	if (inet_pton(AF_INET, addr, &s4->sin_addr)) {
> 		s4->sin_family = AF_INET;
> 		s4->sin_port = htons(port);
> +#ifdef IPV6_SUPPORTED
> +	} else if (inet_pton(AF_INET6, addr, &s6->sin6_addr)) {
> +		s6->sin6_family = AF_INET6;
> +		s6->sin6_port = htons(port);
> +#endif /* IPV6_SUPPORTED */

Does this support scope IDs?  Do we expect to get a link-local IPv6  
address here?

> 	} else {
> 		printerr(0, "ERROR: unable to convert %s to address\n", addr);
> 		return 0;
> @@ -138,6 +146,11 @@ sockaddr_to_hostname(const struct sockaddr *sa,  
> const char *addr)
> 	case AF_INET:
> 		addrlen = sizeof(struct sockaddr_in);
> 		break;
> +#ifdef IPV6_SUPPORTED
> +	case AF_INET6:
> +		addrlen = sizeof(struct sockaddr_in6);
> +		break;
> +#endif /* IPV6_SUPPORTED */
> 	default:
> 		printerr(0, "ERROR: unrecognized addr family %d\n",
> 			 sa->sa_family);
> @@ -549,6 +562,9 @@ static int
> populate_port(struct sockaddr *sa, char *servicename, int protocol)
> {
> 	struct sockaddr_in	*s4 = (struct sockaddr_in *) sa;
> +#ifdef IPV6_SUPPORTED
> +	struct sockaddr_in6	*s6 = (struct sockaddr_in6 *) sa;
> +#endif /* IPV6_SUPPORTED */
> 	char			service[64];
> 	char			*at_sign;
> 	int			errcode;
> @@ -569,6 +585,15 @@ populate_port(struct sockaddr *sa, char  
> *servicename, int protocol)
> 			return 1;
> 		}
> 		break;
> +#ifdef IPV6_SUPPORTED
> +	case AF_INET6:
> +		if (s6->sin6_port != 0) {
> +			printerr(2, "DEBUG: port already set to %d\n",
> +				 ntohs(s6->sin6_port));
> +			return 1;
> +		}
> +		break;
> +#endif /* IPV6_SUPPORTED */
> 	default:
> 		printerr(0, "ERROR: unsupported address family %d\n",
> 			    sa->sa_family);
> @@ -600,6 +625,10 @@ populate_port(struct sockaddr *sa, char  
> *servicename, int protocol)
>
> 	if (a->ai_family == AF_INET)
> 		s4->sin_port = ((struct sockaddr_in *) a->ai_addr)->sin_port;
> +#ifdef IPV6_SUPPORTED
> +	else if (a->ai_family == AF_INET6)
> +		s6->sin6_port = ((struct sockaddr_in6 *) a->ai_addr)->sin6_port;
> +#endif /* IPV6_SUPPORTED */
> 	else
> 		printerr(0, "ERROR: unrecognized address family %d returned "
> 			    "by getaddrinfo.\n", a->ai_family);
> @@ -700,6 +729,11 @@ int create_auth_rpc_client(struct clnt_info *clp,
> 	case AF_INET:
> 		salen = sizeof(struct sockaddr_in);
> 		break;
> +#ifdef IPV6_SUPPORTED
> +	case AF_INET6:
> +		salen = sizeof(struct sockaddr_in6);
> +		break;
> +#endif /* IPV6_SUPPORTED */
> 	default:
> 		printerr(1, "ERROR: Unknown address family %d\n",
> 			 addr->sa_family);

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
