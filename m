From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,
	PATCH 06/35] svc: Add transport specific xpo_release function
Date: Thu, 4 Oct 2007 11:48:48 +1000
Message-ID: <20071004014848.GS21388@sgi.com>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
	<20071001192742.3250.93576.stgit@dell3.ogc.int>
	<D6D83B86-2A07-44F2-A729-9BF9DD74A6D4@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, bfields@fieldses.org, nfs@lists.sourceforge.net
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IdFkc-0002ty-8q
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 18:43:42 -0700
Received: from netops-testserver-4-out.sgi.com ([192.48.171.29]
	helo=relay.sgi.com) by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1IdFkh-0007Y9-7u
	for nfs@lists.sourceforge.net; Wed, 03 Oct 2007 18:43:47 -0700
In-Reply-To: <D6D83B86-2A07-44F2-A729-9BF9DD74A6D4@oracle.com>
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

On Tue, Oct 02, 2007 at 11:18:53AM -0400, Chuck Lever wrote:
> On Oct 1, 2007, at 3:27 PM, Tom Tucker wrote:
> >
> You intend to add xpo_detach and xpo_free in a later patch.  The  
> method names suggest all of these operate on the svc_xprt.   
> xpo_release, however appears to operate on a request, not on a svc_xprt.

Good point.

> Perhaps you might name this method xpo_release_rqst or some other  
> name that indicates that this operates on a request.  The name  
> xpo_release could easily refer to closing the underlying socket.  As  
> an example, the client-side transport uses ->release_request.

I'd really like that, except that server-side the naming waters are
muddied by svc_rqst being the per-thread structure rather a per-request
structure.  I'd use the word "call" to be slightly less ambiguous.

> The client side also appears to treat the transport as handling  
> requests, instead of socket reads and writes.  The use of the method  
> names recvfrom and sendto suggest we are talking about bytes on a  
> socket here, not transmitting and receiving whole RPC requests.  I  
> think that's a useful abstraction.

Agreed.

> While I'm whining aloud... I don't prefer the method names detach or  
> free, either.  On the client side we used close and destroy, which  
> (to me, anyway) makes more sense.

"xpo_destroy" is as good as "xpo_free" by me.  However "xpo_detach"
is actually a precise description of what the method does: it prevents
further data ready callbacks so that no new incoming data is noticed,
and nothing else.  Actually closing the socket needs to be done later
when any sender has finished.

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
