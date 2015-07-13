Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:52180 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750988AbbGMGmR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 02:42:17 -0400
Date: Sun, 12 Jul 2015 23:42:16 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Steve Dickson <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] blkmapd: Skip the SCSI ID if the data length is zero
Message-ID: <20150713064216.GA31842@infradead.org>
References: <55A2FEE4.6030201@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A2FEE4.6030201@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 13, 2015 at 07:57:24AM +0800, Kinglong Mee wrote:
> In vmware linux, the iscsi device contains more than one SCSI ID,
> and, the second one's data length is zero.
> 
> blkmapd must skip it, otherwise, some device will be treat as the above one.
> 
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

Looks good, but can you please add a comment explaining why you're
skipping the zero-length EVPD page?

