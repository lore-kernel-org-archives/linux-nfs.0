From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC PATCH 1/3] NLM lock failover - lock release
Date: Fri, 30 Jun 2006 14:15:08 +1000
Message-ID: <17572.42316.253063.636685@cse.unsw.edu.au>
References: <44A417E7.5090500@redhat.com>
	<1151622397.6405.5.camel@lade.trondhjem.org>
	<1151639830.5642.23.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, Lon Hohberger <lhh@redhat.com>,
	nfs@lists.sourceforge.net,
	Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1FwAPe-0004c8-KV
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 21:15:26 -0700
Received: from ns2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1FwAPd-0001LP-I8
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 21:15:26 -0700
To: Wendy Cheng <wcheng@redhat.com>
In-Reply-To: message from Wendy Cheng on Thursday June 29
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

On Thursday June 29, wcheng@redhat.com wrote:
> On Thu, 2006-06-29 at 19:06 -0400, Trond Myklebust wrote:
> 
> > >  
> > > +	/* add server ip for nlm lock failover */
> > > +	sock->ops->getname(sock, (struct sockaddr *)&daddr, &alen, 0);
> > > +	rqstp->rq_daddr = daddr.sin_addr.s_addr;
> > > +
> > 
> > Hmm.... Why would you want to do this on every receive when you could
> > just store the ip address in the struct svc_sock once and for all?
> 
> ok, will do that - save latency. Thanks.
> 
> > 
> > That said, how do you envisage this working in the cases where the
> > socket is bound to INADDR_ANY?
> 
> This is "our" (server's) address, not peer address - for this request to
> arrive "here", it can't be INADDR_ANY. Can it ? Remember "rq_daddr" will
> only be used during failover in a clustered NFS servers environment. 

The socket can only be bound to INADDR_ANY for UDP, and in that case
we already set rq_daddr correctly.

For a TCP socket, it will be connected, so the local an remote
endpoints will be well defined.

So the code as it stands should work fine.

But yes, it would be best to record the local and remote addresses in
svc_tcp_accept rather than called ->getname twice in svc_recvfrom.

NeilBrown

Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
