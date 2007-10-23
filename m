From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,
	PATCH 1/4] svc: Fix skip computation in svc_defer and svc_revisit
Date: Tue, 23 Oct 2007 13:52:26 +1000
Message-ID: <20071023035226.GD6354@sgi.com>
References: <20071019214058.31422.35615.stgit@dell3.ogc.int>
	<20071019214523.31422.28978.stgit@dell3.ogc.int>
	<20071023024530.GB6354@sgi.com>
	<471D6670.5050704@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IkAlG-000105-MB
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 20:48:58 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1IkAlK-00052E-W3
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 20:49:04 -0700
In-Reply-To: <471D6670.5050704@opengridcomputing.com>
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

On Mon, Oct 22, 2007 at 10:11:44PM -0500, Tom Tucker wrote:
> [...] So to cut to the chase here, the design 
> decision being made is that any transport that needs to save it's 
> transport header _must_ include the transport header in the rq_arg.len

Works for me, just remember to document it.

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
