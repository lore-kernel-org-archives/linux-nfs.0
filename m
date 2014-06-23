Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:40610 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755815AbaFWQXd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 12:23:33 -0400
Date: Mon, 23 Jun 2014 09:23:32 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 005/104] NFSd: Add fine grained protection for the
 nfs4_file->fi_stateids list
Message-ID: <20140623162332.GA22250@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
 <1403189450-18729-6-git-send-email-jlayton@primarydata.com>
 <20140623160407.GC24193@infradead.org>
 <20140623122039.78056ec9@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140623122039.78056ec9@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 23, 2014 at 12:20:39PM -0400, Jeff Layton wrote:
> Correct. I'll add that into the desciption if you think it's warranted,
> but again that's the case with many of the patches in this series.

It might be fairly obvious in the context of the series, it's not
if someone goes back in history with a git-blame.

And it's not a 100% obvious with the series either, at least earlier
versions also fixes pre-existing races, although all of that might be
upstream now.

So as far as I am concerned a simple one-line blurb mentioning what
the new locking is for would be useful to be added to all patches
just changing the locking.
