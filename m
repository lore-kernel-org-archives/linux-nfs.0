Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:38384 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752537AbdDLIUg (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Apr 2017 04:20:36 -0400
Date: Wed, 12 Apr 2017 01:20:34 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Jan Kara <jack@suse.cz>
Cc: linux-fsdevel@vger.kernel.org, linux-block@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 21/25] nfs: Convert to separately allocated bdi
Message-ID: <20170412082034.GU9830@infradead.org>
References: <20170329105623.18241-1-jack@suse.cz>
 <20170329105623.18241-22-jack@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170329105623.18241-22-jack@suse.cz>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>  /*
>   * Finish setting up an NFS2/3 superblock
>   */

I was just looking why you didn't update the v4 variant, but it seems
like the comment above is simply incorrect..

Thus the patch looks fine:

Reviewed-by: Christoph Hellwig <hch@lst.de>
