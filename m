Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f181.google.com ([209.85.216.181]:58080 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753909AbaFWQsd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 12:48:33 -0400
Received: by mail-qc0-f181.google.com with SMTP id x13so6307258qcv.12
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 09:48:32 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 23 Jun 2014 12:48:31 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 009/104] locks: add file_has_lease
Message-ID: <20140623124831.2785c803@tlielax.poochiereds.net>
In-Reply-To: <20140623161254.GG24193@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
	<1403189450-18729-10-git-send-email-jlayton@primarydata.com>
	<20140623161254.GG24193@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Jun 2014 09:12:54 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Jun 19, 2014 at 10:49:15AM -0400, Jeff Layton wrote:
> > Add a function that can tell us whether a file description has had a
> > lease set on it.
> 
> The code looks good, but how is this information useful given that it
> will be stable as soon as i_lock is dropped?
> 

The next patch is what uses it. I can squash the two together, but I
figured it was best to keep them separate since we're touching two
different subsystems here.

The basic idea here is to avoid calling vfs_setlease under a spinlock.
The next patch does that and then takes the spinlocks and hash the
delegation once the lease is set.

Problem: what if the delegation got broken before we could hash it?

The workqueue job that's queued by break_deleg will take the state_lock
spinlock before it can unhash the delegation. So, we take the
state_lock and then call file_has_lease. If the lease is still present
then we know that it hasn't been (and won't be) broken before we could
hash it.

-- 
Jeff Layton <jlayton@primarydata.com>
