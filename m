From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] rpcbind: set SO_REUSEADDR on NC_TPI_COTS listening sockets
 (resend)
Date: Wed, 09 Jun 2010 15:58:42 -0400
Message-ID: <4C0FF272.3010600@oracle.com>
References: <1276081743-31277-1-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: libtirpc-devel-pyega4qmqnRoyOMFzWx49A@public.gmane.org, linux-nfs@vger.kernel.org
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:24874 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932544Ab0FIT7Z (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Jun 2010 15:59:25 -0400
In-Reply-To: <1276081743-31277-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For the record, this is an issue for any network service daemon that 
uses a fixed port.  This solution is similar to what sshd does in many 
cases.

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

On 06/ 9/10 07:09 AM, Jeff Layton wrote:
> I previously sent this patch to the libtirpc-devel list but got no
> response. Resending with wider distribution...
>
> If we don't set SO_REUSEADDR, then if there are any sockets on this port
> in TIME_WAIT state when rpcbind is restarted then that will prevent the
> bind() call from succeeding.
>
> Details of the problem are here:
>
>      https://bugzilla.redhat.com/show_bug.cgi?id=597356
>
> Signed-off-by: Jeff Layton<jlayton@redhat.com>
> ---
>   src/rpcbind.c |    9 +++++++++
>   1 files changed, 9 insertions(+), 0 deletions(-)
>
> diff --git a/src/rpcbind.c b/src/rpcbind.c
> index ddf2cfc..c8f0d9f 100644
> --- a/src/rpcbind.c
> +++ b/src/rpcbind.c
> @@ -276,6 +276,7 @@ init_transport(struct netconfig *nconf)
>   	int addrlen = 0;
>   	int nhostsbak;
>   	int checkbind;
> +	int on = 1;
>   	struct sockaddr *sa = NULL;
>   	u_int32_t host_addr[4];  /* IPv4 or IPv6 */
>   	struct sockaddr_un sun;
> @@ -493,6 +494,14 @@ init_transport(struct netconfig *nconf)
>   		}
>   		oldmask = umask(S_IXUSR|S_IXGRP|S_IXOTH);
>   		__rpc_fd2sockinfo(fd,&si);
> +		if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR,&on,
> +				sizeof(on)) != 0) {
> +			syslog(LOG_ERR, "cannot set SO_REUSEADDR on %s",
> +				nconf->nc_netid);
> +			if (res != NULL)
> +				freeaddrinfo(res);
> +			return 1;
> +		}
>   		if (bind(fd, sa, addrlen)<  0) {
>   			syslog(LOG_ERR, "cannot bind %s: %m", nconf->nc_netid);
>   			if (res != NULL)

