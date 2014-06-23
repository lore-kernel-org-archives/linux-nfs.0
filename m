Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:55579 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753176AbaFWRSS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 13:18:18 -0400
Date: Mon, 23 Jun 2014 10:18:15 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 007/104] NFSd: Add locking to the nfs4_file->fi_fds[]
 array
Message-ID: <20140623171815.GA2591@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
 <1403189450-18729-8-git-send-email-jlayton@primarydata.com>
 <20140623160636.GE24193@infradead.org>
 <20140623131431.71d632ff@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140623131431.71d632ff@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 23, 2014 at 01:14:31PM -0400, Jeff Layton wrote:
> I saw your comments and even did some experimentation to that end.
> After playing around with some patches that tried to use FMODE flags
> instead, I tossed them out. It may have consolidated the code a bit, but
> the result was just too difficult to follow. I think it's better to go
> with clearer code here, even if it's a little more verbose.

ok..

