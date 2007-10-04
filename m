From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 11/35] svc: Add xpo_accept transport function
Date: Thu, 4 Oct 2007 11:54:48 +1000
Message-ID: <20071004015448.GT21388@sgi.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192753.3250.94322.stgit@dell3.ogc.int>
	<EECEF6FF-4C84-4764-BF0B-383AA870AFDD@oracle.com>
	<1191343305.1565.24.camel@trinity.ogc.int>
	<325D6316-382E-45F5-BBB8-4BE40A637C53@oracle.com>
	<1191349734.1565.52.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdFqR-0003Tw-MQ
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 18:49:43 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1IdFqT-0003bq-JV
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 18:49:46 -0700
In-Reply-To: <1191349734.1565.52.camel@trinity.ogc.int>
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

On Tue, Oct 02, 2007 at 01:28:54PM -0500, Tom Tucker wrote:
> On Tue, 2007-10-02 at 13:07 -0400, Chuck Lever wrote:
> > On Oct 2, 2007, at 12:41 PM, Tom Tucker wrote:
> > > On Tue, 2007-10-02 at 11:33 -0400, Chuck Lever wrote:
> > >> On Oct 1, 2007, at 3:27 PM, Tom Tucker wrote:
> > >
> > > [...snip...]
> > >
> > >>> +		if (newxpt)
> > >>> +			svc_check_conn_limits(svsk->sk_server);
> > >>> +		svc_sock_received(svsk);
> > >>>  	} else {
> > >>>  		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
> > >>>  			rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
> > >>
> > >> Instead of adding a test_bit() and conditional branch here, why not
> > >> always call xpo_accept?  For UDP, the method simply returns.
> > >>
> > >
> > > That's what I thought at first too, but UDP needs to call receive  
> > > here.
> > > Doing nothing stalls the service and lockd never gets set up.
> > 
> > The purpose of a transport switch is to force all the transport  
> > specific processing down into the transport implementation so you  
> > don't need these SK_ switches to decide whether or not to call a  
> > function based on which transport is in use.
> 
> I don't think it's doing that. I think it's checking the "role" of the
> instance; passive vs. active endpoint. The role is transport independent
> and is checked in the generic svc_recv function.

Yes, this is generic functionality that any connection-oriented
transport needs.  Two of the three transports we have use xpo_accept.

Fundamentally, the transport-independent core needs to be aware of the
difference between connectionless and connection-oriented transports.
It needs to do several special things for the latter.  Examples
include enforcing a connection limit, and caching client-related data
on the connection.

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
