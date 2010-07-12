Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:40606 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754874Ab0GLWIE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 Jul 2010 18:08:04 -0400
Subject: Re: Implementation of delegation
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Yudong Gao <stgyd@umich.edu>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTimjFbkLIs4GIdR_S06bu7PPOV-JUj5uGAMs7IjG@mail.gmail.com>
References: <AANLkTik1dbBEnyqMEw9snDhjglJiDQJKs4dFdenqXaGJ@mail.gmail.com>
	 <1278971292.14605.2.camel@heimdal.trondhjem.org>
	 <AANLkTimjFbkLIs4GIdR_S06bu7PPOV-JUj5uGAMs7IjG@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 12 Jul 2010 18:07:55 -0400
Message-ID: <1278972475.14605.9.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-07-12 at 15:00 -0700, Yudong Gao wrote:
> Hi Trond,
> 
> Thanks for the prompt reply!
> 
> I find that in _nfs_do_open(), _nfs4_proc_open(), which do the RPC
> call to the remote server, is always called before
> nfs4_opendata_to_nfs4_state(), which will further invoke
> nfs4_try_open_cached().
> 
> Does this means that whenever is file is opened, the client always
> need to talk to the server first?

The actual RPC call is skipped if the call to can_open_cached() succeeds
in nfs4_open_prepare(). In that case, we just grab the sequence, which
ensures that we remain serialised w.r.t. CLOSE and OPEN_DOWNGRADE calls.

Trond

