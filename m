Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f176.google.com ([209.85.223.176]:35651 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750768AbaKXWEg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 24 Nov 2014 17:04:36 -0500
Received: by mail-ie0-f176.google.com with SMTP id tr6so2063950ieb.7
        for <linux-nfs@vger.kernel.org>; Mon, 24 Nov 2014 14:04:35 -0800 (PST)
Message-ID: <1416866672.3523.1.camel@leira.trondhjem.org>
Subject: Re: [PATCH] NFS: fix subtle change in COMMIT behavior
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Weston Andros Adamson <dros@primarydata.com>,
        Peng Tao <bergwolf@primarydata.com>,
        linux-nfs list <linux-nfs@vger.kernel.org>
Date: Mon, 24 Nov 2014 17:04:32 -0500
In-Reply-To: <20141114070401.GA3944@lst.de>
References: <1415812080-3033-1-git-send-email-dros@primarydata.com>
	 <CAKVebiX=mRJ7Psc8+FigNLRgGB8vH84vcKdv173HvuT20+eh=w@mail.gmail.com>
	 <20141113110244.GA25709@lst.de>
	 <6E1CB959-CB60-4AE3-9392-65ABDF0DB2F0@primarydata.com>
	 <20141114070401.GA3944@lst.de>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2014-11-14 at 08:04 +0100, Christoph Hellwig wrote:
> The patch below passes block layout testing for me:

Hmm... Are you sure? It didn't compile for me, due to the misspelled
'nrpages'.

-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


