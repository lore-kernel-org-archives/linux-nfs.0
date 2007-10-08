From: Neil Brown <neilb@suse.de>
Subject: Re: [RFC,PATCH 14/35] svc: Change sk_inuse to a kref
Date: Mon, 8 Oct 2007 13:52:12 +1000
Message-ID: <18185.43372.936660.630626@notabene.brown>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192801.3250.49751.stgit@dell3.ogc.int>
	<20071003111210.GA19381@infradead.org>
	<20071003144517.GA10001@fieldses.org>
	<20071003145238.GA30564@infradead.org>
	<20071003151139.GB10001@fieldses.org>
	<20071003151525.GA32010@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	nfs@lists.sourceforge.net, gnb@sgi.com
To: Christoph Hellwig <hch@infradead.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IejfP-0001jy-Rl
	for nfs@lists.sourceforge.net; Sun, 07 Oct 2007 20:52:32 -0700
Received: from cantor2.suse.de ([195.135.220.15] helo=mx2.suse.de)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IejfS-0004yp-QX
	for nfs@lists.sourceforge.net; Sun, 07 Oct 2007 20:52:33 -0700
In-Reply-To: message from Christoph Hellwig on Wednesday October 3
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

On Wednesday October 3, hch@infradead.org wrote:
> On Wed, Oct 03, 2007 at 11:11:39AM -0400, J. Bruce Fields wrote:
> > OK, but why are they a complete pain in the ass, and which hard-to-avoid
> > races are you thinking of?  Is that documented somewhere?
> 
> They lack a primitive equivalent to atomic_dec_and_test which is required
> if you need the lock to prevent it going up from zero again.  There have
> been various lkml threads on this.

I think you mean an equivalent to atomic_dec_and_lock.

I have noticed that too.  However I don't think it means that krefs
should be a avoided.
Rather, I think it means that we need something slightly different
(lrefs?) that use atomic_dec_and_lock instead of atomic_dec_and_test,
and then some accessible documentation which explains the different
common usage patterns of reference counting, and when krefs are
correct, and when lrefs are correct.

I'm in favour of using krefs for sk_inuse.  dec_and_lock isn't an
issue in this case.

NeilBrown

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
