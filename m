From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,
	PATCH] svc: Restore rq_xprt_hlen in svc_deferred_recv
Date: Mon, 15 Oct 2007 11:22:41 +1000
Message-ID: <20071015012241.GC13665@sgi.com>
References: <20071012192110.25641.29211.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IhEUD-0006jT-8I
	for nfs@lists.sourceforge.net; Sun, 14 Oct 2007 18:11:13 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX195Zlz7H7gUlMOx0ntbW4qSOc9sHNpzeVI=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IhEUH-0003Yl-EC
	for nfs@lists.sourceforge.net; Sun, 14 Oct 2007 18:11:18 -0700
In-Reply-To: <20071012192110.25641.29211.stgit@dell3.ogc.int>
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

On Fri, Oct 12, 2007 at 02:21:10PM -0500, Tom Tucker wrote:
> 
> Fixed a couple bugs in the deferral processing. This won't see significant
> testing until I complete the rdma driver mods because tcp/udp always
> set the xprt_hlen to zero.  The changes are as follows:
> 
> - Restore the length of the transport header in the rqstp structure
> in case the request gets deferred again. 
> 
> - Update the iov_head and arg.len with xprt_hlen.
> 
> - Add comments that describe how xprt_hlen is used.
> 

ok.

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
