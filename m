From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH 05/10] nfs-utils: move check for active knfsd to helper function
Date: Thu, 4 Jun 2009 16:00:43 -0400
Message-ID: <6D2FD4AF-B289-4EB5-B2CE-F83BA80514B1@oracle.com>
References: <1244058763-10352-1-git-send-email-jlayton@redhat.com> <1244058763-10352-6-git-send-email-jlayton@redhat.com>
Mime-Version: 1.0 (Apple Message framework v935.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org, steved@redhat.com
To: Jeff Layton <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:26208 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752292AbZFDUBH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2009 16:01:07 -0400
In-Reply-To: <1244058763-10352-6-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 3, 2009, at 3:52 PM, Jeff Layton wrote:

> nfssvc_setfds checks to see if knfsd is already running. Move this
> check to a helper function. Eventually the nfsd code will call this
> directly.

Some of this isn't your fault, but this code could use a little extra  
clean up as you split it up, IMO.

> Signed-off-by: Jeff Layton <jlayton@redhat.com>
> ---
> support/nfs/nfssvc.c |   44 ++++++++++++++++++++++++++++++ 
> +-------------
> 1 files changed, 31 insertions(+), 13 deletions(-)
>
> diff --git a/support/nfs/nfssvc.c b/support/nfs/nfssvc.c
> index 3e6bd31..8b15c4d 100644
> --- a/support/nfs/nfssvc.c
> +++ b/support/nfs/nfssvc.c
> @@ -24,28 +24,46 @@
> #define NFSD_VERS_FILE    "/proc/fs/nfsd/versions"
> #define NFSD_THREAD_FILE  "/proc/fs/nfsd/threads"
>
> -static void
> -nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
> +/*
> + * Are there already sockets configured? If not, then it is safe to  
> try to
> + * open some and pass them through.
> + *
> + * Note: If the user explicitly asked for 'udp', then we should  
> probably check
> + * if that is open, and should open it if not. However we don't  
> yet. All
> + * sockets have to be opened when the first daemon is started.
> + */
> +int
> +nfssvc_inuse(void)
> {
> -	int fd, n, on=1;
> +	int fd, n;

read(2) returns a ssize_t result, not an int.

> 	char buf[BUFSIZ];

Eesh.  BUFSIZ looks like it's two pages on my system, so adding this  
helper makes the stack requirements in this path over 16KB.

Might be better if we used something a little more stack friendly  
here.  The kernel bounds the size of the read(2) result to  
SIMPLE_TRANSACTION_LIMIT, which is less than a page, for example.   
Making it a static would keep "buf" off the stack, too; or checking  
how much buffer we really need (like only a few bytes, for this  
particular check) might be better.

> -	int udpfd = -1, tcpfd = -1;
> -	struct sockaddr_in sin;
>
> 	fd = open(NFSD_PORTS_FILE, O_RDONLY);
> +
> +	/* problem opening file, assume that nothing is configured */
> 	if (fd < 0)
> -		return;
> +		return 0;
> +
> 	n = read(fd, buf, BUFSIZ);

Nit: Using "sizeof(buf)" might be slightly more maintainable than  
"BUFSIZ".

> 	close(fd);
> +
> 	if (n != 0)

If read(2) returns -1, we return 1 here.  How about "return (n > 0);" ?

> +		return 1;
> +
> +	return 0;
> +}
> +
> +static void
> +nfssvc_setfds(int port, unsigned int ctlbits, char *haddr)
> +{
> +	int fd, n, on=1;

Another compiler warning issue: "n" is probably now unused in  
nfssvc_setfds().

>
> +	char buf[BUFSIZ];
> +	int udpfd = -1, tcpfd = -1;
> +	struct sockaddr_in sin;
> +
> +	if (nfssvc_inuse())
> 		return;
> -	/* there are no ports currently open, so it is safe to
> -	 * try to open some and pass them through.
> -	 * Note: If the user explicitly asked for 'udp', then
> -	 * we should probably check if that is open, and should
> -	 * open it if not.  However we don't yet.  All sockets
> -	 * have to be opened when the first daemon is started.
> -	 */
> +
> 	fd = open(NFSD_PORTS_FILE, O_WRONLY);
> 	if (fd < 0)
> 		return;
> -- 
> 1.6.2.2
>

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
