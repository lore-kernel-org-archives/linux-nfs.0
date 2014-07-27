Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f179.google.com ([209.85.220.179]:39972 "EHLO
	mail-vc0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751876AbaG0PPl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 27 Jul 2014 11:15:41 -0400
Received: by mail-vc0-f179.google.com with SMTP id hq11so9972974vcb.38
        for <linux-nfs@vger.kernel.org>; Sun, 27 Jul 2014 08:15:40 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140727131949.GB32153@infradead.org>
References: <20140726162143.GB20396@n2100.arm.linux.org.uk>
	<20140727131949.GB32153@infradead.org>
Date: Sun, 27 Jul 2014 11:15:40 -0400
Message-ID: <CAHQdGtQhEQiuObg48JrNbK5L6=r0mxfSvErVC0JS4TqxxbJy_w@mail.gmail.com>
Subject: Re: [BUG] nfs3_list_one_acl oops
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
        Christoph Hellwig <hch@lst.de>,
        Linux Kernel mailing list <linux-kernel@vger.kernel.org>,
        linux-arm-kernel@lists.infradead.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Stable Tree <stable@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Jul 27, 2014 at 9:19 AM, Christoph Hellwig <hch@infradead.org> wrote:
> Thanks Russell, the patch looks good.

No. It needs to use an IS_ERR_OR_NULL() test at least in order to work
correctly.

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
