From: Greg Banks <gnb@sgi.com>
Subject: Re: [PATCH] knfsd: remove unnecessary BUG_ON's
Date: Sat, 15 Sep 2007 02:58:01 +1000
Message-ID: <20070914165801.GJ25610@sgi.com>
References: <20070912234317.GF13792@fieldses.org>
	<20070914164058.GK21965@sgi.com>
	<20070914165013.GE26622@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IWEUA-0001AB-SD
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 09:57:42 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1IWEUF-0008TT-JO
	for nfs@lists.sourceforge.net; Fri, 14 Sep 2007 09:57:47 -0700
In-Reply-To: <20070914165013.GE26622@fieldses.org>
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

On Fri, Sep 14, 2007 at 12:50:13PM -0400, J. Bruce Fields wrote:
> On Sat, Sep 15, 2007 at 02:40:58AM +1000, Greg Banks wrote:
> > On Wed, Sep 12, 2007 at 07:43:17PM -0400, J. Bruce Fields wrote:
> > > Trivial patch, but--any objection to removing these assertions?
> > > 
> > > We set svsk->sk_pool = pool just 30-some lines above, and there's no
> > > obvious reason this should have changed, or any other particular reason
> > > to assert this here.
> > 
> > Yeah, you'd think that.  However we saw these BUG_ON()s tripped
> > when attempting to port the 2.6.18-based NFS/RDMA patches to a
> > 2.6.19-like kernel.  All it takes is for some transport code to get
> > confused about the proper way to clear SK_BUSY, and *blam*.  So I
> > think they're useful.
> 
> OK, I'll take your word for it--dropped.  (But, I'm just curious--do you
> remember what the sequence of events was?)

It's been a while, but IIRC the new transport code had copied out the
internals of svc_request_received() pre .19, and were manually clearing
SK_BUSY and calling svc_sock_enqueue().  In .19 when sk_pool was added,
svc_request_received() began setting sk_pool to NULL, and the transport
code wasn't doing that.  Or maybe that was a different failure mode ;-)

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
