Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42338 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752207AbaDYLEL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Apr 2014 07:04:11 -0400
Date: Fri, 25 Apr 2014 04:04:09 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Ben Greear <greearb@candelatech.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>
Subject: Re: Crash in 3.14.0+ (plus hacks)
Message-ID: <20140425110409.GA27561@infradead.org>
References: <5346D22A.10102@candelatech.com>
 <20140425104803.GD22295@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140425104803.GD22295@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 25, 2014 at 06:48:03AM -0400, J. Bruce Fields wrote:
> On Thu, Apr 10, 2014 at 10:17:30AM -0700, Ben Greear wrote:
> > This could be related to some changes I made to nfs, but in case the
> > problem is obvious, here's the stack trace.
> 
> There's also a report here:
> 
> 	https://bugzilla.kernel.org/show_bug.cgi?id=74721
> 
> While I'm travelling, I'm cc'ing Christoph in case this might be a
> consequence of his recent ACL cleanup?

Chuck already sent a patch in reply to this bug report:

	[PATCH] tmpfs: Fix simple_set_acl()

