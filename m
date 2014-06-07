Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:58932 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752761AbaFGOX3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 7 Jun 2014 10:23:29 -0400
Received: by mail-qa0-f41.google.com with SMTP id dc16so5962876qab.0
        for <linux-nfs@vger.kernel.org>; Sat, 07 Jun 2014 07:23:28 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sat, 7 Jun 2014 10:23:26 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSd: nfs4_preprocess_seqid_op should only set *stpp on
 success
Message-ID: <20140607102326.3b48b558@tlielax.poochiereds.net>
In-Reply-To: <20140607140800.GA18140@infradead.org>
References: <1402080994-23737-1-git-send-email-jlayton@primarydata.com>
	<20140607140800.GA18140@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, 7 Jun 2014 07:08:00 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Fri, Jun 06, 2014 at 02:56:34PM -0400, Jeff Layton wrote:
> > From: Trond Myklebust <trond.myklebust@primarydata.com>
> > 
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> 
> The new code looks correct, but shouldn't callers already take care
> not to use the returned stateid only if nfs4_preprocess_seqid_op returns
> 0?
> 

Yeah, I mentioned that to Bruce on IRC. This is not really a bugfix,
per-se, but more of a defensive coding measure.

-- 
Jeff Layton <jlayton@primarydata.com>
