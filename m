From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 14/35] svc: Change sk_inuse to a kref
Date: Wed, 3 Oct 2007 11:34:01 -0400
Message-ID: <20071003153401.GD10001@fieldses.org>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192801.3250.49751.stgit@dell3.ogc.int>
	<20071003111210.GA19381@infradead.org>
	<20071003144517.GA10001@fieldses.org>
	<20071003145238.GA30564@infradead.org>
	<50751C78-DD55-4549-A03E-2DFBBEF7AED3@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Christoph Hellwig <hch@infradead.org>, neilb@suse.de,
	nfs@lists.sourceforge.net, gnb@sgi.com
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id6Ei-00070A-JC
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 08:34:08 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Id6En-0006Rg-E3
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 08:34:13 -0700
In-Reply-To: <50751C78-DD55-4549-A03E-2DFBBEF7AED3@oracle.com>
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

On Wed, Oct 03, 2007 at 11:13:58AM -0400, Chuck Lever wrote:
> We're using krefs without issue in several other areas of the RPC client 
> and server.  Both rpc_clnt and rpc_xprt have a kref in them, for example.  
> I don't see the harm in using them here as well, as long as they are used 
> carefully.

I believe the change in this case is more or less a no-op, so I can't
bring myself to care either way.

I seem to recall Andrew (? I thought?) saying that the use of kref's
helped made obvious cases where use of a reference count followed the
simplest

	atomic_set( ,0) on init
	atomic_inc() on get
	atomic_dec_and_test() on put

pattern, and that that simplified reviewing.

I dunno.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
