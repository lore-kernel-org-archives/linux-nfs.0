Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:41785 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752537AbaIGQ5H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 7 Sep 2014 12:57:07 -0400
Date: Sun, 7 Sep 2014 18:57:03 +0200
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/2] nfs: update time staps on truncate
Message-ID: <20140907165703.GA21500@lst.de>
References: <1410104201-32517-1-git-send-email-hch@lst.de> <1410104201-32517-2-git-send-email-hch@lst.de> <CAHQdGtTe_mi_0N6hGApfrx_3TtL7=btWZNc9wd3hrkMdLRVfzQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtTe_mi_0N6hGApfrx_3TtL7=btWZNc9wd3hrkMdLRVfzQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Sep 07, 2014 at 12:41:28PM -0400, Trond Myklebust wrote:
> I'm still confused as to why we need this change to the client. In
> RFC5661, Section 18.30.4 there is wording to the effect that:
> 
>    Changing the size of a file with SETATTR indirectly changes the
>    time_modify and change attributes.  A client must account for this as
>    size changes can result in data deletion.
> 
> There is similar wording in RFC3530 and even in RFC1813 (see section
> 3.3.2). Without this sort of guarantee by the server, you could, for
> instance, get into nasty situations where the file changes, but the
> NFSv3 client doesn't detect it.
> 
> So basically, I interpret the spec is saying that we should be able to
> rely on the server figuring this out all by itself. I agree that we
> have the special corner case of ftruncate(), but the VFS is still
> setting the ATTR_CTIME|ATTR_MTIME flags for us in that case, right?

Yes.  Looks like the problem is on the server side indeed.  nfsd_setattr
adds a non-conditional ATTR_CTIME for all calls, but never adds ATTR_MTIME
for ATTR_SIZE requests.  I'll send a server patch instead.

[patch 1 in the series still seems worthwhile for the client, though]
