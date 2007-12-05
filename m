From: Greg Banks <gnb@sgi.com>
Subject: Re: [RFC,PATCH 34/38] svc: Add /proc/sys/sunrpc/transport files
Date: Wed, 5 Dec 2007 19:44:27 +1100
Message-ID: <20071205084427.GM26759@sgi.com>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int> <20071129224105.14563.48684.stgit@dell3.ogc.int> <C3F9B0D5-6CBD-4BBC-B00E-DCA16DD78EBF@oracle.com> <20071203165853.GE16422@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chuck Lever <chuck.lever@oracle.com>,
	Tom Tucker <tom@opengridcomputing.com>,
	linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from netops-testserver-3-out.sgi.com ([192.48.171.28]:55386 "EHLO
	relay.sgi.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751714AbXLEIhb (ORCPT
	<rfc822;@relay.sgi.com:linux-nfs@vger.kernel.org>);
	Wed, 5 Dec 2007 03:37:31 -0500
In-Reply-To: <20071203165853.GE16422@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 03, 2007 at 11:58:53AM -0500, J. Bruce Fields wrote:
> On Mon, Dec 03, 2007 at 11:44:15AM -0500, Chuck Lever wrote:
> > One last one, then I will crawl back into my hole.
> 
> By the way, based on who I recall making a lot of comments, I'm planning
> on just adding:
> 
> 	Acked-by: Neil Brown <neilb@suse.de>
> 	Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
> 	Reviewed-by: Greg Banks <gnb@sgi.com>
> 
> to all of the server transport-switch and rdma patches.  Does that sound
> right?

For the server transport switch patches: yes please.

For the server RDMA patches: I've not had a chance to read the latest
versions (a long-running drama has been sucking up all my time for some
weeks now), but after all the discussion I'm not expecting any nasty
surprises.  I'll get back to you in a few days.

> And I'm assuming there are no objections to submitting this come the
> next merge window.

Agreed.

Greg.
-- 
Greg Banks, R&D Software Engineer, SGI Australian Software Group.
Apparently, I'm Bedevere.  Which MPHG character are you?
I don't speak for SGI.
