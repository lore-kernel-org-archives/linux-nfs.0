Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:52277 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766Ab3JaRN3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 31 Oct 2013 13:13:29 -0400
Date: Thu, 31 Oct 2013 10:13:26 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <bjschuma@netapp.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
Message-ID: <20131031171326.GA31800@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-5-git-send-email-bjschuma@netapp.com>
 <20131031160440.GA30108@infradead.org>
 <5272829A.90105@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5272829A.90105@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 31, 2013 at 12:17:30PM -0400, Anna Schumaker wrote:
> On 10/31/2013 12:04 PM, Christoph Hellwig wrote:
> > Btw, I just noticed that current nfs mainline fails xfstests 286 which
> > test SEEK_DATA/SEEK_HOLE.   That sounds like a useful test case for your
> > patches.
> > 
> 
> I read too quickly.  I've been using 285 to test against, but I'll see what 286 gets me!  Thanks for the tip :)

I actually meant 285.  286 tests SEEK_HOLE as well but passes already
with the dumb default behaviour.
