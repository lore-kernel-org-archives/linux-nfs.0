Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:54062 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753878AbdCBRQN (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 2 Mar 2017 12:16:13 -0500
Date: Thu, 2 Mar 2017 08:22:21 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Olga Kornievskaia <kolga@netapp.com>
Cc: Trond.Myklebust@primarydata.com, linux-nfs@vger.kernel.org
Subject: Re: [RFC v1 01/19] fs: Don't copy beyond the end of the file
Message-ID: <20170302162221.GA6854@infradead.org>
References: <20170302160123.30375-1-kolga@netapp.com>
 <20170302160123.30375-2-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170302160123.30375-2-kolga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 02, 2017 at 11:01:05AM -0500, Olga Kornievskaia wrote:
> +	if (pos_in >= i_size_read(inode_in))
> +		return -EINVAL;

That's not how the syscall is supposed to work, we'd rather do a
short read^^^^^copy.
