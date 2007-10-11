From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [RFC,
	PATCH 3/3] knfsd: Modify write_ports to use	svc_find_xprt service
Date: Thu, 11 Oct 2007 10:27:08 -0500
Message-ID: <1192116428.7491.5.camel@trinity.ogc.int>
References: <20071011034608.GC6684@fieldses.org>
	<C3331AAE.3C378%tom@opengridcomputing.com>
	<20071011152512.GB17468@fieldses.org>
Reply-To: tom@opengridcomputing.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: NeilBrown <neilb@suse.de>, nfs@lists.sourceforge.net,
	Greg Banks <gnb@sgi.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfzxX-0000do-Su
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 08:28:24 -0700
Received: from 209-198-142-2-host.prismnet.net ([209.198.142.2]
	helo=smtp.opengridcomputing.com)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ifzxc-0006Q9-9f
	for nfs@lists.sourceforge.net; Thu, 11 Oct 2007 08:28:28 -0700
In-Reply-To: <20071011152512.GB17468@fieldses.org>
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

On Thu, 2007-10-11 at 11:25 -0400, J. Bruce Fields wrote:
> On Thu, Oct 11, 2007 at 12:11:26AM -0500, Tom Tucker wrote:
> > What's the most efficient way for you to accept fixes/changes? I've been
> > going incremental because it's easy on me :-). Is this the best option for
> > you?
> 
> Well, the problem is that there's two different histories we want, and
> no tool really makes it easy (or perhaps can make it really easy) to
> track them both:
> 
> 	- There's the final cleaned-up series that we want submitted.
> 	- There's the incremental changes that are made to fix problems
> 	  in the original series.
> 
> A lot of people deal with this by just resubmitting the whole thing
> (usually as a big mailbomb each time) with a changelog in the 0/n
> message that explains what changed since the previous submission.
> 
> But in practice I think that means we lose some follow-up review because
> it's harder for reviewers in the previous round to plow through the
> whole series from the start each time.  And it looks like Greg is still
> spotting some problems that might not have been otherwise.  So that's
> working.
> 
> So for now I guess I'll try what seems to be Andrew's approach--take
> incremental patches, then merge them in before the end.  If that turns
> out to be too hard, I'll complain.

np. I've got a stacked git tree that has the whole set, so I can flatten
it or keep it at your discretion. 

> 
> > Regarding patch #6, I think the svc_find_xprt API _may_ be ok, but the
> > implementation was bogus (sorry). I _think_ the implementation is fixed in
> > the latest incremental. Greg can confirm.
> 
> OK!
> 
> --b.


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
