Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58596 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757337AbbBEL1y (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 Feb 2015 06:27:54 -0500
Date: Thu, 5 Feb 2015 03:27:49 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Olga.Kornievskaia@netapp.com
Subject: Re: [PATCH 1/2] NFSv4.1: Ask for no delegation on OPEN if using
 O_DIRECT
Message-ID: <20150205112749.GA13486@infradead.org>
References: <1423000784-93180-1-git-send-email-trond.myklebust@primarydata.com>
 <20150204081624.GA16543@infradead.org>
 <CAABAsM4Sy+252QAhwOk_6RM6rGq0g4AxtHA2Yp0dovKeN6At7A@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAABAsM4Sy+252QAhwOk_6RM6rGq0g4AxtHA2Yp0dovKeN6At7A@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Feb 04, 2015 at 07:32:43AM -0500, Trond Myklebust wrote:
> Delegations are all about allowing the NFS client to cache data
> aggressively, and notifying when it is no longer safe to do so. That
> is clearly not of interest to an application using O_DIRECT, since it
> is by definition managing the data cache (if there is one) instead of
> the NFS client. We don't share delegation state with userspace and
> even if we did, there are no existing applications out there that are
> capable (or even interested) of taking advantage of it.
> 
> You can argue that the client could still use the delegation to cache
> metadata and open/lock state, but most of the users of O_DIRECT of
> which I'm aware tend to be data intensive, and not very metadata/state
> intensive. So why burden both the server and the with that extra state
> management?

How does the delegation hurt us in this case?  That needs to go into
the patch description, and into a comment near the code.

