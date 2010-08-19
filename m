Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:47387 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab0HSJnd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Aug 2010 05:43:33 -0400
Date: Thu, 19 Aug 2010 05:43:31 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@panasas.com>
Cc: Christoph Hellwig <hch@infradead.org>, andros@netapp.com,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 11/50] pnfs_submit: set and unset pnfs layoutdriver
 modules
Message-ID: <20100819094330.GB15610@infradead.org>
References: <1281735122-1496-5-git-send-email-andros@netapp.com>
 <1281735122-1496-6-git-send-email-andros@netapp.com>
 <1281735122-1496-7-git-send-email-andros@netapp.com>
 <1281735122-1496-8-git-send-email-andros@netapp.com>
 <1281735122-1496-9-git-send-email-andros@netapp.com>
 <1281735122-1496-10-git-send-email-andros@netapp.com>
 <1281735122-1496-11-git-send-email-andros@netapp.com>
 <1281735122-1496-12-git-send-email-andros@netapp.com>
 <20100818203126.GE16851@infradead.org>
 <4C6C4697.3060309@panasas.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C6C4697.3060309@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Aug 18, 2010 at 11:46:15PM +0300, Benny Halevy wrote:
> On Aug. 18, 2010, 23:31 +0300, Christoph Hellwig <hch@infradead.org> wrote:
> > I don't think such a fine-grained splitup is reviewable at all.
> > Anything more than a couple of patches for core nfs client changes, 
> > one patch for core pnfs support and one for the file layout driver
> > is simply too much.
> > 
> 
> The whole enchilada is about 8500 lines of diff.
> Don't you think that splitting it up to self contained bite-sized patches
> is better for reviewing it?

Depends on your defintion of self contained.  If you actually have
a first patch with a functional and working subset and just keep adding
optimizations or new features that's okay, but otherwise it's poinless.
If you submit a single driver / feature it needs to be a reviewed as a
whole and not artifical pieces.
