Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:38915 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753099Ab3JANTn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Oct 2013 09:19:43 -0400
Date: Tue, 1 Oct 2013 06:19:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 05/49] pnfsd: introduce pnfsd header files
Message-ID: <20131001131940.GA32431@infradead.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220810-12909-1-git-send-email-bhalevy@primarydata.com>
 <20130929114327.GB25750@infradead.org>
 <52481939.7060405@primarydata.com>
 <20130929121345.GA21083@infradead.org>
 <52481B11.2080407@primarydata.com>
 <20130929122130.GI21083@infradead.org>
 <20130929123553.GA7510@infradead.org>
 <5249977E.5060106@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <5249977E.5060106@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 30, 2013 at 06:23:42PM +0300, Benny Halevy wrote:
> This makes sense for blocks for its use of the generic block allocation and mapping
> calls (and it needs a new call for committing uninitialized extents)
> But for objects there are no such calls and the integration with exofs
> is pretty intimate.

That's just because there is no proper split between exofs and the
pnfsd-objects layer.  The split between the two doesn't seem too hard
and would dramatically improve the interface.

With that and moving the recall handling on truncate to generic code
where it belongs almost nothin pnfs-specific will be left in exofs.

