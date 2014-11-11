Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:39148 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751218AbaKKQ1I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Nov 2014 11:27:08 -0500
Date: Tue, 11 Nov 2014 17:27:04 +0100
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 2/2] nfsd: implement chage_attr_type attribute
Message-ID: <20141111162704.GA12103@lst.de>
References: <1415448664-25815-1-git-send-email-hch@lst.de> <1415448664-25815-3-git-send-email-hch@lst.de> <20141110175424.GC32702@fieldses.org> <20141111102735.GB17313@lst.de> <CAHQdGtRKj+8HGV4-bFKGAvD+38Vu8MzjBq16wdgaiDmoe2hqiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtRKj+8HGV4-bFKGAvD+38Vu8MzjBq16wdgaiDmoe2hqiQ@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 11, 2014 at 07:36:48AM -0500, Trond Myklebust wrote:
> Just out of curiosity, though, why does XFS update i_version on every
> block allocation? For NFSv4 compatibility, it really should suffice
> for it to just do the update once in the above case. Did Lustre have
> more stringent requirements?

It's literatlly updated everytime inode metadata changes.  Dave implemented
this, so I don't know the real rationale behind it.  I don't think anyone
sane cares about Lustre ever, certainly not for XFS.

