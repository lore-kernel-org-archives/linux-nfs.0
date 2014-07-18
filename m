Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:54585 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S935058AbaGRRYL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 18 Jul 2014 13:24:11 -0400
Date: Fri, 18 Jul 2014 10:24:10 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, hch@infradead.org, linux-nfs@vger.kernel.org,
        Neil Brown <neilb@suse.de>
Subject: Re: [PATCH v4 10/10] nfsd: give block_delegation and
 delegation_blocked its own spinlock
Message-ID: <20140718172410.GA26872@infradead.org>
References: <1405696416-32585-1-git-send-email-jlayton@primarydata.com>
 <1405696416-32585-11-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1405696416-32585-11-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
