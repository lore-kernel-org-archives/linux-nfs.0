From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Implementation of delegation
Date: Mon, 12 Jul 2010 17:48:12 -0400
Message-ID: <1278971292.14605.2.camel@heimdal.trondhjem.org>
References: <AANLkTik1dbBEnyqMEw9snDhjglJiDQJKs4dFdenqXaGJ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: Yudong Gao <stgyd@umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:59766 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754379Ab0GLVsS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jul 2010 17:48:18 -0400
In-Reply-To: <AANLkTik1dbBEnyqMEw9snDhjglJiDQJKs4dFdenqXaGJ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2010-07-12 at 14:37 -0700, Yudong Gao wrote:
> Hi,
> 
> I am reading the NFS source code of the file open function in kernel
> 2.6.34, but I cannot find any implementation with delegation to allow
> client to open a file locally without contacting the server. We are
> tying to use delegation to do something interesting. So I am wondering
> how much delegation support specified in the NFS 4.1 protocol is
> available in the current Linux implementation?

What's wrong with nfs4_try_open_cached()? It even works with NFSv4.0...

Trond

