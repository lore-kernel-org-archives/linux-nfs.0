Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f177.google.com ([209.85.223.177]:39803 "EHLO
	mail-ie0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932789AbaJVMA2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Oct 2014 08:00:28 -0400
Received: by mail-ie0-f177.google.com with SMTP id tp5so314424ieb.22
        for <linux-nfs@vger.kernel.org>; Wed, 22 Oct 2014 05:00:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20141022114649.GA2567@infradead.org>
References: <20141020173658.GA7552@infradead.org>
	<20141022114649.GA2567@infradead.org>
Date: Wed, 22 Oct 2014 15:00:27 +0300
Message-ID: <CAABAsM44E-Ly=qPFBA2iBvgkCvA3GE5NRGi=d1hD+Pvk1xzevA@mail.gmail.com>
Subject: Re: xfstests generic/075 failure on recent Linus' tree
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 22, 2014 at 2:46 PM, Christoph Hellwig <hch@infradead.org> wrote:
> On Mon, Oct 20, 2014 at 10:36:58AM -0700, Christoph Hellwig wrote:
>> Running 4.1 against a same host server backed off XFS I run into
>> a hang in generic/075:
>
> I've bisected this down to:
>
> commit 2aca5b869ace67a63aab895659e5dc14c33a4d6e
> Author: Trond Myklebust <trond.myklebust@primarydata.com>
> Date:   Wed Sep 24 22:35:58 2014 -0400
>
>     SUNRPC: Add missing support for RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT
>
>
> Note that I can only reproduce it when running locally, and only when
> not using pNFS (block layout).

Does the NFS client show a TCP connection to port 2049 on 127.0.0.1?

Cheers
  Trond
