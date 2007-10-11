From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,
	PATCH 3/3] knfsd: Modify write_ports to use	svc_find_xprt service
Date: Thu, 11 Oct 2007 11:25:12 -0400
Message-ID: <20071011152512.GB17468@fieldses.org>
References: <20071011034608.GC6684@fieldses.org>
	<C3331AAE.3C378%tom@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Greg Banks <gnb@sgi.com>
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfzuT-0008Ut-Vs
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 08:25:14 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IfzuY-00015q-Sq
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 08:25:19 -0700
In-Reply-To: <C3331AAE.3C378%tom@opengridcomputing.com>
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

On Thu, Oct 11, 2007 at 12:11:26AM -0500, Tom Tucker wrote:
> What's the most efficient way for you to accept fixes/changes? I've been
> going incremental because it's easy on me :-). Is this the best option for
> you?

Well, the problem is that there's two different histories we want, and
no tool really makes it easy (or perhaps can make it really easy) to
track them both:

	- There's the final cleaned-up series that we want submitted.
	- There's the incremental changes that are made to fix problems
	  in the original series.

A lot of people deal with this by just resubmitting the whole thing
(usually as a big mailbomb each time) with a changelog in the 0/n
message that explains what changed since the previous submission.

But in practice I think that means we lose some follow-up review because
it's harder for reviewers in the previous round to plow through the
whole series from the start each time.  And it looks like Greg is still
spotting some problems that might not have been otherwise.  So that's
working.

So for now I guess I'll try what seems to be Andrew's approach--take
incremental patches, then merge them in before the end.  If that turns
out to be too hard, I'll complain.

> Regarding patch #6, I think the svc_find_xprt API _may_ be ok, but the
> implementation was bogus (sorry). I _think_ the implementation is fixed in
> the latest incremental. Greg can confirm.

OK!

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
