Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:42146 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751444AbaEFTJ2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 6 May 2014 15:09:28 -0400
Date: Tue, 6 May 2014 15:09:26 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@lst.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: get rid of include/linux/nfsd
Message-ID: <20140506190926.GI18281@fieldses.org>
References: <1399397836-31948-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1399397836-31948-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 06, 2014 at 07:37:12PM +0200, Christoph Hellwig wrote:
> Now that all user-visible headers are in include/uapi there is nothing
> left there which shouldn't rather be under fs/nfsd/.

Makes sense, thanks, applying.

I'll try to get a for-3.16 branch pushed out today or tomorrow.

--b.
