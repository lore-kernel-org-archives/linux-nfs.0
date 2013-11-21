Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:49130 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750805Ab3KUHTj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 21 Nov 2013 02:19:39 -0500
Date: Wed, 20 Nov 2013 23:19:33 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>,
        chenditang <chendt.fnst@cn.fujitsu.com>,
        Benny Halevy <bhalevy@tonian.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] pnfsd-file: cause oops when stop the nfs server
Message-ID: <20131121071933.GA2619@infradead.org>
References: <51517A15.3010805@cn.fujitsu.com>
 <51776397.2050504@cn.fujitsu.com>
 <5242FA2F.1000302@primarydata.com>
 <20131120164053.GA16928@infradead.org>
 <528DAF90.6000702@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <528DAF90.6000702@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 21, 2013 at 09:00:32AM +0200, Benny Halevy wrote:
> On 2013-11-20 18:40, Christoph Hellwig wrote:
> > On Wed, Sep 25, 2013 at 10:58:55AM -0400, Benny Halevy wrote:
> >> Chenditang, I see that this patch was never subimtted upstream.
> >> Is there anything specific to pnfs that causes this bug?
> > 
> > It's not.  I've just reproduced it without pnfs, by shutting down
> > the server after running xfstests over a NFSv4.1 mount.
> > 
> 
> This should be covered by this patch:
> http://git.linux-nfs.org/?p=bfields/linux.git;a=commitdiff;h=e50a26d

Indeed, that fixes it as well.

