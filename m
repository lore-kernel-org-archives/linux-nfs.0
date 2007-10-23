From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,
	PATCH 1/4] svc: Fix skip computation in svc_defer and svc_revisit
Date: Tue, 23 Oct 2007 12:45:30 +1000
Message-ID: <20071023024530.GB6354@sgi.com>
References: <20071019214058.31422.35615.stgit@dell3.ogc.int>
	<20071019214523.31422.28978.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Ik9ib-0003Ke-Fc
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 19:42:10 -0700
Received: from netops-testserver-3-out.sgi.com
	([192.48.171.28] helo=relay.sgi.com
	ident=[U2FsdGVkX1/6S1ZPxTqTdUNx5a6H96UtAx6pPVaj+3Y=])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Ik9if-0004rT-SK
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 19:42:15 -0700
In-Reply-To: <20071019214523.31422.28978.stgit@dell3.ogc.int>
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

On Fri, Oct 19, 2007 at 04:45:23PM -0500, Tom Tucker wrote:
> 
> The rq_arg.len includes the size of the transport header. The computations
> assumed that it did not.

ok, assuming that your latest svc_rdma_xdr_decode_req(), which I
haven't read yet, doesn't change rq_arg.len as it parses the RDMA
chunking header.

The reason I mention that is that one set of patches I was working
with some time ago had different semantics for rq_arg.len; when
parsing the chunking header, rq_arg.len was adjusted downward as
rq_head[0].iov_base was adjusted forward.  This kept rq_arg.len equal
to the sum of rq_{head[0],pages[...],tail[0]}.iov_len, which seemed
like a good idea.

But your way seems valid too.

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
