Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:46802 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751734AbaDUNQg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 09:16:36 -0400
Date: Mon, 21 Apr 2014 06:16:35 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, Bruce Fields <bfields@fieldses.org>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 15/70] NFSd: Add locking to the nfs4_file->fi_fds[] array
Message-ID: <20140421131635.GA830@infradead.org>
References: <1397846704-14567-10-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-11-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-12-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-13-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-14-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-15-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-16-git-send-email-trond.myklebust@primarydata.com>
 <20140419143549.GA25682@infradead.org>
 <1398085297.2891.8.camel@leira.trondhjem.org>
 <20140421131412.GB24289@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140421131412.GB24289@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Apr 21, 2014 at 06:14:12AM -0700, Christoph Hellwig wrote:
> One option would be:

Doesn't work because O_RDONLY is defined as 0.  But if we use
FMODE_READ and FMODE_WRITE as flag it should work.

