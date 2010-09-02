Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:59039 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752322Ab0IBQG7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Sep 2010 12:06:59 -0400
Date: Thu, 2 Sep 2010 12:06:27 -0400
To: Greg <greg-sys@duchatelet.net>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Relocate NFS root FS for maintenance
Message-ID: <20100902160627.GH13117@fieldses.org>
References: <4C7E4469.70807@duchatelet.net>
 <4C7ECB23.60300@excfb.com>
 <4C7F5302.30300@duchatelet.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C7F5302.30300@duchatelet.net>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Sep 02, 2010 at 09:32:18AM +0200, Greg wrote:
>  Tom,
> 
> >
> >What you are missing here is that the client uses two things to
> >access content on
> >the servers - path and file handles. When you do the reshare, you
> >would be pointing any
> >new requests to the empty directories. But, any application which
> >already had a
> >file handle would have a reference to the old mount (via the fsid
> >part of the file handle).
> 
> OK thanks for the precisions. It's why I'm getting those errors :
> Sep  1 15:12:53 varan-14 kernel: [3424547.256518] NFS: server
> filer-large-vip.local error: fileid changed
> Sep  1 15:12:53 varan-14 kernel: [3424547.256518] fsid 0:13:
> expected fileid 0x2, got 0x41
> 
> >The options I see are to:
> >
> >1) Shutdown NFS/remove write access to the export/etc - this is
> >along the lines of what
> >you have done. And the result is that the server will inform the
> >client of an error.
> >
> >2) Disconnect the servers from the network. (Or partition the
> >network). In this scenario,
> >the client will be getting timeouts and will probably use a retry schema.
> >
> >3) Shutdown the NFS clients - harsh, but they will not be
> >accessing the servers and you
> >can easily do the upgrades.
> >
> >These all result in downtime for both your servers and your clients.
> 
> So in short there is no way to do a maintenance on attached storage,
> could it be hard drives, RAID, iSCSI or anything.
> Is such a "feature" in the roadmap ?

I think I just don't understand your setup, because I'm confused about
what you're asking for.  (If the thing you're upgrading is literally the
only path between the nfs servers and their storage, then what can we
do?)

Would you mind explaining again from the start exactly what you're setup
is and what you're hoping to accomplish by moving these mountpoints?
Apologies for being dense!

--b.
