Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36875 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752636AbbIPTJD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Sep 2015 15:09:03 -0400
Subject: Re: [PATCH] statd: statd_get_socket() should return open fds
To: Chuck Lever <chuck.lever@oracle.com>
References: <20150824160538.1402.26833.stgit@seurat.1015granger.net>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <55F9BE4C.7030707@RedHat.com>
Date: Wed, 16 Sep 2015 15:09:00 -0400
MIME-Version: 1.0
In-Reply-To: <20150824160538.1402.26833.stgit@seurat.1015granger.net>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 08/24/2015 12:05 PM, Chuck Lever wrote:
> Tastky <tastky@gmail.com> reports:
>> There appears to be a bug in nfs-utils exposed by musl, which
>> makes rpc.statd loop with:
>>
>> my_svc_run() - select: Bad file descriptor
> 
> OpenGroup says getservbyport(3) is supposed to return NULL when
> no entry exists for the specified port. But musl's getservbyport(3)
> never returns NULL (likely a bug).
> 
> Thus statd_get_socket() tries bindresvport(3) 100 times, then gives
> up and returns the last socket it created. This should work fine,
> but there's a bug in the retry loop:
> 
> Rich Felker <dalias@libc.org> says:
>> The logic bug is the count-down loop that closes all the temp
>> sockets. In the case where the loop terminates via break, it
>> leaves the last one open and only closes the extras. But in the
>> case where where the loop terminates via the end condition in the
>> for statement, the close loop closes all the sockets _including_
>> the one it intends to use.
> 
> (emphasis mine). The closed socket fd is then passed to select(2).
> 
> See also: http://www.openwall.com/lists/musl/2015/08
> 
> The fix is to perform the loop termination test before adding sockfd
> to the set of fds to be closed. As additional clean ups, remove the
> use of the variable-length stack array, and switch to variable names
> that better document the purpose of this logic.
> 
> Reported-by: Tastky <tastky@gmail.com>
> Fixes: eb8229338f06 ("rpc.statd: Fix socket binding loop.")
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Committed... 

steved.

> ---
>  utils/statd/rmtcall.c |   27 ++++++++++++++++++---------
>  1 file changed, 18 insertions(+), 9 deletions(-)
> 
> diff --git a/utils/statd/rmtcall.c b/utils/statd/rmtcall.c
> index dc620a9..d2255a1 100644
> --- a/utils/statd/rmtcall.c
> +++ b/utils/statd/rmtcall.c
> @@ -52,6 +52,9 @@
>  
>  static int		sockfd = -1;	/* notify socket */
>  
> +/* How many times to try looking for an unused privileged port */
> +#define MAX_BRP_RETRIES	100
> +
>  /*
>   * Initialize socket used to notify lockd of peer reboots.
>   *
> @@ -68,14 +71,14 @@ statd_get_socket(void)
>  {
>  	struct sockaddr_in	sin;
>  	struct servent *se;
> -	const int loopcnt = 100;
> -	int i, tmp_sockets[loopcnt];
> +	static int prevsocks[MAX_BRP_RETRIES];
> +	unsigned int retries;
>  
>  	if (sockfd >= 0)
>  		return sockfd;
>  
> -	for (i = 0; i < loopcnt; ++i) {
> -
> +	retries = 0;
> +	do {
>  		if ((sockfd = socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP)) < 0) {
>  			xlog(L_ERROR, "%s: Can't create socket: %m", __func__);
>  			break;
> @@ -96,13 +99,19 @@ statd_get_socket(void)
>  		se = getservbyport(sin.sin_port, "udp");
>  		if (se == NULL)
>  			break;
> -		/* rather not use that port, try again */
>  
> -		tmp_sockets[i] = sockfd;
> -	}
> +		if (retries == MAX_BRP_RETRIES) {
> +			xlog(D_GENERAL, "%s: No unused privileged ports",
> +					__func__);
> +			break;
> +		}
> +
> +		/* rather not use that port, try again */
> +		prevsocks[retries++] = sockfd;
> +	} while (1);
>  
> -	while (--i >= 0)
> -		close(tmp_sockets[i]);
> +	while (retries)
> +		close(prevsocks[--retries]);
>  
>  	if (sockfd < 0)
>  		return -1;
> 
