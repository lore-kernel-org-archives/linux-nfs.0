From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,
	PATCH 04/35] svc: Add a max payload value to the transport
Date: Wed, 3 Oct 2007 21:09:32 +1000
Message-ID: <20071003110932.GN21388@sgi.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192738.3250.6971.stgit@dell3.ogc.int>
	<8E01CAF1-5D8D-4AE5-B15D-C04983079F76@oracle.com>
	<1191342488.1565.8.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id224-0007Ip-Ly
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 04:04:48 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1+qBb1Z1Di69jKLURJqwijoVd9QVJvrHLw=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Id228-00064Z-Kc
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 04:04:53 -0700
In-Reply-To: <1191342488.1565.8.camel@trinity.ogc.int>
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

On Tue, Oct 02, 2007 at 11:28:08AM -0500, Tom Tucker wrote:
> On Tue, 2007-10-02 at 10:54 -0400, Chuck Lever wrote:
> > On Oct 1, 2007, at 3:27 PM, Tom Tucker wrote:
> > >
> 
> [...snip...]
> 
> > >
> > >  struct svc_xprt {
> > >  	struct svc_xprt_class	*xpt_class;
> > >  	struct svc_xprt_ops	xpt_ops;
> > > +	u32			xpt_max_payload;
> > >  };
> > 
> > Why do you need this field in both the class and the instance  
> > structures?  Since svc_xprt refers back to svc_xprt_class, you can  
> > just take the max payload value from the class.
> > 
> 
> The premise was that I didn't want a given thread peeking into some
> other processors memory, so anything needed from the class is copied
> into the svc_xprt structure when the transport instance is created.

If I understand the code correctly, the only field in svc_xprt_class
that ever changes is the list_head used to add it to the global list,
which changes once when the transport module is loaded.  After that
all the svc_xprt_class cachelines will remain in shared state in all
CPUs' caches; it's effectively read-only.  Given that, there's little
to be concerned about.

> 
> Greg, help me here ;-)

Sorry, I agree with Chuck :-/

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
