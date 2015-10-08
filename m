Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:39915 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbbJHIBD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Oct 2015 04:01:03 -0400
Date: Thu, 8 Oct 2015 01:01:03 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Sagi Grimberg <sagig@mellanox.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 00/26] New fast registration API
Message-ID: <20151008080103.GA29235@infradead.org>
References: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1444290669-5252-1-git-send-email-sagig@mellanox.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 08, 2015 at 10:50:43AM +0300, Sagi Grimberg wrote:
> - Rebased against Doug's for-4.4 tree (4.3.0-rc1) + 4.3-rc fixes

Does this means its not on top of the send_wr changes now?  I'm fine
with that as I think your series is even more important than the send_wr
split and I'm happy to rebase, but I'd also really like to see some
progress on them..
