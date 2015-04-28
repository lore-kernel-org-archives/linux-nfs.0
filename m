Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:42254 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030316AbbD1SLP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 28 Apr 2015 14:11:15 -0400
Date: Tue, 28 Apr 2015 20:11:13 +0200
From: Christoph Hellwig <hch@lst.de>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Sachin Bhamare <sachin.bhamare@primarydata.com>,
        Jeff Layton <jlayton@primarydata.com>
Subject: Re: [PATCH 2/2] nfsd: fix pNFS return on close semantics
Message-ID: <20150428181113.GA6183@lst.de>
References: <1430139014-28013-1-git-send-email-hch@lst.de> <1430139014-28013-3-git-send-email-hch@lst.de> <20150427203943.GI4083@fieldses.org> <20150427193008.1195d7dd@tlielax.poochiereds.net> <20150428081456.GA21413@lst.de> <20150428160353.GN4083@fieldses.org> <20150428174934.GA5887@lst.de> <CAHQdGtQfM3jOi5Ydu1MAhCe8J=XQ7aHDPPVZFpC_zTGZ+2G0eg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQfM3jOi5Ydu1MAhCe8J=XQ7aHDPPVZFpC_zTGZ+2G0eg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Apr 28, 2015 at 01:54:31PM -0400, Trond Myklebust wrote:
> The main reason why you may want these patches is that without
> return-on-close, you typically can end up with layouts being cached in
> knfsd without the filesystem being pinned. When you then unmount the
> filesystem...

Each layout has a reference on the layout state, and each layout state
has a struct file reference.
