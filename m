Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:52111 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933491AbaGXPWI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Jul 2014 11:22:08 -0400
Date: Thu, 24 Jul 2014 08:22:03 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        trond.myklebust@primarydata.com
Subject: Re: [PATCH v2 0/4] nfsd: don't let nfs4_file pin down the inode when
 it has no open state
Message-ID: <20140724152203.GA14503@infradead.org>
References: <1406146661-9794-1-git-send-email-jlayton@primarydata.com>
 <20140723204712.GI9118@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140723204712.GI9118@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 23, 2014 at 04:47:12PM -0400, J. Bruce Fields wrote:
> Looks OK to me.  I'll give it a day in case Christoph or someone spots a
> problem.

The series looks fine, but I've not done a detailed review.

