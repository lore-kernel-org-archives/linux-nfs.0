Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pa0-f51.google.com ([209.85.220.51]:43153 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750947AbaKXXrb convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Nov 2014 18:47:31 -0500
Received: by mail-pa0-f51.google.com with SMTP id ey11so10447680pad.24
        for <linux-nfs@vger.kernel.org>; Mon, 24 Nov 2014 15:47:30 -0800 (PST)
Content-Type: text/plain; charset=utf-8
Mime-Version: 1.0 (Mac OS X Mail 8.1 \(1993\))
Subject: Re: [PATCH] NFS: fix subtle change in COMMIT behavior
From: Tom Haynes <thomas.haynes@primarydata.com>
In-Reply-To: <1416866672.3523.1.camel@leira.trondhjem.org>
Date: Mon, 24 Nov 2014 15:47:28 -0800
Cc: Christoph Hellwig <hch@lst.de>, Dros Adamson <dros@primarydata.com>,
        Peng Tao <bergwolf@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Message-Id: <F7789C09-3BFA-4574-9E20-2CBB23371AF3@primarydata.com>
References: <1415812080-3033-1-git-send-email-dros@primarydata.com> <CAKVebiX=mRJ7Psc8+FigNLRgGB8vH84vcKdv173HvuT20+eh=w@mail.gmail.com> <20141113110244.GA25709@lst.de> <6E1CB959-CB60-4AE3-9392-65ABDF0DB2F0@primarydata.com> <20141114070401.GA3944@lst.de> <1416866672.3523.1.camel@leira.trondhjem.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sure it isn’t you?

You also had “issues” with Anna’s patch.

Just saying!

> On Nov 24, 2014, at 2:04 PM, Trond Myklebust <trond.myklebust@primarydata.com> wrote:
> 
> On Fri, 2014-11-14 at 08:04 +0100, Christoph Hellwig wrote:
>> The patch below passes block layout testing for me:
> 
> Hmm... Are you sure? It didn't compile for me, due to the misspelled
> 'nrpages'.
> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer, PrimaryData
> trond.myklebust@primarydata.com
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

