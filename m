Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:52009 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751816AbaA3OOJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Jan 2014 09:14:09 -0500
Date: Thu, 30 Jan 2014 06:14:05 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, Christoph Hellwig <hch@lst.de>,
        Al Viro <viro@zeniv.linux.org.uk>,
        linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org
Subject: Re: NFS client broken in Linus' tip
Message-ID: <20140130141405.GA23985@infradead.org>
References: <20140130140834.GW15937@n2100.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140130140834.GW15937@n2100.arm.linux.org.uk>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jan 30, 2014 at 02:08:34PM +0000, Russell King - ARM Linux wrote:
> into nfs3_proc_create(), but this ends up calling down into nfs3_get_acl(),
> which does this:
> 
>         if (!nfs_server_capable(inode, NFS_CAP_ACLS))
>                 return ERR_PTR(-EOPNOTSUPP);

Does replacing that return with a

		return NULL;

fix the issue for you?

