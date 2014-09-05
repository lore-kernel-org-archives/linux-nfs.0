Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f46.google.com ([209.85.216.46]:57188 "EHLO
	mail-qa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932383AbaIEODb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2014 10:03:31 -0400
Received: by mail-qa0-f46.google.com with SMTP id w8so10903888qac.5
        for <linux-nfs@vger.kernel.org>; Fri, 05 Sep 2014 07:03:30 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 5 Sep 2014 10:03:29 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org
Subject: Re: [PATCH v2 11/17] locks: move freeing of leases outside of
 i_lock
Message-ID: <20140905100329.00da1065@tlielax.poochiereds.net>
In-Reply-To: <20140904175014.GE16935@infradead.org>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
	<1409834323-7171-12-git-send-email-jlayton@primarydata.com>
	<20140904175014.GE16935@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 4 Sep 2014 10:50:14 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Sep 04, 2014 at 08:38:37AM -0400, Jeff Layton wrote:
> > There was only one place where we still could free a file_lock while
> > holding the i_lock -- lease_modify. Add a new list_head argument to the
> > lm_change operation, pass in a private list when calling it, and fix
> > those callers to dispose of the list once the lock has been dropped.
> 
> As mentioned I don't see a real need for this, but it does look correct
> to me.
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Yeah, it's not strictly necessary, but I think it simplifies the API
for potential users. We already have the infrastructure to handle
deferring file_lock removal so we might as well take advantage of it
here too.

-- 
Jeff Layton <jlayton@primarydata.com>
