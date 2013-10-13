Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:17616 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754884Ab3JMT3A (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Oct 2013 15:29:00 -0400
Date: Sun, 13 Oct 2013 15:28:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 21/49] nfsd: no need to unhash_stid before free
Message-ID: <20131013192834.GA5077@pad.fieldses.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220876-13642-1-git-send-email-bhalevy@primarydata.com>
 <20131011193721.GA4941@infradead.org>
 <525A3C77.7030600@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <525A3C77.7030600@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 13, 2013 at 09:23:51AM +0300, Benny Halevy wrote:
> On 2013-10-11 22:37, Christoph Hellwig wrote:
> > On Thu, Sep 26, 2013 at 02:41:16PM -0400, Benny Halevy wrote:
> >> idr_remove is about to be called before kmem_cache_free so unhashing it
> >> is redundant
> >>
> >> Signed-off-by: Benny Halevy <bhalevy@primarydata.com>
> > 
> > This is probably something thast should go straight to Bruce, same for
> > the next one in the series.
> > 
> 
> True.
> Bruce, are you ok with merging these patches for 3.13?

Could you just resend separately anything that can be justified as a
bugfix or cleanup independent of the rest of the pnfs stuff?

--b.
