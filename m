Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:44235 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753006Ab3JBQJd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 2 Oct 2013 12:09:33 -0400
Date: Wed, 2 Oct 2013 09:09:32 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 20/49] pnfsd: filelayout: layout encoding
Message-ID: <20131002160932.GA29391@infradead.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220872-13597-1-git-send-email-bhalevy@primarydata.com>
 <20130929121639.GD21083@infradead.org>
 <524C2D43.6040300@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <524C2D43.6040300@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 02, 2013 at 05:27:15PM +0300, Benny Halevy wrote:
> On 2013-09-29 15:16, Christoph Hellwig wrote:
> > The actual XDR encoding doesn't have business being under fs/exportfs
> > and should be in the NFSD code itself.
> 
> But then it will create a module dependency we want to avoid.

Not for the current patchset where the only consumer is nfsd.ko, and not
for any method scheme that isn't braindead.

