Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45479 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbbCYImh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 25 Mar 2015 04:42:37 -0400
Date: Wed, 25 Mar 2015 01:42:35 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Steve Dickson <SteveD@redhat.com>, rees@umich.edu,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] blkmapd: Make sure device root contains valid device id
Message-ID: <20150325084235.GB25682@infradead.org>
References: <550EC233.9090908@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <550EC233.9090908@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 22, 2015 at 09:22:59PM +0800, Kinglong Mee wrote:
> When testing pnfs in virtual linux based on VirtualBox,
> blkmapd gets dev_root->len == 0, which causes it Segmentation fault.

VirtualBox learly returns bogus values here, but it's always better to
be defensive, so:

Reviewed-by: Christoph Hellwig <hch@lst.de>
