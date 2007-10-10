From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,
	PATCH] svc: Modify svc_create_xprt to return local port
Date: Wed, 10 Oct 2007 12:35:40 +1000
Message-ID: <20071010023540.GB20690@sgi.com>
References: <20071009225253.25816.36183.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfRHr-0004ob-P0
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 19:27:03 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1IfRHw-0003n0-TK
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 19:27:09 -0700
In-Reply-To: <20071009225253.25816.36183.stgit@dell3.ogc.int>
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

On Tue, Oct 09, 2007 at 05:52:53PM -0500, Tom Tucker wrote:
> 
> Please take this version of the patch. The previous version has a
> whitespace issue. Sorry for the inconvenience.
> 
> This patch fixes a regression introduced by the svc transport
> switch as follows:
> 
> - Listening endpoints need to have their local address set properly. 
> 
> - svc_create_xprt needs to return the local port number since the
>   the nfs4 callback service uses the return value to determine the 
>   local port elected by the transport when binding to zero.
> 
> [...]
> --- a/net/sunrpc/svcsock.c
> +++ b/net/sunrpc/svcsock.c
> @@ -1278,6 +1278,8 @@ svc_create_socket(struct svc_serv *serv,
>  	int		error;
>  	int		type;
>  	char		buf[RPC_MAX_ADDRBUFLEN];
> +	struct sockaddr	newsin;
> +	int		newlen;

Struct sockaddr isn't big enough for this to work with ipv6,
use struct sockaddr_storage.  Or do the kernel_getsockname()
driectly into xprt->xpt_local.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
