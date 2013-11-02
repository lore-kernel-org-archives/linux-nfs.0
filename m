Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60129 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753754Ab3KBNyK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Nov 2013 09:54:10 -0400
Date: Sat, 2 Nov 2013 06:54:09 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Message-ID: <20131102135409.GC18961@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
 <20131028214030.GO31322@fieldses.org>
 <526FAF30.3060502@netapp.com>
 <20131029130649.GA29606@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131029130649.GA29606@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Oct 29, 2013 at 09:06:49AM -0400, J. Bruce Fields wrote:
> What I meant was--why are we doing a sync at all, instead of returning
> NFS_UNSTABLE and making the client commit?

Did NFSv4.2 introduce a concept of unstable metadata operations?

