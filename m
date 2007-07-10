From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [RFC,
	PATCH 20/20] knfsd: create listener via portlist	write
Date: Tue, 10 Jul 2007 19:36:46 -0400
Message-ID: <1184110606.6480.44.camel@heimdal.trondhjem.org>
References: <20070710052711.28979.70843.stgit@dell3.ogc.int>
	<20070710053502.28979.32613.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I8PGF-0001jz-NO
	for nfs@lists.sourceforge.net; Tue, 10 Jul 2007 16:36:51 -0700
Received: from pat.uio.no ([129.240.10.15]
	ident=[U2FsdGVkX1+phtvKZ1/YY9mO+/5+3M3/+ZfR7fZ7QRg=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1I8PGG-0000Ef-RR
	for nfs@lists.sourceforge.net; Tue, 10 Jul 2007 16:36:55 -0700
In-Reply-To: <20070710053502.28979.32613.stgit@dell3.ogc.int>
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

On Tue, 2007-07-10 at 00:35 -0500, Tom Tucker wrote:
> Update the write handler for the portlist file to allow creating new 
> listening endpoints on a transport. The general form of the string is:
> 
> <transport_name><space><port number>
> 
> For example:
> 
> tcp 2049
> 
> This is intended to support the creation of a listening endpoint for
> RDMA transports without adding #ifdef code to the nfssvc.c file.
> The "built-in" transports UDP/TCP were left in the nfssvc initialization
> code to avoid having to change rpc.nfsd, etc...
> 
> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
> ---
> 
>  fs/nfsd/nfsctl.c |   16 ++++++++++++++++
>  1 files changed, 16 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 71c686d..b72514d 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -555,6 +555,22 @@ static ssize_t write_ports(struct file *
>  		kfree(toclose);
>  		return len;
>  	}
> +	/* This implements the ability to add a transport by writing
> +	 * it's transport name to the portlist file
> +	 */
> +	if (isalnum(buf[0])) {
> +		int err;
> +		char transport[16];
> +		int port;
> +		sscanf(buf, "%15s %4d", transport, &port);

Hmm... This looks dodgy to me. You are not initialising transport and
port nor even checking the return value of sscanf()?

> +		err = nfsd_create_serv();
> +		if (!err)
> +			err = svc_create_svcsock(nfsd_serv,
> +						 transport, port,
> +						 SVC_SOCK_ANONYMOUS);
> +		return err < 0 ? err : 0;
> +	}
> +	
>  	return -EINVAL;
>  }
>  
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by DB2 Express
> Download DB2 Express C - the FREE version of DB2 express and take
> control of your XML. No limits. Just data. Click to get it now.
> http://sourceforge.net/powerbar/db2/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
