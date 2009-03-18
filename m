From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 03/40] SUNRPC: Clean up svc_find_xprt() calling sequence
Date: Wed, 18 Mar 2009 18:34:09 -0400
Message-ID: <20090318223409.GG18894@fieldses.org>
References: <20090312155609.16019.86499.stgit@ingres.1015granger.net> <20090312160721.16019.89653.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: trond.myklebust@fys.uio.no, linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:38493 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752030AbZCRWeN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Mar 2009 18:34:13 -0400
In-Reply-To: <20090312160721.16019.89653.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 12, 2009 at 12:07:21PM -0400, Chuck Lever wrote:
> Clean up: add documentating comment and use appropriate data types for
> svc_find_xprt()'s arguments.
> 
> This also eliminates a mixed sign comparison: @port was an int, while
> the return value of svc_xprt_local_port() is an unsigned short.

OK.  Applied, though:

> @@ -1042,14 +1048,14 @@ static struct svc_deferred_req *svc_deferred_dequeue(struct svc_xprt *xprt)
>   * wild-card, and will result in matching the first transport in the
>   * service's list that has a matching class name.
>   */
> -struct svc_xprt *svc_find_xprt(struct svc_serv *serv, char *xcl_name,
> -			       int af, int port)
> +struct svc_xprt *svc_find_xprt(struct svc_serv *serv, const char *xcl_name,
> +			       const sa_family_t af, const unsigned short port)
>  {
>  	struct svc_xprt *xprt;
>  	struct svc_xprt *found = NULL;
>  
>  	/* Sanity check the args */
> -	if (!serv || !xcl_name)
> +	if (serv == NULL || xcl_name == NULL)
>  		return found;

Maybe that's better, maybe not, I don't know, but: let's make allowances
for *some* variation in individual style.

Applying as-is, but in future, I'd rather that level of decision be left
to the preferences of whoever wrote the code.

--b.
