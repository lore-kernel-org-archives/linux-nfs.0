Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:51908 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755210AbaIDUMA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Sep 2014 16:12:00 -0400
Date: Thu, 4 Sep 2014 13:12:00 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Steven Whitehouse <swhiteho@redhat.com>,
        cluster-devel <cluster-devel@redhat.com>
Subject: Re: [PATCH v2 01/17] locks: consolidate "nolease" routines
Message-ID: <20140904201200.GA26054@infradead.org>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
 <1409834323-7171-2-git-send-email-jlayton@primarydata.com>
 <CAHQdGtTqG8aW-cte2PW6pVw+OeCXATgr1BZwdhponuWMjzNg8g@mail.gmail.com>
 <20140904084938.2664bf0a@tlielax.poochiereds.net>
 <CAABAsM6v3-f_7cco8f_F5Wpy7PWJOUywQHH7A=mZ-LyHRASZ7Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAABAsM6v3-f_7cco8f_F5Wpy7PWJOUywQHH7A=mZ-LyHRASZ7Q@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 04, 2014 at 02:25:35PM -0400, Trond Myklebust wrote:
> Actually, it looks as if when you compile with !CONFIG_FILE_LOCKING,
> then fcntl_setlease() returns the value '0' (which would be
> "success!"). The word "confusing" only begins to describe it all.

That's incorrect for sure, we should agree on a single sensible code
for:

 1) !CONFIG_FILE_LOCKING
 2) !lease_enable
 3) filesystem doesn't support leases.

