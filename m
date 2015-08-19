Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:50884 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752717AbbHSHR6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Aug 2015 03:17:58 -0400
Date: Wed, 19 Aug 2015 00:17:57 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSv4.1/pnfs: Fix a close/delegreturn hang when
 return-on-close is set
Message-ID: <20150819071757.GA7393@infradead.org>
References: <1439959019-16805-1-git-send-email-trond.myklebust@primarydata.com>
 <CAHQdGtS4bFB0er8a2Ymepuc73SDeReDKxPdGkOT4UPNv6rNTow@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtS4bFB0er8a2Ymepuc73SDeReDKxPdGkOT4UPNv6rNTow@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 18, 2015 at 09:38:14PM -0700, Trond Myklebust wrote:
> Can you please check if this patch fixes the hang you're seeing?

Your testing branch with the two v2 patches applied fixes it.
