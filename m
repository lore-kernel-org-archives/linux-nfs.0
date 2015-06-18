Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:45060 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751308AbbFRVTR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Jun 2015 17:19:17 -0400
Date: Thu, 18 Jun 2015 17:19:16 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: stateid handling improvements
Message-ID: <20150618211916.GA21903@fieldses.org>
References: <1434638702-353-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1434638702-353-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 18, 2015 at 04:44:57PM +0200, Christoph Hellwig wrote:
> Ensure that we allocate a file structure in nfs4_preprocess_stateid_op
> for all callers that as for it to consolidate code and fix the handling
> of ALLOCATE, DEALLOCATE and SEEK to match the latest NFSv4.2 drafts.

Those make sense to me, thanks.

Applying pending some testing.

--b.
