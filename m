Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f171.google.com ([209.85.216.171]:63079 "EHLO
	mail-qc0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751823AbaHTSnE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Aug 2014 14:43:04 -0400
Received: by mail-qc0-f171.google.com with SMTP id r5so8120201qcx.2
        for <linux-nfs@vger.kernel.org>; Wed, 20 Aug 2014 11:43:02 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Wed, 20 Aug 2014 14:43:01 -0400
To: Christoph Hellwig <hch@lst.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: pnfs block layout driver fixes
Message-ID: <20140820144301.23d6aac3@tlielax.poochiereds.net>
In-Reply-To: <1407396229-4785-1-git-send-email-hch@lst.de>
References: <1407396229-4785-1-git-send-email-hch@lst.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu,  7 Aug 2014 09:23:32 +0200
Christoph Hellwig <hch@lst.de> wrote:

> This series fixes a wide range of issues with the pnfs block layout driver.
> 
> Before this we were seeing frequent silent data corruption, softlockups and
> kernel crashes when running both user applications and test cases like xfstests.
> 
> After this rewrite of the I/O path we've sorted out all issues under normal
> operations, although error handling in the block layout driver and its
> interaction with the core nfs and pnfs code still needs further work.
> 
> This work was sponsored by NetApp, Inc.
> 

What sort of server are you testing this against?

-- 
Jeff Layton <jlayton@primarydata.com>
