From: Neil Brown <neilb@suse.de>
Subject: Re: [PATCH 05/12] SUNRPC: Add a function to format the
	address in an svc_rqst for printing
Date: Thu, 9 Nov 2006 14:44:50 +1100
Message-ID: <17746.42034.768127.846582@cse.unsw.edu.au>
References: <20061101180830.14581.18323.stgit@schiele.dsl.sfldmi.ameritech.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Gi0qT-0005qd-SF
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 19:44:53 -0800
Received: from ns.suse.de ([195.135.220.2] helo=mx1.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Gi0qT-00072z-Hg
	for nfs@lists.sourceforge.net; Wed, 08 Nov 2006 19:44:55 -0800
To: Chuck Lever <chucklever@gmail.com>
In-Reply-To: message from Chuck Lever on Wednesday November 1
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wednesday November 1, chuck.lever@oracle.com wrote:
>  		long timeout = MAX_SCHEDULE_TIMEOUT;
> +		char buf[RPC_MAX_ADDRBUFLEN];
>  
>  		if (signalled()) {
>  			flush_signals(current);
> @@ -175,11 +176,10 @@ lockd(struct svc_rqst *rqstp)
>  			break;
>  		}
>  
> -		dprintk("lockd: request from %08x\n",
> -			(unsigned)ntohl(rqstp->rq_addr.sin_addr.s_addr));
> +		svc_print_addr(rqstp, buf, sizeof(buf));
> +		dprintk("lockd: request from %s\n", buf);
>  
....
> +/**
> + * svc_print_addr - Format rq_addr field for printing
> + * @rqstp: svc_rqst struct containing address to print
> + * @buf: target buffer for formatted address
> + * @len: length of target buffer
> + *
> + */
> +void svc_print_addr(struct svc_rqst *rqstp, char *buf, size_t len)
> +{
> +	__svc_print_addr((struct sockaddr *) &rqstp->rq_addr, buf, len);
> +
> +}

Can we have svc_print_addr take a 
  char buf[RPC_MAX_ADDRBUFLEN]
rather than a char* and a len?  The buffer is always the same size, so
best to hard code it..

Also can svc_print_addr return a 'char *' being 'buf'.
Then we can

> +		dprintk("lockd: request from %s\n",
> +			svc_print_addr(rqstp, buf));

This makes it less verbose and similar to bdevname().

Thanks,
NeilBrown

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
