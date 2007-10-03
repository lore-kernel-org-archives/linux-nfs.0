From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,
	PATCH 05/35] svc: Move sk_sendto and sk_recvfrom to svc_xprt_class
Date: Wed, 3 Oct 2007 21:13:25 +1000
Message-ID: <20071003111325.GO21388@sgi.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192740.3250.73564.stgit@dell3.ogc.int>
	<CBDFC3B7-FE67-4715-87CA-E828D76844BB@oracle.com>
	<1191342596.1565.11.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id25n-0007k8-As
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 04:08:41 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1+93nfFg4IuFsRzAb/7ynxlYa8Hfx1Ew5o=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Id25s-0007YS-8b
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 04:08:44 -0700
In-Reply-To: <1191342596.1565.11.camel@trinity.ogc.int>
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

On Tue, Oct 02, 2007 at 11:29:56AM -0500, Tom Tucker wrote:
> On Tue, 2007-10-02 at 11:04 -0400, Chuck Lever wrote:
> > On Oct 1, 2007, at 3:27 PM, Tom Tucker wrote:
> > Again, here you have copied a pointer from the class structure to the  
> > instance structure -- the address of the transport ops structure  
> > never changes during the lifetime of the xprt instance, does it?  You  
> > could just as easily use the class's ops pointer instead.
> > 
> > It looks like on the client side, I didn't put the ops vector or the  
> > payload maximum in the class structure at all... 6 of one, half dozen  
> > of the other.  Using the class's value of the ops and payload maximum  
> > would save some space in the svc_xprt, though, come to think of it.
> > 
> 
> cache thing again. let's see how Greg weighs in.

What Chuck said.

> > Also, to address Neil's concern about the appearance of the  
> > expression which dereferences these methods, why not use a macro,  
> > similar to VOP_GETATTR() in the old BSD kernels, that replaces this  
> > long chain of indirections with a simple to recognize macro call?
> > 
> 
> The chain is disgusting until everything gets normalized to an svc_xprt
> in later patches. Take a look at the final result and see if you still
> think a macro helps vs. just obscures.

I agree with Tom here, the final result is less sickening
than some of the intermediate stages.  Like sausage.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
