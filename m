Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:36633 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754246Ab3JMLI2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 13 Oct 2013 07:08:28 -0400
Date: Sun, 13 Oct 2013 04:08:20 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 10/49] pnfsd: use sbid hash table to map
 super_blocks to devid major identifiers
Message-ID: <20131013110820.GA31153@infradead.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220831-13136-1-git-send-email-bhalevy@primarydata.com>
 <20131011195608.GA18634@infradead.org>
 <525A399C.5040405@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <525A399C.5040405@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Oct 13, 2013 at 09:11:40AM +0300, Benny Halevy wrote:
> On 2013-10-11 22:56, Christoph Hellwig wrote:
> > On Thu, Sep 26, 2013 at 02:40:31PM -0400, Benny Halevy wrote:
> >> From: Benny Halevy <bhalevy@panasas.com>
> > 
> > This is entirely unessecary.  Just make sure all layouts set the sbid
> > field in getdevicelist to the s_dev value of the filesystem and you
> > can just use user_get_super.
> 
> That's true for filesystmes that have a meaningful s_dev, unlike exofs,
> but this functionality can be added later respectively.

Even exofs has a s_dev from the anon dev_T allocator.  Given that
layouts aren't supposed to surived over reboots of the server I don't
see a problem with it.

