Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qa0-f41.google.com ([209.85.216.41]:40693 "EHLO
	mail-qa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965133AbaCSNLj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Mar 2014 09:11:39 -0400
Received: by mail-qa0-f41.google.com with SMTP id j5so8609533qaq.0
        for <linux-nfs@vger.kernel.org>; Wed, 19 Mar 2014 06:11:38 -0700 (PDT)
Message-ID: <53299787.5030401@gmail.com>
Date: Wed, 19 Mar 2014 09:11:35 -0400
From: Anna Schumaker <schumaker.anna@gmail.com>
MIME-Version: 1.0
To: Christoph Hellwig <hch@infradead.org>
CC: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfs: remove ->write_pageio_init from rpc ops
References: <20140318112825.GA22359@infradead.org> <532840E8.5090804@gmail.com> <20140318140942.GB11672@infradead.org> <53288AAC.2010406@gmail.com> <20140319074130.GA14944@infradead.org>
In-Reply-To: <20140319074130.GA14944@infradead.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 03/19/2014 03:41 AM, Christoph Hellwig wrote:
> On Tue, Mar 18, 2014 at 02:04:28PM -0400, Anna Schumaker wrote:
>>> The other option would be to simply always have the pnfs_curr_ld field
>>> in the server structure and remove the ifdef entirely.
>> Okay.  If we keep the ifdef, then it should probably check for CONFIG_NFS_V4_1 and not CONFIG_NFS_V4
> The field in the header is under CONFIG_NFS_V4, so I tried to make it
> consistent.
>
struct pnfs_layoutdriver_type comes from fs/nfs/pnfs.h under a CONFIG_NFS_V4_1 check, so you can't access pg_write_ops or pg_read_ops without v4.1 enabled.

