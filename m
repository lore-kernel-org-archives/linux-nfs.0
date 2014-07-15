Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:34854 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753193AbaGOQYn (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 12:24:43 -0400
Date: Tue, 15 Jul 2014 09:24:42 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org, hch@infradead.org
Subject: Re: [PATCH 0/7] nfsd: more delegation fixes to prepare for
 client_mutex removal
Message-ID: <20140715162442.GA8928@infradead.org>
References: <1405420669-4030-1-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405420669-4030-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 15, 2014 at 06:37:42AM -0400, Jeff Layton wrote:
> I know that the Christoph mentioned pushing out the open and lock
> stateid changes next, but we need to finish up the delegation changes in
> order to prepare for those. Most of these have been posted before, and
> they should be merged on top of the two lm_break callback patches that I
> posted yesterday.

Fixing delegations up first sounds perfectly fine to.
