From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,
	PATCH 0/3] svc: gnb review cleanup for transport switch
Date: Fri, 12 Oct 2007 11:41:24 -0400
Message-ID: <20071012154124.GB1025@fieldses.org>
References: <20071011022356.3501.63859.stgit@dell3.ogc.int>
	<20071011203029.GE22823@fieldses.org>
	<1192140282.7491.33.camel@trinity.ogc.int>
	<20071011220820.GF22823@fieldses.org>
	<1192202234.30080.21.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net, gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IgMdf-0004VK-Eh
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 08:41:23 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IgMdj-0000uq-HR
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 08:41:28 -0700
In-Reply-To: <1192202234.30080.21.camel@trinity.ogc.int>
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

On Fri, Oct 12, 2007 at 10:17:14AM -0500, Tom Tucker wrote:
> On Thu, 2007-10-11 at 18:08 -0400, J. Bruce Fields wrote:
> > On Thu, Oct 11, 2007 at 05:04:42PM -0500, Tom Tucker wrote:
> > > I think I found the problem. The patchset is not caching the auth data
> > > properly. This causes the server to fail the setting of the client id
> > > with a 10018 error.
> > > 
> > > I'll send a patch off tonight....sorry :-\
> 
> A quick update. The problem is not what I thought it was, but I did
> discover some interesting things:
> 
> - If you wait 60 seconds after the nfs4 mount, everything works fine.
> You can run connectathon and the world is happy. Before the 60 seconds
> you get the hang. Curiously, there are connection management timers in
> the client that have this value.

Oh, well that may be just the grace period--we don't generally allow any
opens for the first lease time (45 seconds by default, I think?)

(We should be smarter and skip the grace period in cases where we know
no former clients held state on the server.  I'm hoping that'll be fixed
in the next month.)

> - It looks like the module load logic that is down in the
> crypto_alloc_hash path is not working properly. Maybe the module name
> changed or something, or maybe it always worked this way and I'm
> confused, but you have to manually load md5 for nfs4 to work
> 
> - It looks like the callback path is still broken. It's not the port
> number, it's the IP address. Since I moved the IP address, it's likely
> that I'm the culprit. 

OK, thanks.

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
