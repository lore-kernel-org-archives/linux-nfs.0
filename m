Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:52106 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751320AbcGSD6p (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 18 Jul 2016 23:58:45 -0400
Date: Mon, 18 Jul 2016 20:58:43 -0700
From: "hch@infradead.org" <hch@infradead.org>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "hch@infradead.org" <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v4 24/28] NFS: Getattr doesn't require data sync semantics
Message-ID: <20160719035843.GA24437@infradead.org>
References: <1467844205-76852-19-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-20-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-21-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-22-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-23-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-24-git-send-email-trond.myklebust@primarydata.com>
 <1467844205-76852-25-git-send-email-trond.myklebust@primarydata.com>
 <20160718034847.GA1195@infradead.org>
 <A9C18137-87A3-4652-ADD6-E8E1C4BAE27B@primarydata.com>
 <1468817945.5273.2.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1468817945.5273.2.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jul 18, 2016 at 04:59:09AM +0000, Trond Myklebust wrote:
> Actually... The problem might be that a previous attribute update is
> marking the attribute cache as being revalidated. Does the following
> patch help?

It doesn't.  Also with your most recent linux-next branch the test
now cause the systems to OOM with or without your patch (with mine it's
still fine).  I tested with your writeback branch from about two or
three days ago before, and with that + your patch it also 'just fails'
and doesn't OOM.  Looks like whatever causes the bug also creates
a temporarily memory leak when combined with recent changes from your
tree, most likely something from the pnfs branch.
