Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:52837 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756101Ab3JKU6h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Oct 2013 16:58:37 -0400
Date: Fri, 11 Oct 2013 16:58:36 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Ming Lei <Ming.Lei@riverbed.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Chuck Lever <chuck.lever@oracle.com>
Subject: Re: nfs4.1  pseudo filesystem
Message-ID: <20131011205836.GC22160@fieldses.org>
References: <loom.20131010T232229-437@post.gmane.org>
 <20131011163022.GA22214@fieldses.org>
 <2CE44BD3DBCF9541909CCB42F11CA3921C774298@sfo1exc-mbxp08.nbttech.com>
 <20131011182942.GA22160@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131011182942.GA22160@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Oct 11, 2013 at 02:29:42PM -0400, J. Bruce Fields wrote:
> On Fri, Oct 11, 2013 at 04:51:29PM +0000, Ming Lei wrote:
> > I want to cherry-pick a few subdirectories under say /root, but I don't want to specifies all these mount directories one by one just like NFSv2/3.
> 
> Well, you're kind of stuck enumerating them whether as exports or bind
> mounts.
> 
> > Does pseudo filesystem in kernel v3.11 work well enough?
> 
> But it should work anyway, yes.
> 
> Oh, wait, I see the problem: it doesn't work well if you're exporting
> subdirectories and not full filesystems.  Unless you do something
> special at the export points  (e.g. mount --bind them over themselves),
> knfsd doesn't know when you've crossed an export point.

I wonder if exportfs should be taught to mark export points as
junctions.  That might fix this kind of problem?

It might mean creating junctions never get cleaned up, which is ugly
though perhaps unlikely to be a serious problem in practice.

--b.
