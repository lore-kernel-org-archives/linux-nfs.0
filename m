Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47089 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750893AbbGIIMk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jul 2015 04:12:40 -0400
Date: Thu, 9 Jul 2015 01:12:39 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/5] nfsd: Fix a file leak of ls_file if
 nfsd4_layout_setlease fail
Message-ID: <20150709081239.GB19291@infradead.org>
References: <559672B7.4010802@gmail.com>
 <20150708213015.GG19084@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150708213015.GG19084@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 08, 2015 at 05:30:15PM -0400, J. Bruce Fields wrote:
> Hm, is the stateid really completely enough set up that this is safe?

It's not.  nfsd4_free_layout_stateid unconditionally deletes
from the per-client and per-file lists which are empty at this
point.  Just adding an explicit fput would be the better fix.
