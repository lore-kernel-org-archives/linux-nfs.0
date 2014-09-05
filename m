Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:53452 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069AbaIELsa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 5 Sep 2014 07:48:30 -0400
Received: by mail-qc0-f171.google.com with SMTP id x3so12094259qcv.16
        for <linux-nfs@vger.kernel.org>; Fri, 05 Sep 2014 04:48:29 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Fri, 5 Sep 2014 07:48:27 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Devel FS Linux <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        Steven Whitehouse <swhiteho@redhat.com>,
        cluster-devel <cluster-devel@redhat.com>,
        samba-technical@lists.samba.org
Subject: Re: [PATCH v2 01/17] locks: consolidate "nolease" routines
Message-ID: <20140905074827.62a5048a@tlielax.poochiereds.net>
In-Reply-To: <20140904201200.GA26054@infradead.org>
References: <1409834323-7171-1-git-send-email-jlayton@primarydata.com>
	<1409834323-7171-2-git-send-email-jlayton@primarydata.com>
	<CAHQdGtTqG8aW-cte2PW6pVw+OeCXATgr1BZwdhponuWMjzNg8g@mail.gmail.com>
	<20140904084938.2664bf0a@tlielax.poochiereds.net>
	<CAABAsM6v3-f_7cco8f_F5Wpy7PWJOUywQHH7A=mZ-LyHRASZ7Q@mail.gmail.com>
	<20140904201200.GA26054@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 4 Sep 2014 13:12:00 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> On Thu, Sep 04, 2014 at 02:25:35PM -0400, Trond Myklebust wrote:
> > Actually, it looks as if when you compile with !CONFIG_FILE_LOCKING,
> > then fcntl_setlease() returns the value '0' (which would be
> > "success!"). The word "confusing" only begins to describe it all.
> 
> That's incorrect for sure, we should agree on a single sensible code
> for:
> 
>  1) !CONFIG_FILE_LOCKING
>  2) !lease_enable
>  3) filesystem doesn't support leases.
> 

Agreed. I think -ENOLCK is really better than -EINVAL.

I usually take -EINVAL to mean "you sent me something bogus". Whereas
-ENOLCK just says "locking doesn't work". -ENOLCK seems closer to the
situation in all 3 cases above.

That said, this is a user-visible change. The main userland consumer of
leases (AFAIK) is samba, so I'll take a peek at that code and run it by
them before merging anything.

-- 
Jeff Layton <jlayton@primarydata.com>
