Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f177.google.com ([209.85.160.177]:50095 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753095AbaHYBfF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 24 Aug 2014 21:35:05 -0400
Received: by mail-yk0-f177.google.com with SMTP id 79so9907170ykr.22
        for <linux-nfs@vger.kernel.org>; Sun, 24 Aug 2014 18:35:05 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Sun, 24 Aug 2014 21:35:02 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, bfields@fieldses.org,
        cluster-devel@redhat.com, linux-cifs@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 09/10] locks: move freeing of leases outside of i_lock
Message-ID: <20140824213502.4cab1ba3@synchrony.poochiereds.net>
In-Reply-To: <20140824160804.GH15908@infradead.org>
References: <1408804878-1331-1-git-send-email-jlayton@primarydata.com>
	<1408804878-1331-10-git-send-email-jlayton@primarydata.com>
	<20140824160804.GH15908@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, 24 Aug 2014 09:08:04 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Sat, Aug 23, 2014 at 10:41:17AM -0400, Jeff Layton wrote:
> > There was only one place where we still could free a file_lock while
> > holding the i_lock -- lease_modify. Add a new list_head argument to the
> > lm_change operation, pass in a private list when calling it, and fix
> > those callers to dispose of the list once the lock has been dropped.
> 
> Why do we care about locks held when simply freeing a piece of memory?
> 

That's all that's done now, but locks_free_lock can call
fl->fl_release_private. Currently, no filesystem sets that for leases,
but while we're in here we might as well make it possible for that to
block for all lock types since that's simpler than having different
rules for them.

It doesn't really cost us anything other than a bit of list
manipulation and reduces contention on the i_lock slightly.

-- 
Jeff Layton <jlayton@primarydata.com>
