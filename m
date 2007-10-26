From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH 09/27] SUNRPC: Fix use of copy_to_user()
	in	gss_pipe_upcall()
Date: Fri, 26 Oct 2007 14:34:00 -0400
Message-ID: <1193423640.7486.31.camel@heimdal.trondhjem.org>
References: <20071026173126.31475.41682.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IlTzU-0004l1-CR
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 11:33:11 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IlTzV-0003iJ-Uz
	for nfs@lists.sourceforge.net; Fri, 26 Oct 2007 11:33:09 -0700
In-Reply-To: <20071026173126.31475.41682.stgit@manray.1015granger.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net


On Fri, 2007-10-26 at 13:31 -0400, Chuck Lever wrote:
> The gss_pipe_upcall() function expects the copy_to_user() function to
> return a negative error value if the call fails, but copy_to_user()
> returns an unsigned long number of bytes that couldn't be copied.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  net/sunrpc/auth_gss/auth_gss.c |   13 +++++++------
>  1 files changed, 7 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
> index 53995af..f9e546c 100644
> --- a/net/sunrpc/auth_gss/auth_gss.c
> +++ b/net/sunrpc/auth_gss/auth_gss.c
> @@ -472,18 +472,19 @@ gss_pipe_upcall(struct file *filp, struct rpc_pipe_msg *msg,
>  		char __user *dst, size_t buflen)
>  {
>  	char *data = (char *)msg->data + msg->copied;
> -	ssize_t mlen = msg->len;
> -	ssize_t left;
> +	size_t mlen = msg->len;
> +	unsigned long left;
>  
>  	if (mlen > buflen)
>  		mlen = buflen;
>  	left = copy_to_user(dst, data, mlen);
> -	if (left < 0) {
> -		msg->errno = left;
> -		return left;
> +	if (left == mlen) {
> +		msg->errno = -EFAULT;
> +		return -1;

NACK. This will end up returning -1 as the errno to a user read()
request.

Trond



-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
