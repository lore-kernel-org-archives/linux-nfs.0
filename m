Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:54366 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbaCRSEc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Mar 2014 14:04:32 -0400
Received: by mail-qc0-f175.google.com with SMTP id e16so8312077qcx.34
        for <linux-nfs@vger.kernel.org>; Tue, 18 Mar 2014 11:04:31 -0700 (PDT)
Message-ID: <53288AAC.2010406@gmail.com>
Date: Tue, 18 Mar 2014 14:04:28 -0400
From: Anna Schumaker <schumaker.anna@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfs: remove ->write_pageio_init from rpc ops
References: <20140318112825.GA22359@infradead.org> <532840E8.5090804@gmail.com> <20140318140942.GB11672@infradead.org>
In-Reply-To: <20140318140942.GB11672@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/18/2014 10:09 AM, Christoph Hellwig wrote:
>>> +	struct nfs_server *server = NFS_SERVER(inode);
>>> +	const struct nfs_pageio_ops *pg_ops = &nfs_pageio_write_ops;
>>> +
>>> +#if IS_ENABLED(CONFIG_NFS_V4)
>>> +	if (server->pnfs_curr_ld)
>>> +		pg_ops = server->pnfs_curr_ld->pg_write_ops;
>>> +#endif
>>> +	nfs_pageio_init(pgio, inode, pg_ops, compl_ops, server->wsize, ioflags);
>>>  }
>> I thought it was bad style to put a #ifdef in the middle of a function, which is why we have so many noop functions in the rest of the code.  Should this be done with a select_compl_ops() function instead?
> I don't think it's much of a problem for a small and readable function
> with a single ifdef.  And we'd need one helper for read and write each,
> which would make the code much harder to read.  Still better than what's
> there currently, though.
>
> The other option would be to simply always have the pnfs_curr_ld field
> in the server structure and remove the ifdef entirely.

Okay.  If we keep the ifdef, then it should probably check for CONFIG_NFS_V4_1 and not CONFIG_NFS_V4
