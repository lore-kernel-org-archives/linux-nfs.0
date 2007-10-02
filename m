From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 05/35] svc: Move sk_sendto and	sk_recvfrom	to	svc_xprt_class
Date: Tue, 02 Oct 2007 15:38:55 -0500
Message-ID: <1191357535.1565.71.camel@trinity.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192740.3250.73564.stgit@dell3.ogc.int>
	<CBDFC3B7-FE67-4715-87CA-E828D76844BB@oracle.com>
	<1191342596.1565.11.camel@trinity.ogc.int>
	<4A775179-9659-41B6-999F-8316BA181152@oracle.com>
	<1191349462.1565.46.camel@trinity.ogc.int>
	<1191349842.1565.54.camel@trinity.ogc.int>
	<7FF82697-AB93-4339-AD46-CAE93E967242@oracle.com>
	<1191354906.1565.65.camel@trinity.ogc.int>
	<35565992-BEA8-41BA-A25E-723CC18FF628@oracle.com>
	<1191357310.1565.68.camel@trinity.ogc.int>
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
	id 1IcoXL-0006Il-74
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 13:40:12 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IcoXO-00078T-65
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 13:40:16 -0700
In-Reply-To: <1191357310.1565.68.camel@trinity.ogc.int>
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

On Tue, 2007-10-02 at 15:35 -0500, Tom Tucker wrote:
> On Tue, 2007-10-02 at 16:29 -0400, Chuck Lever wrote:

[...snip...]

> I agree too. So unless anyone objects, I'm going to change the the
> svc_xprt structure to have a pointer to the svc_xprt_ops structure, and
> the svc_max_payload will be accessed from the svc_xprt_class structure.
> 
> The ptr to the svc_xprt_ops structure is to avoid one ptr indirection
> when accessing ops (done quite a bit).

BTW, this reminds me, the current implementation avoids one ptr
indirection when calling ops as follows:

xrpt->ops.op 

if we change it, it will be

xprt->ops_ptr->ops.op


> > 
> > >> In other words, on each request, you will need to get the address of
> > >> the vector from dynamically allocated memory, but the vector itself
> > >> (and therefore the addresses of the transport methods) will be fixed
> > >> and in the boot CPU's memory pool.
> > 
> > --
> > Chuck Lever
> > chuck[dot]lever[at]oracle[dot]com
> > 
> > 
> 
> 
> -------------------------------------------------------------------------
> This SF.net email is sponsored by: Microsoft
> Defy all challenges. Microsoft(R) Visual Studio 2005.
> http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
