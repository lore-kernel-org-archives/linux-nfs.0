From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 1/8] SUNRPC: Use unsigned string lengths
	in	xdr_decode_string_inplace
Date: Fri, 2 Nov 2007 10:21:12 +1100
Message-ID: <18218.24424.760975.221813@notabene.brown>
References: <20071101205647.5503.42569.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, nfs@lists.sourceforge.net,
	trond.myklebust@fys.uio.no
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1InjLh-0004jT-BO
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 16:21:17 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1InjLl-0003QM-Gz
	for nfs@lists.sourceforge.net; Thu, 01 Nov 2007 16:21:23 -0700
In-Reply-To: message from Chuck Lever on Thursday November 1
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


Thanks Chuck.
This series all:
   Acked-By: NeilBrown <neilb@suse.de>

Just one question:

> diff --git a/net/sunrpc/xdr.c b/net/sunrpc/xdr.c
> index fdc5e6d..31bd346 100644
> --- a/net/sunrpc/xdr.c
> +++ b/net/sunrpc/xdr.c
> @@ -93,11 +93,13 @@ xdr_encode_string(__be32 *p, const char *string)
>  }
>  
>  __be32 *
> -xdr_decode_string_inplace(__be32 *p, char **sp, int *lenp, int maxlen)
> +xdr_decode_string_inplace(__be32 *p, char **sp,
> +			  unsigned int *lenp, unsigned int maxlen)
>  {
> -	unsigned int	len;
> +	u32 len;

What is the reason for making this a u32?  You seem to be happy with
"unsigned int" everywhere else.

It's not important, but I'm curious.

NeilBrown

>  
> -	if ((len = ntohl(*p++)) > maxlen)
> +	len = ntohl(*p++);
> +	if (len > maxlen)
>  		return NULL;
>  	*lenp = len;
>  	*sp = (char *) p;

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
