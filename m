Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:36907 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751796AbaFBITk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jun 2014 04:19:40 -0400
Date: Mon, 2 Jun 2014 01:19:40 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: commit layouts in fdatasync
Message-ID: <20140602081940.GA32300@infradead.org>
References: <20140421172917.GA20036@infradead.org>
 <20140505065624.GA32658@infradead.org>
 <20140527160044.GA17587@infradead.org>
 <CAHQdGtSKHRt3DZad9ezvF0Wx+i5SfQuJTHzHUOOwdgi1GoscKw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtSKHRt3DZad9ezvF0Wx+i5SfQuJTHzHUOOwdgi1GoscKw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 28, 2014 at 07:00:08PM -0400, Trond Myklebust wrote:
> Applied for 3.16. Not sure about -stable eligibility, since this only
> affects pnfs blocks for now (files and objects should both be able to
> recover in case of client failure).

At least the linux-nfs.org object server needs the layoutcommit to
update i_size on the inode, so changes won't be persistent without the
layoutcommit.  I expect loosely coupled file servers to work in a
similar fashion.

> Are you seeing this in production
> environments?

This was found during data integrity testing.

