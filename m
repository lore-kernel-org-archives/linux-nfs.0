Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:37489 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938AbaEIHeK (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 May 2014 03:34:10 -0400
Date: Fri, 9 May 2014 00:34:04 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruce Fields <bfields@fieldses.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 29/70] NFSd: Add a struct nfs4_file field to struct
 nfs4_stid
Message-ID: <20140509073404.GA30366@infradead.org>
References: <1397846704-14567-23-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-24-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-25-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
 <20140507192534.GD8324@fieldses.org>
 <CAHQdGtS1fidn=zbUKqS39EGy-HK2GDxM6Ho_QnsFpo9rEcAuaw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtS1fidn=zbUKqS39EGy-HK2GDxM6Ho_QnsFpo9rEcAuaw@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 08, 2014 at 03:40:49PM -0400, Trond Myklebust wrote:
> On Wed, May 7, 2014 at 3:25 PM, Bruce Fields <bfields@fieldses.org> wrote:
> > We're adding a put without adding a corresponding get, so was there a
> > leak before this patch?
> 
> No. The struct sc_file is added by this patch, and since the entire
> stid is zeroed on allocation (through the use of kmem_cache_zalloc),
> it is safe to add the put() in this patch.

It's safe, but it would still be nicer to have a single patch that just
moves the file from the delegation to the generic stateid.

