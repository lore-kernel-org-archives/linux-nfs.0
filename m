Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:56912 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751345AbaGJKvo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2014 06:51:44 -0400
Date: Thu, 10 Jul 2014 03:51:43 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v4 018/100] nfsd: cleanup and rename nfs4_check_open
Message-ID: <20140710105143.GA21461@infradead.org>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
 <1404842668-22521-19-git-send-email-jlayton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1404842668-22521-19-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 08, 2014 at 02:03:06PM -0400, Jeff Layton wrote:
> Rename it to better describe what it does, and have it just return the
> stateid instead of a __be32 (which is now always nfs_ok). Also, do the
> search for an existing stateid after the delegation check, to reduce
> cleanup if the delegation check returns error.
> 
> Signed-off-by: Jeff Layton <jlayton@primarydata.com>

Looks good,

Reviewed-by: Christoph Hellwig <hch@lst.de>
