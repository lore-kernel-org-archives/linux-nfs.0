Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f174.google.com ([209.85.220.174]:54966 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752877AbaIIOlc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Sep 2014 10:41:32 -0400
Received: by mail-vc0-f174.google.com with SMTP id hy10so2707456vcb.5
        for <linux-nfs@vger.kernel.org>; Tue, 09 Sep 2014 07:41:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140909055307.GA12536@lst.de>
References: <1408637375-11343-1-git-send-email-hch@lst.de>
	<1408637375-11343-8-git-send-email-hch@lst.de>
	<CAHQdGtQcukSsVFxHwYyjeHk9RkwyT4+qR1buwydULgciAtrndA@mail.gmail.com>
	<20140909055307.GA12536@lst.de>
Date: Tue, 9 Sep 2014 07:41:31 -0700
Message-ID: <CAHQdGtS0YL=bk2EYW3z-n1dnfCNbaUjjnvLS6ZTi0sNQP8sNrQ@mail.gmail.com>
Subject: Re: [PATCH 07/19] pnfs: add flag to force read-modify-write in ->write_begin
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Sep 8, 2014 at 10:53 PM, Christoph Hellwig <hch@lst.de> wrote:
> On Mon, Sep 08, 2014 at 08:50:13PM -0700, Trond Myklebust wrote:
>> This doesn't look as if it will compile without IS_ENABLED(CONFIG_NFS_V4).
>
> Indeed it doesn't.  I've added an inline wrapper similar to the other
> PNFS layoutdriver checks.
>

Cool. Thanks!

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
