From: "Labiaga, Ricardo" <Ricardo.Labiaga@netapp.com>
Subject: RE: [PATCH RFC 02/10] nfsd41: sunrpc: Added rpc server-sidebackchannel handling
Date: Mon, 24 Aug 2009 17:05:42 -0700
Message-ID: <273FE88A07F5D445824060902F7003440738D4D8@SACMVEXC1-PRD.hq.netapp.com>
References: <20090824233419.GE8532@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>, <pnfs@linux-nfs.org>,
	"Iyer, Rahul" <Rahul.Iyer@netapp.com>,
	"Sager, Mike" <Mike.Sager@netapp.com>,
	"Marc Eshel" <eshel@almaden.ibm.com>,
	"Adamson, Andy" <William.Adamson@netapp.com>,
	"Batsakis, Alexandros" <Alexandros.Batsakis@netapp.com>,
	"Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
	"Benny Halevy" <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:21050 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753844AbZHYAJT convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Aug 2009 20:09:19 -0400
In-Reply-To: <20090824233419.GE8532@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org]
> Sent: Monday, August 24, 2009 4:34 PM
> 
> What are you using to test the backchannel?
> 

We use delegation recalls to test the backchannel.

> >  		break;
> >  	case AF_INET6:
> >  		if (((struct sockaddr_in6 *)addr)->sin6_port !=
htons(0))
> >  			xprt_set_bound(xprt);
> >
> >  		INIT_DELAYED_WORK(&transport->connect_worker,
> xs_tcp_connect_worker6);
> > -		xs_format_ipv6_peer_addresses(xprt, "tcp",
RPCBIND_NETID_TCP6);
> > +		xs_format_ipv6_peer_addresses(xprt, "tcp",
> > +					      RPCBIND_NETID_TCP);
> 
> Is the TCP->TCP6 change a typo?
> 

Yes, thanks for catching this.  Will be fixed when the synchronization
problem is addressed.

- ricardo

