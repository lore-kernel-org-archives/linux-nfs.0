Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:47072 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932482AbbHIHVO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 9 Aug 2015 03:21:14 -0400
Date: Sun, 9 Aug 2015 00:21:13 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jlayton@poochiereds.net>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v2 14/18] nfsd: have _fh_update take a knfsd_fh instead
 of a svc_fh
Message-ID: <20150809072113.GF9772@infradead.org>
References: <1438264341-18048-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-1-git-send-email-jeff.layton@primarydata.com>
 <1438809216-4846-15-git-send-email-jeff.layton@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1438809216-4846-15-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks fine,

Reviewed-by: Christoph Hellwig <hch@lst.de>

Can you maybe rename it to __fh_update to fit the normal naming scheme
in the kernel while you're at it?
