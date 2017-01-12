Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58248 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751168AbdALCRE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 21:17:04 -0500
Date: Wed, 11 Jan 2017 21:17:03 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: linux-nfs@vger.kernel.org
Cc: tibbs@math.uh.edu
Subject: Re: RFC: make labeled NFS opt-in
Message-ID: <20170112021703.GC18977@fieldses.org>
References: <20170104165636.GA17649@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170104165636.GA17649@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 04, 2017 at 11:56:36AM -0500, bfields wrote:
> This is something I should have noticed before merging labeled NFS:
> labeled NFS shouldn't be on by default, among other reasons because it
> assumes everybody's using consistent security policies.  As 4.2 is
> getting turned on by default, this is starting to generate bug reports.
> 
> The patch below turns it off by default, and provides a new option to
> turn it on per export.  The drawback is a regression on kernel upgrade
> for anyone depending on labeled NFS, until they find the new option.  My
> impression is that's a specialized use case that still has a small
> number of users at this point, so I think we can get away with that.
> 
> The below is untested.  I have a (small) nfs-utils patch as well.

OK, I've tested now, the only problem was actually a preexisting
bug--I'll post the patches, plus the companion nfs-utils patch.

--b.
