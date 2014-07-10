Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:58421 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225AbaGJHkl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 03:40:41 -0400
Date: Thu, 10 Jul 2014 00:40:36 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Christoph Hellwig <hch@infradead.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 003/114] nfsd: wait to initialize work struct just
 prior to using it
Message-ID: <20140710074036.GA26217@infradead.org>
References: <1404143423-24381-1-git-send-email-jlayton@primarydata.com>
 <1404143423-24381-4-git-send-email-jlayton@primarydata.com>
 <20140708211133.GA26851@fieldses.org>
 <20140709082121.GA30099@infradead.org>
 <20140709194114.GC26851@fieldses.org>
 <20140709163744.1aa6126c@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140709163744.1aa6126c@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 09, 2014 at 04:37:44PM -0400, Jeff Layton wrote:
> I didn't see where you had reverted the patch in your repo, so I went
> ahead and did it and then rebased the series on top of the revert.
> There were some merge conflicts, but I at least was able to get rid of
> the double INIT_WORK calls in the case of a delegation (and do some
> related cleanup in this area):

This looks reasonable to me.

