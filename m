Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33586 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752812AbcAPWBO (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 16 Jan 2016 17:01:14 -0500
Subject: Re: [PATCH 1/1] [nfs-utils] handle EINTR during connection
 establishment
To: Olga Kornievskaia <kolga@netapp.com>
References: <1452807265-36920-1-git-send-email-kolga@netapp.com>
Cc: linux-nfs@vger.kernel.org
From: Steve Dickson <SteveD@redhat.com>
Message-ID: <569ABDA9.6040607@RedHat.com>
Date: Sat, 16 Jan 2016 17:01:13 -0500
MIME-Version: 1.0
In-Reply-To: <1452807265-36920-1-git-send-email-kolga@netapp.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



On 01/14/2016 04:34 PM, Olga Kornievskaia wrote:
> both connect() and select() can receive EINTR signals that we need to
> recover from.
> 
> In Unix Network Programming, volume 1, section 5.9, W. Richard Stevens
> states:
> 
> What we are doing […] is restarting the interrupted system call ourself.
> This is fine for accept, along with the functions such as read, write,
> select and open. But there is one function that we cannot restart ourself:
> connect. If this function returns EINTR, we cannot call it again, as doing
> so will return an immediate error. When connect is interrupted by a caught
> signal and is not automatically restarted, we must call select to wait for
> the connection to complete,
> 
> Thus for connect() treat both EINPROGRESS and EINTR the same -- call
> select().
> 
> For select(), it should be re-tried again upon receiving EINTR.
> 
> Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
Committed... Nice work!! 

steved.

> ---
>  support/nfs/rpc_socket.c |   16 +++++++++++-----
>  1 files changed, 11 insertions(+), 5 deletions(-)
> 
> diff --git a/support/nfs/rpc_socket.c b/support/nfs/rpc_socket.c
> index c14efe8..edd43cc 100644
> --- a/support/nfs/rpc_socket.c
> +++ b/support/nfs/rpc_socket.c
> @@ -215,7 +215,7 @@ static int nfs_connect_nb(const int fd, const struct sockaddr *sap,
>  	 * use it later.
>  	 */
>  	ret = connect(fd, sap, salen);
> -	if (ret < 0 && errno != EINPROGRESS) {
> +	if (ret < 0 && errno != EINPROGRESS && errno != EINTR) {
>  		ret = -1;
>  		goto done;
>  	}
> @@ -227,10 +227,16 @@ static int nfs_connect_nb(const int fd, const struct sockaddr *sap,
>  	FD_ZERO(&rset);
>  	FD_SET(fd, &rset);
>  
> -	ret = select(fd + 1, NULL, &rset, NULL, timeout);
> -	if (ret <= 0) {
> -		if (ret == 0)
> -			errno = ETIMEDOUT;
> +	while ((ret = select(fd + 1, NULL, &rset, NULL, timeout)) < 0) {
> +		if (errno != EINTR) {
> +			ret = -1;
> +			goto done;
> +		} else {
> +			continue;
> +		}
> +	}
> +	if (ret == 0) {
> +		errno = ETIMEDOUT;
>  		ret = -1;
>  		goto done;
>  	}
> 
