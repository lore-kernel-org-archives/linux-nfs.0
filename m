Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60610 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965428AbaCSPkt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Mar 2014 11:40:49 -0400
Date: Wed, 19 Mar 2014 08:40:48 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Anna Schumaker <schumaker.anna@gmail.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] nfs: remove ->write_pageio_init from rpc ops
Message-ID: <20140319154048.GB3729@infradead.org>
References: <20140318112825.GA22359@infradead.org>
 <532840E8.5090804@gmail.com>
 <20140318140942.GB11672@infradead.org>
 <53288AAC.2010406@gmail.com>
 <20140319074130.GA14944@infradead.org>
 <53299787.5030401@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53299787.5030401@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Mar 19, 2014 at 09:11:35AM -0400, Anna Schumaker wrote:
> On 03/19/2014 03:41 AM, Christoph Hellwig wrote:
> > On Tue, Mar 18, 2014 at 02:04:28PM -0400, Anna Schumaker wrote:
> >>> The other option would be to simply always have the pnfs_curr_ld field
> >>> in the server structure and remove the ifdef entirely.
> >> Okay.  If we keep the ifdef, then it should probably check for CONFIG_NFS_V4_1 and not CONFIG_NFS_V4
> > The field in the header is under CONFIG_NFS_V4, so I tried to make it
> > consistent.
> >
> struct pnfs_layoutdriver_type comes from fs/nfs/pnfs.h under a CONFIG_NFS_V4_1 check, so you can't access pg_write_ops or pg_read_ops without v4.1 enabled.

You're right - the field exists for plain v4, but we can't dereference
it unless 4.1 support is enable.  I'll send an update.
