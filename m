From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 14/35] svc: Change sk_inuse to a kref
Date: Thu, 4 Oct 2007 12:51:27 +1000
Message-ID: <20071004025127.GW21388@sgi.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192801.3250.49751.stgit@dell3.ogc.int>
	<20071003111210.GA19381@infradead.org>
	<20071003144517.GA10001@fieldses.org>
	<20071003145238.GA30564@infradead.org>
	<50751C78-DD55-4549-A03E-2DFBBEF7AED3@oracle.com>
	<20071003153401.GD10001@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, neilb@suse.de,
	nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdGjH-0000L3-KK
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 19:46:24 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX18bJ+kbpkRdBR9j/esOZy1NYGmjok57nRk=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IdGjL-0006N4-Kw
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 19:46:28 -0700
In-Reply-To: <20071003153401.GD10001@fieldses.org>
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

On Wed, Oct 03, 2007 at 11:34:01AM -0400, J. Bruce Fields wrote:
> On Wed, Oct 03, 2007 at 11:13:58AM -0400, Chuck Lever wrote:
> > We're using krefs without issue in several other areas of the RPC client 
> > and server.  Both rpc_clnt and rpc_xprt have a kref in them, for example.  
> > I don't see the harm in using them here as well, as long as they are used 
> > carefully.
> 
> I believe the change in this case is more or less a no-op, so I can't
> bring myself to care either way.
> 
> I seem to recall Andrew (? I thought?) saying that the use of kref's
> helped made obvious cases where use of a reference count followed the
> simplest
> 
> 	atomic_set( ,0) on init

Or rather, atomic_set(,1)

> 	atomic_inc() on get
> 	atomic_dec_and_test() on put
> 
> pattern, and that that simplified reviewing.
> 
> I dunno.
> 

krefs also seem to be missing a wrapper for atomic_read(), which is
used several times in the svc code for BUG_ON()s and dprintks().

Personally I don't see the attraction of krefs.  It looks like someone
saw the typical C++ pattern of a paired abstract base class/smart
pointer class to do automatic reference counting and tried to copy it.
In C it doesn't really work because you can't do a smart pointer and
a virtual destructor is hard to do cleanly.

But, whatever.  In this case they're adequate.

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
