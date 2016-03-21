Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:59289 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755999AbcCUPaP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Mar 2016 11:30:15 -0400
Date: Mon, 21 Mar 2016 08:30:14 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Peng Tao <tao.peng@primarydata.com>
Subject: Re: [PATCH] nfs/blocklayout: make sure making a aligned read request
Message-ID: <20160321153014.GA18948@infradead.org>
References: <56BF34E3.1020003@gmail.com>
 <20160229095756.GA19397@infradead.org>
 <56D432D5.7000905@gmail.com>
 <20160229133439.GA4416@infradead.org>
 <56D58CAC.7010603@gmail.com>
 <CAHQdGtQWxv1vzC_o8x3JSFyW3tMYihF1rcmFGBsGEpddLabejA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtQWxv1vzC_o8x3JSFyW3tMYihF1rcmFGBsGEpddLabejA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 16, 2016 at 03:41:06PM -0400, Trond Myklebust wrote:
> Christoph, does Kinglong's explanation satisfy your concerns, or are
> there still unresolved differences that should prevent me from taking
> this patch?

I still don't think it's the right thing to do, but I don't have time
time to debug the issue fully myself.  Let's take the patch for now
as it should be less harmful than not having it.
