Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:43934 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752828AbaHLPxZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 11:53:25 -0400
Date: Tue, 12 Aug 2014 17:53:22 +0200
From: Christoph Hellwig <hch@lst.de>
To: Boaz Harrosh <openosd@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/4] pnfs: factor GETDEVICEINFO implementations
Message-ID: <20140812155322.GA32092@lst.de>
References: <1407787617-26050-1-git-send-email-hch@lst.de> <1407787617-26050-2-git-send-email-hch@lst.de> <53E9FC57.9010806@gmail.com> <20140812122156.GA16362@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140812122156.GA16362@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Ok, I've pushed a commit to implement the max_getdeviceinfo_size
field out.

