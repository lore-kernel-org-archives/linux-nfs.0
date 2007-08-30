From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] mount.nfs: restore admin-specified
	clientaddr	option
Date: Thu, 30 Aug 2007 14:54:50 -0400
Message-ID: <1188500090.7891.8.camel@gaula.trondhjem.org>
References: <20070830174620.3799.1497.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IQpHv-0004Tv-Bh
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 12:02:43 -0700
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IQpHz-0007OM-8U
	for nfs@lists.sourceforge.net; Thu, 30 Aug 2007 12:02:47 -0700
In-Reply-To: <20070830174620.3799.1497.stgit@monet.1015granger.net>
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

clientaddr= MUST be allowed, damnit! Who the hell tried to disable it?

'clientaddr' was set up because there is no way for the kernel (or an
automated userland mount program) to determine exactly which IP address
the server should be using for callbacks in the case where there are
more than 1 options.
That all depends on the local network topology, and routing policies,
which may not be visible to the client.

Trond

On Thu, 2007-08-30 at 13:46 -0400, Chuck Lever wrote:
> Revert an earlier change to make specifying the clientaddr= option illegal.
> 
> Jeff Layton pointed out that admins may want to specify the clientaddr=
> option to advertise a different callback address when accessing an NFSv4
> server through a NAT router.
> 
> Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
> ---
> 
>  utils/mount/stropts.c |   11 ++++-------
>  1 files changed, 4 insertions(+), 7 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 12f6423..236a3b4 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -201,7 +201,9 @@ static int append_addr_opt(struct sockaddr_in *saddr, char **extra_opts)
>  }
>  
>  /*
> - * Append the 'clientaddr=' option to the options string.
> + * Called if no 'clientaddr=' option was specified in the options string
> + * to discover our address and append an appropriate 'clientaddr=' option
> + * to the options string.
>   *
>   * Returns 1 if 'clientaddr=' option created successfully;
>   * otherwise zero.
> @@ -319,15 +321,10 @@ int nfs4mount_s(const char *spec, const char *node, int flags,
>  		return EX_FAIL;
>  	}
>  
> -	if (ca_opt) {
> -		nfs_error(_("%s: Illegal option: 'clientaddr='"), progname);
> -		return EX_FAIL;
> -	}
> -
>  	if (!append_addr_opt(&saddr, extra_opts))
>  		return EX_FAIL;
>  
> -	if (!append_clientaddr_opt(&saddr, extra_opts))
> +	if (!ca_opt && !append_clientaddr_opt(&saddr, extra_opts))
>  		return EX_FAIL;
>  
>  	if (verbose)
> 
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Splunk Inc.
> Still grepping through log files to find problems?  Stop.
> Now Search log events and configuration files using AJAX and a browser.
> Download your FREE copy of Splunk now >>  http://get.splunk.com/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
