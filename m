Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42619 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755447Ab3J2NHW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Oct 2013 09:07:22 -0400
Date: Tue, 29 Oct 2013 06:07:21 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
Message-ID: <20131029130721.GA32094@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-5-git-send-email-bjschuma@netapp.com>
 <20131029073558.GA10889@infradead.org>
 <526FB180.1060003@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <526FB180.1060003@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 29, 2013 at 09:00:48AM -0400, Anna Schumaker wrote:
>  From what I can tell, I think the allocated flag will just tell the 
> clients if all the blocks exist on disk or not.  Is there a way to have 
> a hole with allocated blocks?  Or maybe it's supposed to represent 
> partially allocated blocks?  I checked the draft, and it doesn't 
> actually say what they expect allocated to represent...

You can have preallocated space, which behaves like a hole in that
reads return zeroes.  As far as SEEK_DATA/SEEK_HOLE is concerned we
tend to treat them as holes when we can as that's what the users expect.

Note that at least the pnfs block rfc has a special state representing
this kind of preallocated space.

