From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH] svc: bzero the xprt memory in svc_xprt_init
Date: Mon, 15 Oct 2007 11:22:26 +1000
Message-ID: <20071015012226.GB13665@sgi.com>
References: <20071012190048.24784.44983.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IhETx-0006eD-Vd
	for nfs@lists.sourceforge.net; Sun, 14 Oct 2007 18:10:58 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1/ZV/CDOXQinLlssDUGx0z9DweVwFYNQ70=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IhEU2-0003RR-3e
	for nfs@lists.sourceforge.net; Sun, 14 Oct 2007 18:11:03 -0700
In-Reply-To: <20071012190048.24784.44983.stgit@dell3.ogc.int>
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

On Fri, Oct 12, 2007 at 02:00:48PM -0500, Tom Tucker wrote:
> 
> The transport class driver is responsible for allocating the 
> memory that contains svc_xprt. We don't know whether the driver
> used kzalloc or kmalloc. Initialize the svc_xprt structure to
> zeroes just in case.

ok.

> Also changed the name of the svc_xprt ptr variable to xprt to
> be consistent with the naming used everywhere else for the
> transport ptr.

Cool, there's a lot to be said for consistency.

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
