Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-lb0-f180.google.com ([209.85.217.180]:56148 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087Ab3GNTkj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 14 Jul 2013 15:40:39 -0400
MIME-Version: 1.0
In-Reply-To: <51DFBD49.7000205@bfs.de>
References: <20130712063903.GB29320@longonot.mountain>
	<51DFBD49.7000205@bfs.de>
Date: Sun, 14 Jul 2013 22:40:37 +0300
Message-ID: <CA+_b7D+2O2E0S4vQY37SZcK3VTPUdd1cP8y9NuZM-HWwP3HNGw@mail.gmail.com>
Subject: Re: [patch -stable] svcrdma: underflow issue in decode_write_list()
From: Dan Carpenter <error27@gmail.com>
To: wharms@bfs.de
Cc: Dan Carpenter <dan.carpenter@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 7/12/13, walter harms <wharms@bfs.de> wrote:

> i am struggling to understand what is actually checked here.
> Perhaps this improves the readability a bit
>  if ( nchunks < 0 ||
>        sizeof(struct rpcrdma_write_chunk) * nchunks > (SIZE_MAX - start) ||

That doesn't work.

This is one of the few times I get to use algebra in real life.  Yay!
The problem is you have to
have the nchunks by itself and the trusted bits on the other side.  So
the multiply becomes a
divide.

There are lots of these checks in the kernel.  It's idiomatic.

regards,
dan carpenter
