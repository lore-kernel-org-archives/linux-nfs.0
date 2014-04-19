Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:57721 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751046AbaDSOkb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Apr 2014 10:40:31 -0400
Date: Sat, 19 Apr 2014 07:40:30 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 30/70] NFSd: Replace delegation->dl_file with the
 dl_stid.sc_file
Message-ID: <20140419144030.GC25682@infradead.org>
References: <1397846704-14567-22-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Instead of adding a mostly unused file field to the stid in the previous
patch and starting to use it here I'd recommend merging the two patches.

