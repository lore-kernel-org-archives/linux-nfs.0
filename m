Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:50079 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933495AbdCHAgV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Mar 2017 19:36:21 -0500
Date: Tue, 7 Mar 2017 15:40:51 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@infradead.org>,
        Olga Kornievskaia <kolga@netapp.com>, Trond.Myklebust@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
Message-ID: <20170307234051.GA29977@infradead.org>
References: <20170302160123.30375-1-kolga@netapp.com>
 <20170302160123.30375-2-kolga@netapp.com>
 <20170302162221.GA6854@infradead.org>
 <20170303204747.GE13877@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170303204747.GE13877@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Mar 03, 2017 at 03:47:47PM -0500, J. Bruce Fields wrote:
> That's what I think too, but then is COPY(2) wrong?:

Either the current kernel code or the man page is wrong..

> Also, copy_file_range can be implemented by ->clone_file_range, where
> these kinds of checks make more sense, I think; e.g. from btrfs:
> 
> 	ret = -EINVAL;
> 	if (off + len > src->i_size || off + len < off)
> 		goto out_unlock;
> 
> Well, so the caller just has to be prepared for either behavior, I
> guess, but that may make it more complicated to use.

We'll need to stick to one behavior.  So between the man page and
the clone implementation I guess this patch is fine after all.
