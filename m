Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f177.google.com ([209.85.213.177]:47051 "EHLO
	mail-ig0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964887AbaKNPCp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Nov 2014 10:02:45 -0500
Received: by mail-ig0-f177.google.com with SMTP id uq10so370343igb.16
        for <linux-nfs@vger.kernel.org>; Fri, 14 Nov 2014 07:02:44 -0800 (PST)
Content-Type: text/plain; charset=us-ascii
Mime-Version: 1.0 (Mac OS X Mail 8.0 \(1990.1\))
Subject: Re: [PATCH] NFS: fix subtle change in COMMIT behavior
From: Weston Andros Adamson <dros@primarydata.com>
In-Reply-To: <20141114070401.GA3944@lst.de>
Date: Fri, 14 Nov 2014 10:02:42 -0500
Cc: Peng Tao <bergwolf@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <95762566-245D-433D-828A-E4608F3C72F1@primarydata.com>
References: <1415812080-3033-1-git-send-email-dros@primarydata.com> <CAKVebiX=mRJ7Psc8+FigNLRgGB8vH84vcKdv173HvuT20+eh=w@mail.gmail.com> <20141113110244.GA25709@lst.de> <6E1CB959-CB60-4AE3-9392-65ABDF0DB2F0@primarydata.com> <20141114070401.GA3944@lst.de>
To: Christoph Hellwig <hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> 
> On Nov 14, 2014, at 2:04 AM, Christoph Hellwig <hch@lst.de> wrote:
> 
> The patch below passes block layout testing for me:
> <0001-pnfs-blocklayout-fix-end-calculation-in-pnfs_num_con.patch>

Great! That seems like a cleaner solution to me.

Trond - There will be a minor conflict with my patch, but it should be very
easy to fix.

-dros
