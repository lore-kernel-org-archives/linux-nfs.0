Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:37504 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758796Ab0KRP1r (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 18 Nov 2010 10:27:47 -0500
Subject: Re: Question about nfs_page_async_flush assertion
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Peng Tao <lkml.bergwolf@gmail.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <AANLkTimavN8px1k_Y65mFqsAsiLjgCh6vos22ZnZm+3Z@mail.gmail.com>
References: <AANLkTimavN8px1k_Y65mFqsAsiLjgCh6vos22ZnZm+3Z@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 18 Nov 2010 10:27:43 -0500
Message-ID: <1290094063.3187.41.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, 2010-11-18 at 18:53 +0800, Peng Tao wrote:
> Hi, all,
> 
> nfs_writepages calls into
> write_cache_pages()->nfs_writepages_callback()->nfs_do_writepage()->nfs_page_async_flush(),
> where it asserts BUG_ON(test_bit(PG_CLEAN, &req->wb_flags)).
> My question is: how do we guarantee the request has PG_CLEAN flag set?

We don't. We guarantee that the request has PG_CLEAN cleared, and that
is done when we dirty the page (see nfs_try_to_update_request()).

Cheers
  Trond

