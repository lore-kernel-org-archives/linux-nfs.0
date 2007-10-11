From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,
	PATCH 3/3] knfsd: Modify write_ports to use svc_find_xprt	service
Date: Wed, 10 Oct 2007 23:46:08 -0400
Message-ID: <20071011034608.GC6684@fieldses.org>
References: <20071011022356.3501.63859.stgit@dell3.ogc.int>
	<20071011022901.3501.5244.stgit@dell3.ogc.int>
	<18189.37354.527748.91357@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, gnb@sgi.com
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ifozx-0005rR-8y
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 20:46:09 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1Ifp00-0005sl-9H
	for nfs@lists.sourceforge.net; Wed, 10 Oct 2007 20:46:14 -0700
In-Reply-To: <18189.37354.527748.91357@notabene.brown>
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

On Thu, Oct 11, 2007 at 01:00:58PM +1000, Neil Brown wrote:
> On Wednesday October 10, tom@opengridcomputing.com wrote:
> >  		if (sscanf(buf, "%15s %4d", transport, &port) == 2) {
> 
> We should give a bit of thought to this parsing and future expansion.
> Suppose we did want to pump more information into the kernel as has
> been suggested (e.g. local IP address), we would want this code to
> handle the new format correctly, probably by failing.
> 
> So maybe we really want
> 
> >  		if (sscanf(buf, "%15s %4d%c", transport, &port, &nl) == 2
> 	            && nl == '\n') {
> 
> or something like that???
> 
> BTW, I'm fairly happy with the state of this patch set and suggest
> that we aim for 2.6.24-rc1.  I still want to read through the final
> code with all patches applied, but I should be able to find time for
> that in the next month or so.  I don't expect any significant issues.

It seems OK to me, and it would be nice to get this batch in and have
just the rdma stuff left to merge in 2.6.25.

But we're very short for time, and it appears that there's still some
work to be done.  Certainly any user interfaces need to be sorted out,
as we'll be stuck with them....

Other work to be done: these incremental fixes are helpful for reviewers
like Greg who are keeping close watch on the process, but we need to
submit a patch series that shows our changes with perfect hindsight, so
we need to combine these with the previous patches.  I did this with the
most recent two of Tom's 7-patch series; result here:

	git://linux-nfs.org/~bfields/linux.git server-xprt-switch

I didn't apply patch #6 since Greg still had comments, and I haven't
applied the most recent fixes.

If this isn't all ready by Friday (OK, maybe Monday) then I think we're
out of time.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
