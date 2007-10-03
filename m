From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 14/35] svc: Change sk_inuse to a kref
Date: Wed, 3 Oct 2007 11:11:39 -0400
Message-ID: <20071003151139.GB10001@fieldses.org>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192801.3250.49751.stgit@dell3.ogc.int>
	<20071003111210.GA19381@infradead.org>
	<20071003144517.GA10001@fieldses.org>
	<20071003145238.GA30564@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net, gnb@sgi.com
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id5sw-0002bt-UK
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 08:11:39 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Id5t0-0002no-OY
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 08:11:44 -0700
In-Reply-To: <20071003145238.GA30564@infradead.org>
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

On Wed, Oct 03, 2007 at 03:52:38PM +0100, Christoph Hellwig wrote:
> On Wed, Oct 03, 2007 at 10:45:17AM -0400, J. Bruce Fields wrote:
> > On Wed, Oct 03, 2007 at 12:12:10PM +0100, Christoph Hellwig wrote:
> > > On Mon, Oct 01, 2007 at 02:28:01PM -0500, Tom Tucker wrote:
> > > > 
> > > > Change the atomic_t reference count to a kref and move it to the 
> > > > transport indepenent svc_xprt structure. Change the reference count
> > > > wrapper names to be generic.
> > > 
> > > Why?  krefs are a complete pain in the ass, and it's hard to avoid
> > > various races with them.
> > 
> > So kref's are deprecated now?  What's the deal?  Is there a pointer to
> > discussion somewhere?
> 
> The people that have introduced them as still playing fanboys for them,
> but that doesn't make them any better idea.  I don't think they've every
> been encouraged by lots of people.

OK, but why are they a complete pain in the ass, and which hard-to-avoid
races are you thinking of?  Is that documented somewhere?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
