Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:37150 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S937432AbdAHKHQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Jan 2017 05:07:16 -0500
Date: Sun, 8 Jan 2017 02:07:15 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Christoph Hellwig <hch@infradead.org>,
        Steve Dickson <SteveD@redhat.com>
Subject: Re: [PATCH] NFSD: only support readonly export for !fsync and
 readonly filesystem
Message-ID: <20170108100715.GC25268@infradead.org>
References: <960d206f-3cb5-b60e-5245-d7282dabf664@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <960d206f-3cb5-b60e-5245-d7282dabf664@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Dec 31, 2016 at 09:18:08PM +0800, Kinglong Mee wrote:
> Commit fae5096ad217
> "nfsd: assume writeable exportabled filesystems have f_sync"
> have remove the checking of f_sync.
> 
> Christoph Hellwig suggests,
> "Warn and refuse the writable export."
> 
> I think just covert to a readonly export for !fsync filesystem,
> also, for a readonly filesystem is reasonable.

I don't like degrading the export.  We should require an explicit
ro option in this case.
