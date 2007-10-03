From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,PATCH 14/35] svc: Change sk_inuse to a kref
Date: Wed, 03 Oct 2007 09:39:50 -0500
Message-ID: <1191422390.1565.109.camel@trinity.ogc.int>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192801.3250.49751.stgit@dell3.ogc.int>
	<20071003111210.GA19381@infradead.org>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net,
	gnb@sgi.com
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Id5PX-0006yE-RV
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 07:41:15 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Id5PS-0001aN-RM
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 07:41:11 -0700
In-Reply-To: <20071003111210.GA19381@infradead.org>
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

On Wed, 2007-10-03 at 12:12 +0100, Christoph Hellwig wrote:
> On Mon, Oct 01, 2007 at 02:28:01PM -0500, Tom Tucker wrote:
> > 
> > Change the atomic_t reference count to a kref and move it to the 
> > transport indepenent svc_xprt structure. Change the reference count
> > wrapper names to be generic.
> 
> Why?  krefs are a complete pain in the ass, and it's hard to avoid
> various races with them.

I converted to krefs at the request of Chuck Lever who implemented the
client side.

>From my perspective the value of krefs is that it is a focal point for
adding debug logic to catch dangling reference holders -- of course,
that debug logic is not in the kernel right now -- so ... 

Other than that it's a wash.





-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
