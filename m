Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:59901 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750944AbbCITp7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 9 Mar 2015 15:45:59 -0400
Date: Mon, 9 Mar 2015 15:45:59 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: Dave Chinner <david@fromorbit.com>, Eric Sandeen <sandeen@sandeen.net>,
        linux-nfs@vger.kernel.org, xfs@oss.sgi.com
Subject: Re: panic on 4.20 server exporting xfs filesystem
Message-ID: <20150309194559.GC2627@fieldses.org>
References: <20150304222709.GI1627@fieldses.org>
 <20150304224557.GY4251@dastard>
 <54F78BE5.1020608@sandeen.net>
 <20150304225623.GZ4251@dastard>
 <20150305040849.GJ1627@fieldses.org>
 <20150305131731.GA16235@lst.de>
 <20150305150138.GA15674@fieldses.org>
 <20150305170217.GC15674@fieldses.org>
 <20150305204749.GA17934@fieldses.org>
 <20150308153056.GA24037@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150308153056.GA24037@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 08, 2015 at 04:30:56PM +0100, Christoph Hellwig wrote:
> On Thu, Mar 05, 2015 at 03:47:49PM -0500, J. Bruce Fields wrote:
> > nfsd: client 192.168.122.32 failed to respond to layout recall.   Fencing..
> > nfsd: fence failed for client 192.168.122.32: -2!
> > nfsd: client 192.168.122.32 failed to respond to layout recall.   Fencing..
> > nfsd: fence failed for client 192.168.122.32: -2!
> 
> There is no userspace elper to do the fencing, so unfortunately this
> is expecvted.
> 
> > receive_cb_reply: Got unrecognized reply: calldir 0x1 xpt_bc_xprt ffff88005639a000 xid c21abd62
> 
> Now this looks like some issue with the low-level callback path.  I've never
> seen tis before, but from looking at receive_cb_reply this happens if
> xprt_lookup_rqst can't find a rpc_rqst structured for the xid.  Looks like
> we might be corrupting the request list / xid allocation somewhere?
> 
> I can prepare a patch for you to aid with xid tracing if you want.

I'll take a look when I get back.  But before that I'd like to
understand why the layout seems to be left here blocking writes forever,
instead of getting cleaned up after a lease period with no layout
return.

--b.
