Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58632 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753301AbcHVT1P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 22 Aug 2016 15:27:15 -0400
Date: Mon, 22 Aug 2016 15:27:13 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: andros@netapp.com, trondmy.myklebust@primarydata.com,
        anna.schumaker@netapp.com, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@rhel7-2-ga-3.androsad.fake>
Subject: Re: [PATCH Version-2 03/12] VFS permit cross device
 vfs_copy_file_range
Message-ID: <20160822192713.GA12581@fieldses.org>
References: <1471627512-4102-1-git-send-email-andros@netapp.com>
 <1471627512-4102-4-git-send-email-andros@netapp.com>
 <20160819210844.GR32329@fieldses.org>
 <20160820061833.GA6812@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160820061833.GA6812@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Aug 20, 2016 at 08:18:33AM +0200, Christoph Hellwig wrote:
> On Fri, Aug 19, 2016 at 05:08:44PM -0400, J. Bruce Fields wrote:
> > I thought I remembered Christoph (cc'd) arguing at the 2015 lsf/mm that
> > there were some more issues that would need to be taken care of before
> > we could turn on cross-device copies.
> 
> Yes.  Noi other VFS operation is supported between mountpoint, so
> copy_file_range shouldn't be either.

Is there anything specific it would break?

> Also a general NAK to any new copy_file_range work before we have
> proper xfstests coverage.  And it's not like the coverage is hard,
> we already have 100s of tests for clone, which in many way is very
> similar and could be partially reused.

Sounds like a reasonable request.

--b.
