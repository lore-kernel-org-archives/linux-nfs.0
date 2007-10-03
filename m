From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 13/35] svc: Change services to use new	svc_create_xprt service
Date: Wed, 03 Oct 2007 11:23:47 -0500
Message-ID: <1191428627.1565.121.camel@trinity.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192758.3250.2651.stgit@dell3.ogc.int>
	<608B3480-525A-43C6-945C-3482CDE823FC@oracle.com>
	<1191343505.1565.28.camel@trinity.ogc.int>
	<D376113E-3F59-4E3D-BE3D-AE778647BD0E@oracle.com>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id720-0005Lp-2c
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 09:25:04 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Id724-0001xP-2i
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 09:25:09 -0700
In-Reply-To: <D376113E-3F59-4E3D-BE3D-AE778647BD0E@oracle.com>
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

On Wed, 2007-10-03 at 11:25 -0400, Chuck Lever wrote:
> On Oct 2, 2007, at 12:45 PM, Tom Tucker wrote:
[...snip...]
> >> First, I think we would be better off making the server transport API
> >> stronger by not allowing ULPs to dig around in svc_xprt or the
> >> svc_xprt_class structures directly.  Perhaps you could provide a
> >> method for obtaining the transport's NETID.
> >
> > I'll propose a service. NETID or simply protocol/port? What's the
> > consensus?
> 
> I think NETID is all that is needed here.
> 
> You might consider moving the whole function into the RPC server to  
> make this even cleaner.  The fact that this facility is planted  
> squarely in lockd is a bit of a layering violation to begin with.

Agreed. Thanks,
Tom

> 
> --
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
