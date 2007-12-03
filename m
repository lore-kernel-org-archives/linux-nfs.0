From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [RFC,PATCH 34/38] svc: Add /proc/sys/sunrpc/transport files
Date: Mon, 3 Dec 2007 11:58:53 -0500
Message-ID: <20071203165853.GE16422@fieldses.org>
References: <20071129223917.14563.77633.stgit@dell3.ogc.int> <20071129224105.14563.48684.stgit@dell3.ogc.int> <C3F9B0D5-6CBD-4BBC-B00E-DCA16DD78EBF@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Tom Tucker <tom@opengridcomputing.com>, linux-nfs@vger.kernel.org,
	Neil Brown <neilb@suse.de>,
	Chuck Lever <chuck.lever@oracle.com>, Greg Banks <gnb@sgi.com>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:60241 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751369AbXLCQ64 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 3 Dec 2007 11:58:56 -0500
In-Reply-To: <C3F9B0D5-6CBD-4BBC-B00E-DCA16DD78EBF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 03, 2007 at 11:44:15AM -0500, Chuck Lever wrote:
> One last one, then I will crawl back into my hole.

By the way, based on who I recall making a lot of comments, I'm planning
on just adding:

	Acked-by: Neil Brown <neilb@suse.de>
	Reviewed-by: Chuck Lever <chuck.lever@oracle.com>
	Reviewed-by: Greg Banks <gnb@sgi.com>

to all of the server transport-switch and rdma patches.  Does that sound
right?

And I'm assuming there are no objections to submitting this come the
next merge window.

--b.
