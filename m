Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f47.google.com ([209.85.216.47]:65343 "EHLO
	mail-qa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755754AbaFWQYW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 12:24:22 -0400
Received: by mail-qa0-f47.google.com with SMTP id hw13so5901831qab.34
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 09:24:22 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 23 Jun 2014 12:24:20 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 006/104] NFSd: Add a mutex to protect the NFSv4.0
 open owner replay cache
Message-ID: <20140623122420.4cfa0fb5@tlielax.poochiereds.net>
In-Reply-To: <20140623160549.GD24193@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
	<1403189450-18729-7-git-send-email-jlayton@primarydata.com>
	<20140623160549.GD24193@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Jun 2014 09:05:49 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Jun 19, 2014 at 10:49:12AM -0400, Jeff Layton wrote:
> > From: Trond Myklebust <trond.myklebust@primarydata.com>
> > 
> > We don't want to rely on the state_lock() for protection in the
> > case of NFSv4 open owners. Instead, we add a mutex that will
> > only be taken for NFSv4.0 state mutating operations, and
> > that will be released once the entire compound is done.
> > 
> > Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> 
> Looks reasonable to me, but doesn't this create a lock order reversal
> with the client_lock until it is removed?  
> 

No, I don't think so. AFAICT, the new mutex is always taken inside of
the client_mutex until that point.

-- 
Jeff Layton <jlayton@primarydata.com>
