From: Wendy Cheng <wcheng@redhat.com>
Subject: Re: [RFC PATCH 1/3] NLM lock failover - lock release
Date: Thu, 29 Jun 2006 23:57:10 -0400
Message-ID: <1151639830.5642.23.camel@localhost.localdomain>
References: <44A417E7.5090500@redhat.com>
	<1151622397.6405.5.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: cluster-devel@redhat.com, Lon Hohberger <lhh@redhat.com>,
	nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Fw9xV-00028t-Va
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 20:46:22 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Fw9xV-0005H0-UV
	for nfs@lists.sourceforge.net; Thu, 29 Jun 2006 20:46:22 -0700
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1151622397.6405.5.camel@lade.trondhjem.org>
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

On Thu, 2006-06-29 at 19:06 -0400, Trond Myklebust wrote:

> >  
> > +	/* add server ip for nlm lock failover */
> > +	sock->ops->getname(sock, (struct sockaddr *)&daddr, &alen, 0);
> > +	rqstp->rq_daddr = daddr.sin_addr.s_addr;
> > +
> 
> Hmm.... Why would you want to do this on every receive when you could
> just store the ip address in the struct svc_sock once and for all?

ok, will do that - save latency. Thanks.

> 
> That said, how do you envisage this working in the cases where the
> socket is bound to INADDR_ANY?

This is "our" (server's) address, not peer address - for this request to
arrive "here", it can't be INADDR_ANY. Can it ? Remember "rq_daddr" will
only be used during failover in a clustered NFS servers environment. 


-- Wendy




Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
