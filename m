From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH] svc: Add xprt header len to svc_deferred_req
Date: Wed, 10 Oct 2007 12:47:04 +1000
Message-ID: <20071010024704.GD20690@sgi.com>
References: <20071009225740.26067.25488.stgit@dell3.ogc.int>
	<20071010023956.GC20690@sgi.com>
	<1191983661.16714.19.camel@trinity.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IfRSv-0005sf-7Z
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 19:38:29 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1+XtRCTI1lVdxh+FiecDAn4ztH+cNXjRPc=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IfRSy-0006oM-CI
	for nfs@lists.sourceforge.net; Tue, 09 Oct 2007 19:38:34 -0700
In-Reply-To: <1191983661.16714.19.camel@trinity.ogc.int>
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

On Tue, Oct 09, 2007 at 09:34:21PM -0500, Tom Tucker wrote:
> On Wed, 2007-10-10 at 12:39 +1000, Greg Banks wrote:
> > On Tue, Oct 09, 2007 at 05:57:40PM -0500, Tom Tucker wrote:
> > > 
> > Are you planning on restoring rqstp->rq_xprt_hlen from
> > dr->xprt_hlen in svc_deferred_recv() ?
> 
> Well that's a really good question. I'm assuming RPC are never deferred
> more than one. That seems naive looking at the code.

Also, multiple other RPCs can be handled by the nfsd thread while
waiting for deferred RPCs, each of which can change rq_xprt_hlen
to different values.

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
