Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f54.google.com ([209.85.216.54]:57499 "EHLO
	mail-qa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166AbaGORdZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 13:33:25 -0400
Received: by mail-qa0-f54.google.com with SMTP id k15so3423045qaq.13
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2014 10:33:24 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 15 Jul 2014 13:33:23 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: trond.myklebust@primarydata.com, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 7/7] sunrpc: remove "ec" argument from encrypt_v2
 operation
Message-ID: <20140715133323.30704557@tlielax.poochiereds.net>
In-Reply-To: <20140715170541.GD7767@infradead.org>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
	<1405303064-9102-8-git-send-email-jlayton@primarydata.com>
	<20140715170541.GD7767@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 15 Jul 2014 10:05:41 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> Looks good,
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>
> 
> I wonder what hat non-trivial memset and add to buffer code was doing
> before it bitrotted, though..

AFAICT, it was never used. I guess you could (in principle) have
callers that did pass a non-zero value there, we just never did in the
kernel. I suspect Kevin just added it in there for completeness sake
when he did the implementation initially.

-- 
Jeff Layton <jlayton@primarydata.com>
