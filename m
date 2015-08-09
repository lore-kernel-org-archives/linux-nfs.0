Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47133 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932482AbbHIHVz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Aug 2015 03:21:55 -0400
Date: Sun, 9 Aug 2015 00:21:55 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 15/18] nfsd: have set_version_and_fsid_type take a
 knfsd_fh instead of svc_fh
Message-ID: <20150809072155.GG9772@infradead.org>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-16-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1438809216-4846-16-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Aug 05, 2015 at 05:13:33PM -0400, Jeff Layton wrote:
> Note however that we do still have it take a svc_fh for the ref_fh, but
> that could be changed in the future if it's helpful to do so.
> 
> Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>
