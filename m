Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f182.google.com ([209.85.216.182]:53979 "EHLO
	mail-qc0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755896AbaFWQUm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 12:20:42 -0400
Received: by mail-qc0-f182.google.com with SMTP id m20so6258822qcx.13
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 09:20:41 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 23 Jun 2014 12:20:39 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 005/104] NFSd: Add fine grained protection for the
 nfs4_file->fi_stateids list
Message-ID: <20140623122039.78056ec9@tlielax.poochiereds.net>
In-Reply-To: <20140623160407.GC24193@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
	<1403189450-18729-6-git-send-email-jlayton@primarydata.com>
	<20140623160407.GC24193@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Jun 2014 09:04:07 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Jun 19, 2014 at 10:49:11AM -0400, Jeff Layton wrote:
> > From: Trond Myklebust <trond.myklebust@primarydata.com>
> > 
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> Looks good, but should have a patch description that better tells
> why this is done (looks like preparing for nfs_lock_state() removal
> again, not fixing some existing race)
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Correct. I'll add that into the desciption if you think it's warranted,
but again that's the case with many of the patches in this series.

-- 
Jeff Layton <jlayton@primarydata.com>
