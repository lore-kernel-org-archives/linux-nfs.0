Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:36922 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755806AbaFWQZB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 12:25:01 -0400
Received: by mail-qc0-f171.google.com with SMTP id w7so6178639qcr.2
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 09:25:00 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 23 Jun 2014 12:24:58 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: Jeff Layton <jeff.layton@primarydata.com>, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 005/104] NFSd: Add fine grained protection for the
 nfs4_file->fi_stateids list
Message-ID: <20140623122458.655c431e@tlielax.poochiereds.net>
In-Reply-To: <20140623162332.GA22250@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
	<1403189450-18729-6-git-send-email-jlayton@primarydata.com>
	<20140623160407.GC24193@infradead.org>
	<20140623122039.78056ec9@tlielax.poochiereds.net>
	<20140623162332.GA22250@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Jun 2014 09:23:32 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Mon, Jun 23, 2014 at 12:20:39PM -0400, Jeff Layton wrote:
> > Correct. I'll add that into the desciption if you think it's warranted,
> > but again that's the case with many of the patches in this series.
> 
> It might be fairly obvious in the context of the series, it's not
> if someone goes back in history with a git-blame.
> 
> And it's not a 100% obvious with the series either, at least earlier
> versions also fixes pre-existing races, although all of that might be
> upstream now.
> 
> So as far as I am concerned a simple one-line blurb mentioning what
> the new locking is for would be useful to be added to all patches
> just changing the locking.

Fair enough. I'll do that.

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
