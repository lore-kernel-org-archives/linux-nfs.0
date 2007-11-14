From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Use of delayed request information in nlmsvc_lookup_host
Date: Wed, 14 Nov 2007 13:43:18 -0500
Message-ID: <1195065798.7584.37.camel@heimdal.trondhjem.org>
References: <473B3D0B.3060204@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: chuck.lever@oracle.com
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IsNCw-0003rJ-Ow
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 10:43:26 -0800
Received: from pat.uio.no ([129.240.10.15])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IsND1-0004zp-Cv
	for nfs@lists.sourceforge.net; Wed, 14 Nov 2007 10:43:32 -0800
In-Reply-To: <473B3D0B.3060204@oracle.com>
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


On Wed, 2007-11-14 at 13:23 -0500, Chuck Lever wrote:
> Hi-
> 
> Historical question here.
> 
> nlmsvc_lookup_host() has this:
> 
> struct nlm_host *
> nlmsvc_lookup_host(struct svc_rqst *rqstp,
>                          const char *hostname, unsigned int hostname_len)
> {
>          struct sockaddr_in ssin = {0};
> 
>  >>>     ssin.sin_addr = rqstp->rq_daddr.addr;
>          return nlm_lookup_host(1, svc_addr_in(rqstp),
>                                 rqstp->rq_prot, rqstp->rq_vers,
>                                 hostname, hostname_len, &ssin);
> }
> 
> Why is it using rq_daddr to construct the lookup target?
> 
> The problem here is that rq_daddr isn't a full address.  It doesn't have 
> address family information.  So nlmsvc_lookup_host() just assumes that 
> what's stored in rq_daddr is always AF_INET.

Why can't rq_daddr hold address family information? AFAICS there is
nothing stopping you from setting that in svc_recvfrom() and in
svc_udp_get_dest_address().

In fact, why isn't rq_daddr defined to be a sockaddr_storage so that it
can be safely cast into either a sockaddr_in or a sockaddr_in6 after
checking the ss_family field?

Cheers
  Trond


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
