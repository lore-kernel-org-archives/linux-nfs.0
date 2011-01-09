Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:38510 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751548Ab1AIUI7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Jan 2011 15:08:59 -0500
Date: Sun, 9 Jan 2011 15:08:56 -0500
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 3/4] locks: eliminate fl_mylease callback
Message-ID: <20110109200856.GA5797@infradead.org>
References: <1294110419-3105-1-git-send-email-bfields@redhat.com>
 <1294110419-3105-4-git-send-email-bfields@redhat.com>
 <20110104060723.GA15158@infradead.org>
 <20110104181815.GB2308@fieldses.org>
 <20110107134015.GA2573@infradead.org>
 <20110109195508.GB26813@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110109195508.GB26813@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Jan 09, 2011 at 02:55:09PM -0500, J. Bruce Fields wrote:
> > I don't think you removed all instances of it yet.  It is still
> > implemented by lease_manager_ops in fs/locks.c
> 
> Argh, yes, I'd forgotten about that.  The original patch is still right,
> so we could just back out the documentation patch, or maybe there's a
> better alternative for the remaining user.

Given that leases are only releases in a few controlled places the
code could probably be moved into those.  But it's probably to risky to
try that so late in the merge window.

