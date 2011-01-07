Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33065 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753417Ab1AGNkS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Jan 2011 08:40:18 -0500
Date: Fri, 7 Jan 2011 08:40:15 -0500
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 3/4] locks: eliminate fl_mylease callback
Message-ID: <20110107134015.GA2573@infradead.org>
References: <1294110419-3105-1-git-send-email-bfields@redhat.com>
 <1294110419-3105-4-git-send-email-bfields@redhat.com>
 <20110104060723.GA15158@infradead.org>
 <20110104181815.GB2308@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110104181815.GB2308@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Jan 04, 2011 at 01:18:16PM -0500, J. Bruce Fields wrote:
> Whoops, thanks for the reminder.
> 
> Looks like we never added fl_mylease?

I actually addded it recently, but it seems like you're based on an
older tree.

> That leaves the fl_release_private patch, updated as follows.

I don't think you removed all instances of it yet.  It is still
implemented by lease_manager_ops in fs/locks.c
