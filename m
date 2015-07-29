Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34344 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752911AbbG2H6w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 29 Jul 2015 03:58:52 -0400
Date: Wed, 29 Jul 2015 00:33:30 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Devesh Sharma <devesh.sharma@avagotech.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1] xprtrdma: take vendor driver refcount at client
Message-ID: <20150729073330.GA13361@infradead.org>
References: <1438173661-12497-1-git-send-email-devesh.sharma@avagotech.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1438173661-12497-1-git-send-email-devesh.sharma@avagotech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Devesh,

I don't understand your use of "vendor driver" here.  It seems your'e
talking about the HCA driver.

