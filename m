Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:55961 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933AbaAGPx1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Jan 2014 10:53:27 -0500
Date: Tue, 7 Jan 2014 07:53:24 -0800
From: Christoph Hellwig <hch@infradead.org>
To: viro@zeniv.linux.org.uk
Cc: linux-fsdevel@vger.kernel.org, linux-btrfs@vger.kernel.org,
        linux-ext4@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net,
        linux-mtd@lists.infradead.org, Mark Fasheh <mfasheh@suse.com>,
        Joel Becker <jlbec@evilplan.org>, reiserfs-devel@vger.kernel.org,
        xfs@oss.sgi.com, jfs-discussion@lists.sourceforge.net,
        cluster-devel@redhat.com, linux-nfs@vger.kernel.org,
        Andreas Gruenbacher <andreas.gruenbacher@linbit.com>
Subject: Re: [PATCH 00/21] Consolidate Posix ACL implementation V3
Message-ID: <20140107155324.GA24113@infradead.org>
References: <20131220131635.650823732@bombadil.infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131220131635.650823732@bombadil.infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 20, 2013 at 05:16:35AM -0800, Christoph Hellwig wrote:
> This series consolidates the various cut'n'pasted Posix ACL implementations
> into a single common one based on the ->get_acl method Linus added a while
> ago and a new ->set_acl counterpart.
> 
> This remove ~1800 lines of code and provides a single place to implement
> various nasty little gems of the semantics.

Any more comments?  Al, what's the best way to make sure this doesn't
miss 3.14?

