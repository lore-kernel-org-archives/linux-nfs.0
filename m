From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 05/35] svc: Move sk_sendto and sk_recvfrom to	svc_xprt_class
Date: Tue, 02 Oct 2007 13:24:22 -0500
Message-ID: <1191349462.1565.46.camel@trinity.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192740.3250.73564.stgit@dell3.ogc.int>
	<CBDFC3B7-FE67-4715-87CA-E828D76844BB@oracle.com>
	<1191342596.1565.11.camel@trinity.ogc.int>
	<4A775179-9659-41B6-999F-8316BA181152@oracle.com>
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
	id 1IcmR8-0008VW-Dk
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 11:25:38 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IcmRB-0003AH-CR
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 11:25:43 -0700
In-Reply-To: <4A775179-9659-41B6-999F-8316BA181152@oracle.com>
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

On Tue, 2007-10-02 at 12:57 -0400, Chuck Lever wrote:
> On Oct 2, 2007, at 12:29 PM, Tom Tucker wrote:

[...snip...]

> >>
> >> It looks like on the client side, I didn't put the ops vector or the
> >> payload maximum in the class structure at all... 6 of one, half dozen
> >> of the other.  Using the class's value of the ops and payload maximum
> >> would save some space in the svc_xprt, though, come to think of it.
> >>
> >
> > cache thing again. let's see how Greg weighs in.
> 
> The ops vector itself will be in some other CPU's memory most of the  
> time on big systems. 

Well this is a good point. Unless we implement thread pools for svc_xprt
memory allocation, it won't likely buy you much.

>  I don't see how you can avoid a peek... but  
> since it's a constant, caching should protect you most of the time, yes?

> 
> Chuck Lever
> chuck.lever@oracle.com
> 
> 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
