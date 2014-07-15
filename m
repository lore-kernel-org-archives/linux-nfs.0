Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f170.google.com ([209.85.216.170]:54556 "EHLO
	mail-qc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753787AbaGORRl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 15 Jul 2014 13:17:41 -0400
Received: by mail-qc0-f170.google.com with SMTP id c9so5393899qcz.29
        for <linux-nfs@vger.kernel.org>; Tue, 15 Jul 2014 10:17:40 -0700 (PDT)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Tue, 15 Jul 2014 13:17:39 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: trond.myklebust@primarydata.com, bfields@fieldses.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/7] sunrpc: xdr_get_next_encode_buffer can be static
Message-ID: <20140715131739.7ac1a1f2@tlielax.poochiereds.net>
In-Reply-To: <20140715170248.GA7767@infradead.org>
References: <1405303064-9102-1-git-send-email-jlayton@primarydata.com>
	<1405303064-9102-5-git-send-email-jlayton@primarydata.com>
	<20140715170248.GA7767@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 15 Jul 2014 10:02:48 -0700
Christoph Hellwig <hch@infradead.org> wrote:

> Trond just sent a patch for this as well..
> 
> Reviewed-by: Christoph Hellwig <hch@lst.de>

Ok, cool. I'll drop this one then.

Thanks,
-- 
Jeff Layton <jlayton@primarydata.com>
