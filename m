From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 15/23] mount.nfs: clean up getport() function
Date: Sun, 29 Jul 2007 19:43:33 -0400
Message-ID: <20070729234333.GA18686@fieldses.org>
References: <20070728215024.21871.54208.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IFIQC-00089a-FZ
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 16:43:36 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IFIQF-0001lk-8Y
	for nfs@lists.sourceforge.net; Sun, 29 Jul 2007 16:43:40 -0700
In-Reply-To: <20070728215024.21871.54208.stgit@localhost.localdomain>
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

On Sat, Jul 28, 2007 at 05:50:24PM -0400, Chuck Lever wrote:
> Mostly comment clarification.  Also replace some naked undocumented
> integers with macros, and make getport() static.
> @@ -153,25 +157,30 @@ unsigned short getport(struct sockaddr_in *saddr, unsigned long prog,
>  		return 0;
>  	}
>  
> -	switch (prot) {
> +	switch (proto) {
>  	case IPPROTO_UDP:
>  		clnt = clntudp_bufcreate(saddr,
> -					 PMAPPROG, PMAPVERS, TIMEOUT, &socket,
> -					 UDPMSGSIZE, UDPMSGSIZE);
> +					 PMAPPROG, PMAPVERS,
> +					 RETRY_TIMEOUT, &socket,
> +					 RPCSMALLMSGSIZE,
> +					 RPCSMALLMSGSIZE);
>  		break;
>  	case IPPROTO_TCP:
> -		clnt = clnttcp_create(saddr,
> -			PMAPPROG, PMAPVERS, &socket, 50, 500);
> +		clnt = clnttcp_create(saddr, PMAPPROG, PMAPVERS, &socket,
> +				      RPCSMALLMSGSIZE, RPCSMALLMSGSIZE);

Did you mean to change those final two arguments?  (They were different
before, then they're the same after.)

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
