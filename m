From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Use of delayed request information in nlmsvc_lookup_host
Date: Thu, 15 Nov 2007 12:37:42 -0500
Message-ID: <1195148262.7673.11.camel@heimdal.trondhjem.org>
References: <473B3D0B.3060204@oracle.com>
	<1195065798.7584.37.camel@heimdal.trondhjem.org>
	<473B45C9.4060708@oracle.com>
	<1195069262.7584.54.camel@heimdal.trondhjem.org>
	<473B5278.7090408@oracle.com>
	<18235.41907.383911.722103@notabene.brown>
	<473C4FE2.1090402@oracle.com>
	<1195142050.7506.13.camel@heimdal.trondhjem.org>
	<473C80A2.1020204@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Isiez-0006GK-Qb
	for nfs@lists.sourceforge.net; Thu, 15 Nov 2007 09:37:51 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Isif4-0003kx-E1
	for nfs@lists.sourceforge.net; Thu, 15 Nov 2007 09:37:55 -0800
In-Reply-To: <473C80A2.1020204@oracle.com>
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


On Thu, 2007-11-15 at 12:23 -0500, Chuck Lever wrote:
> Trond Myklebust wrote:
> > On Thu, 2007-11-15 at 08:55 -0500, Chuck Lever wrote:
> > 
> >> What do you think of changing the rq_daddr field to be a sockaddr_storage?
> > 
> > Why? You've already got rq_addr.
> 
> OK, here's what I've ended up with.  I think this is what you and Neil 
> have been suggesting.  Comments?
> 
> /*
>   * Find an NLM client handle in the cache. If there is none, create it.
>   *
>   * Manufacture a specific source address in case we're using multiple
>   * IP addresses on a single NIC.  NB: the family of the address in
>   * rq_daddr is guaranteed to be the same as the family of rq_addr.
>   */
> struct nlm_host *
> nlmsvc_lookup_host(struct svc_rqst *rqstp,
> 			const char *hostname, unsigned int hostname_len)
> {
> 	struct sockaddr_in6 source = {
> 		.sin6_family	= AF_INET6,
> 	};
> 
> 	switch(svc_addr(rqstp)->sa_family) {
> 	case AF_INET: {
> 		struct sockaddr_in *sin = (struct sockaddr_in *)&source;
> 		sin->sin_family = AF_INET;
> 		sin->sin_addr.s_addr = rqstp->rq_daddr.addr.s_addr;
> 		break;
> 	}
> 	case AF_INET6:
> 		ipv6_addr_copy(&source.sin6_addr,
>                                 &rqstp->rq_daddr.addr6);
> 		break;
> 	}
> 
> 	return nlm_lookup_host(1, svc_addr_in(rqstp),
> 			       rqstp->rq_prot, rqstp->rq_vers,
> 			       hostname, hostname_len,
> 			       (struct sockaddr *)&source);
> }

That works for me. Technically, I suppose we should really pass a
source_len to nlm_lookup_host() if only to ensure that the comparisons
don't overrun memory, however in practice I doubt this is a problem. We
always know that the kernel allocates enough space.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
