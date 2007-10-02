From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 11/35] svc: Add xpo_accept transport function
Date: Tue, 02 Oct 2007 13:28:54 -0500
Message-ID: <1191349734.1565.52.camel@trinity.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192753.3250.94322.stgit@dell3.ogc.int>
	<EECEF6FF-4C84-4764-BF0B-383AA870AFDD@oracle.com>
	<1191343305.1565.24.camel@trinity.ogc.int>
	<325D6316-382E-45F5-BBB8-4BE40A637C53@oracle.com>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcmVU-0000ar-5M
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 11:30:08 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IcmVZ-0004at-3l
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 11:30:13 -0700
In-Reply-To: <325D6316-382E-45F5-BBB8-4BE40A637C53@oracle.com>
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

On Tue, 2007-10-02 at 13:07 -0400, Chuck Lever wrote:
> On Oct 2, 2007, at 12:41 PM, Tom Tucker wrote:
> > On Tue, 2007-10-02 at 11:33 -0400, Chuck Lever wrote:
> >> On Oct 1, 2007, at 3:27 PM, Tom Tucker wrote:
> >
> > [...snip...]
> >
> >>> +		if (newxpt)
> >>> +			svc_check_conn_limits(svsk->sk_server);
> >>> +		svc_sock_received(svsk);
> >>>  	} else {
> >>>  		dprintk("svc: server %p, pool %u, socket %p, inuse=%d\n",
> >>>  			rqstp, pool->sp_id, svsk, atomic_read(&svsk->sk_inuse));
> >>
> >> Instead of adding a test_bit() and conditional branch here, why not
> >> always call xpo_accept?  For UDP, the method simply returns.
> >>
> >
> > That's what I thought at first too, but UDP needs to call receive  
> > here.
> > Doing nothing stalls the service and lockd never gets set up.
> 
> The purpose of a transport switch is to force all the transport  
> specific processing down into the transport implementation so you  
> don't need these SK_ switches to decide whether or not to call a  
> function based on which transport is in use.

I don't think it's doing that. I think it's checking the "role" of the
instance; passive vs. active endpoint. The role is transport independent
and is checked in the generic svc_recv function.

> 
> Could you instead create, say, an ->xpo_accept_and_receive hook that  
> did the right thing for all three transports?

You could, but IMO doing so just neuters the meaning of the
XPT_LISTENING bit for peer-to-peer transports.

> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
