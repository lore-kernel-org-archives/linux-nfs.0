From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 00/35] SVC Transport Switch
Date: Tue, 2 Oct 2007 11:25:58 -0400
Message-ID: <20071002152558.GC21675@fieldses.org>
References: <20071001191426.3250.15371.stgit@dell3.ogc.int>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: neilb@suse.de, nfs@lists.sourceforge.net, gnb@sgi.com
To: Tom Tucker <tom@opengridcomputing.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IcjdH-0004MQ-QW
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 08:25:59 -0700
Received: from mail.fieldses.org ([66.93.2.214] helo=fieldses.org)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IcjdL-00011T-8n
	for nfs@lists.sourceforge.net; Tue, 02 Oct 2007 08:26:04 -0700
In-Reply-To: <20071001191426.3250.15371.stgit@dell3.ogc.int>
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

On Mon, Oct 01, 2007 at 02:14:26PM -0500, Tom Tucker wrote:
> This is rev 2 of the new pluggable transport switch for
> RPC servers. This version includes two new patches: one to add a field
> for keeping track of a transport specific header that precedes the
> RPC header for deferral processing, and one that cleans up some 
> left over references to svc_sock in transport independent code.

Thanks! I've replaced this in for-mm at

	git://linux-nfs.org/~bfields/linux.git for-mm

But still haven't taken the time to read through it carefully.

The review comments seem to mostly be on small stuff.  Are there any
doubts about the basic approach?

By the way, are the only three transport classes we can forsee for now
udp, tcp, and rdma?

--b.

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
