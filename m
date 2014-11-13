Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:43638 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933277AbaKMNiw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 13 Nov 2014 08:38:52 -0500
Date: Thu, 13 Nov 2014 14:38:50 +0100
From: Christoph Hellwig <hch@lst.de>
To: Weston Andros Adamson <dros@primarydata.com>
Cc: Peng Tao <bergwolf@primarydata.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFS: fix subtle change in COMMIT behavior
Message-ID: <20141113133850.GA6325@lst.de>
References: <1415812080-3033-1-git-send-email-dros@primarydata.com> <CAKVebiX=mRJ7Psc8+FigNLRgGB8vH84vcKdv173HvuT20+eh=w@mail.gmail.com> <20141113110244.GA25709@lst.de> <6E1CB959-CB60-4AE3-9392-65ABDF0DB2F0@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <6E1CB959-CB60-4AE3-9392-65ABDF0DB2F0@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 13, 2014 at 08:38:15AM -0500, Weston Andros Adamson wrote:
> That sounds reasonable. Can someone track this down? I don’t have a block
> server to test against…
> 
> Thanks for the help Tao and Christoph!

I will give that variant a spin on my test setup.
