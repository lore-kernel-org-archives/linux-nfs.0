Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f178.google.com ([209.85.223.178]:34626 "EHLO
	mail-ie0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933204AbaKMNiS convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 13 Nov 2014 08:38:18 -0500
Received: by mail-ie0-f178.google.com with SMTP id rp18so15894084iec.9
        for <linux-nfs@vger.kernel.org>; Thu, 13 Nov 2014 05:38:17 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.0 \(1990.1\))
Subject: Re: [PATCH] NFS: fix subtle change in COMMIT behavior
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <20141113110244.GA25709@lst.de>
Date: Thu, 13 Nov 2014 08:38:15 -0500
Cc: Peng Tao <bergwolf@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <6E1CB959-CB60-4AE3-9392-65ABDF0DB2F0@primarydata.com>
References: <1415812080-3033-1-git-send-email-dros@primarydata.com> <CAKVebiX=mRJ7Psc8+FigNLRgGB8vH84vcKdv173HvuT20+eh=w@mail.gmail.com> <20141113110244.GA25709@lst.de>
To: Christoph Hellwig <hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> On Nov 13, 2014, at 6:02 AM, Christoph Hellwig <hch@lst.de> wrote:
> 
> On Thu, Nov 13, 2014 at 09:03:53AM +0800, Peng Tao wrote:
>>> but should be contiguous (as enforced by nfs_flush_incompatible).
>>> 
>> The idea is to get an estimation on the length of layout that client
>> wants to use. So even if a single byte is used by client, client would
>> want to ask for a layout that covers the whole page.
> 
> That code is very non-obvious and could use a few more comments.
> 
> I think the NFS_I(inode)->npages should be replaced with
> inode->i_mapping->nrpages which counts the number of page cache pages.

That sounds reasonable. Can someone track this down? I don’t have a block
server to test against…

Thanks for the help Tao and Christoph!

-dros