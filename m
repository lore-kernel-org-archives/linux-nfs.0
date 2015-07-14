Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:57313 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751503AbbGNHPi (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jul 2015 03:15:38 -0400
Date: Tue, 14 Jul 2015 00:15:37 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Steve Dickson <SteveD@redhat.com>, Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3] blkmapd: Skip the SCSI ID if data length is zero
Message-ID: <20150714071537.GB31117@infradead.org>
References: <55A2FEE4.6030201@gmail.com>
 <20150713064216.GA31842@infradead.org>
 <55A375A1.4000800@gmail.com>
 <20150713090142.GA28557@infradead.org>
 <55A380A5.20009@gmail.com>
 <55A38C1C.3030600@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <55A38C1C.3030600@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> +		/* Needs an SCSI ID with unique date not zero length */
> +		if (!dev_id->len)
> +			continue;

That explains what the code does, not why it does so.

How about:

		/*
		 * Some buggy targets (e.g. VMWare) export zero length
		 * EVPD pages, skip them to not confuse the device id
		 * cache.
		 */

