Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:45603 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932115AbaIIFxK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Sep 2014 01:53:10 -0400
Date: Tue, 9 Sep 2014 07:53:07 +0200
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 07/19] pnfs: add flag to force read-modify-write in
	->write_begin
Message-ID: <20140909055307.GA12536@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de> <1408637375-11343-8-git-send-email-hch@lst.de> <CAHQdGtQcukSsVFxHwYyjeHk9RkwyT4+qR1buwydULgciAtrndA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQcukSsVFxHwYyjeHk9RkwyT4+qR1buwydULgciAtrndA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 08, 2014 at 08:50:13PM -0700, Trond Myklebust wrote:
> This doesn't look as if it will compile without IS_ENABLED(CONFIG_NFS_V4).

Indeed it doesn't.  I've added an inline wrapper similar to the other
PNFS layoutdriver checks.

