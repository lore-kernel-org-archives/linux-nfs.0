From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] nfsd: fix possible read-ahead cache and
	export	table corruption
Date: Tue, 24 Jul 2007 10:40:40 -0400
Message-ID: <20070724144040.GA24302@fieldses.org>
References: <20070713024420.GA31364@fieldses.org>
	<20070713041019.GB20430@sgi.com>
	<20070713174625.GF12582@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Neil Brown <neilb@suse.de>, nfs@lists.sourceforge.net
To: Greg Banks <gnb@sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IDLZ5-0001mT-5I
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 07:40:43 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IDLZ8-0002Xl-QL
	for nfs@lists.sourceforge.net; Tue, 24 Jul 2007 07:40:47 -0700
In-Reply-To: <20070713174625.GF12582@fieldses.org>
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

On Fri, Jul 13, 2007 at 01:46:25PM -0400, J. Bruce Fields wrote:
> On Fri, Jul 13, 2007 at 02:10:19PM +1000, Greg Banks wrote:
> > There's a couple of other problems with that code, for which I'll send
> > patches shortly.  But I think the raparams cache needs a more thorough
> > renovation than that.  I have a mostly-working patch which rips it out
> > entirely and replaces it with a cache of open struct files, an idea
> > of Neil's.  This approach fixes a whole bunch of separate problems
> > at once, and will be really useful...
> 
> OK!  What are the other problems you were thinking of?

By the way, one other problem with keeping open files that I was
reminded of recently--currently you should be able to do something like

	killall rpc.mountd
	# flush export table:
	exportfs -f
	umount /exports
	... do stuff
	mount /exports
	rpc.mountd

Also useful if you want to unmount a filesystem one one machine so you
can move it to another and mount it there.  But that's only possible
because noone holds a file open for longer than the time required to
service a single request.

Well, no-one except lockd--hence Wendy's patches to drop all locks on a
filesystem.  Or the nfsv4 server, which is holding files open as long as
clients have them open.  Oops, my fault.  I'm not sure quite what to do
about that.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
