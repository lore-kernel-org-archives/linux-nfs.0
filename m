Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f177.google.com ([209.85.216.177]:49226 "EHLO
	mail-qc0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753176AbaFWROd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 Jun 2014 13:14:33 -0400
Received: by mail-qc0-f177.google.com with SMTP id r5so6265427qcx.8
        for <linux-nfs@vger.kernel.org>; Mon, 23 Jun 2014 10:14:32 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 23 Jun 2014 13:14:31 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 007/104] NFSd: Add locking to the nfs4_file->fi_fds[]
 array
Message-ID: <20140623131431.71d632ff@tlielax.poochiereds.net>
In-Reply-To: <20140623160636.GE24193@infradead.org>
References: <1403189450-18729-1-git-send-email-jlayton@primarydata.com>
	<1403189450-18729-8-git-send-email-jlayton@primarydata.com>
	<20140623160636.GE24193@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 23 Jun 2014 09:06:36 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> Missed the why the locking is added.
> 
> Also I pointed out a way to better factor this code in reply to one
> of Tronds previous postings of this one.
>

I saw your comments and even did some experimentation to that end.
After playing around with some patches that tried to use FMODE flags
instead, I tossed them out. It may have consolidated the code a bit, but
the result was just too difficult to follow. I think it's better to go
with clearer code here, even if it's a little more verbose.

-- 
Jeff Layton <jlayton@primarydata.com>
