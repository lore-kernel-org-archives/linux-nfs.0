Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43081 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751752Ab1AITzT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 9 Jan 2011 14:55:19 -0500
Date: Sun, 9 Jan 2011 14:55:09 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 3/4] locks: eliminate fl_mylease callback
Message-ID: <20110109195508.GB26813@fieldses.org>
References: <1294110419-3105-1-git-send-email-bfields@redhat.com>
 <1294110419-3105-4-git-send-email-bfields@redhat.com>
 <20110104060723.GA15158@infradead.org>
 <20110104181815.GB2308@fieldses.org>
 <20110107134015.GA2573@infradead.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110107134015.GA2573@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, Jan 07, 2011 at 08:40:15AM -0500, Christoph Hellwig wrote:
> On Tue, Jan 04, 2011 at 01:18:16PM -0500, J. Bruce Fields wrote:
> > Whoops, thanks for the reminder.
> > 
> > Looks like we never added fl_mylease?
> 
> I actually addded it recently, but it seems like you're based on an
> older tree.

Whoops, I'll probably resolve that before submitting a pull request....

> > That leaves the fl_release_private patch, updated as follows.
> 
> I don't think you removed all instances of it yet.  It is still
> implemented by lease_manager_ops in fs/locks.c

Argh, yes, I'd forgotten about that.  The original patch is still right,
so we could just back out the documentation patch, or maybe there's a
better alternative for the remaining user.

--b.
