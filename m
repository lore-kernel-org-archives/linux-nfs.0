Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:56456 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752590AbbA2BQ3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Jan 2015 20:16:29 -0500
Date: Wed, 28 Jan 2015 13:38:32 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Anna.Schumaker@netapp.com
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 0/4] NFSD: Add READ_PLUS support
Message-ID: <20150128213832.GA24389@infradead.org>
References: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1422477777-27933-1-git-send-email-Anna.Schumaker@Netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jan 28, 2015 at 03:42:53PM -0500, Anna.Schumaker@netapp.com wrote:
> From: Anna Schumaker <Anna.Schumaker@Netapp.com>
> 
> These patches add server support for the NFS v4.2 operation READ_PLUS.
> 
> I noticed a race condition in the 3rd patch when I start needing vfs_llseek()
> to determine if I should encode the next segment as either data or a hole.  It
> is possible that the file could change on us between each of the seek calls,
> so we don't know if we are actually at a hole or data segment.  I don't want to
> add new locks to the NFS server for this case, so instead I've decided to
> encode any "quantum data" segments as if they were actually data.
> 
> I tested these patches using xfstests, specificially generic/075, generic/091,
> generic/112, generic/127, generic/210, and generic/263.  Additionally, three
> new tests are run once READ_PLUS support has been added: generic/213,
> generic/214, and generic/228.

Why do theses test start working when you use READ_PLUS?  They should
only depend on ALLOCATE support, and maybe SEEK if we're trying to
figure out information about mappings somehow.
