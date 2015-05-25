Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:36653 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888AbbEYPOa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 May 2015 11:14:30 -0400
Date: Mon, 25 May 2015 08:14:29 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benjamin ESTRABAUD <be@mpstor.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "bc@mpstor.com" <bc@mpstor.com>
Subject: Re: Issue running buffered writes to a pNFS (NFS 4.1 backed by SAN)
 filesystem.
Message-ID: <20150525151429.GB18386@infradead.org>
References: <41EB9782-8445-4FBB-A825-A484EFF7169C@mpstor.com>
 <20150517163841.GA19109@infradead.org>
 <555CB69B.7030108@mpstor.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <555CB69B.7030108@mpstor.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 20, 2015 at 05:30:19PM +0100, Benjamin ESTRABAUD wrote:
> I'm going to try this now (move client and maybe even server to Linux 4.0,
> now that 4.0 has a more "current" stable release).

Only the client is interesting in this case.

> By the way, what is the minimum Linux Kernel version required to connect to
> a NFS v4.1 server using pNFS? We only managed to get this working with
> kernel 4.0 (on the client) and it appears that this is the lowest kernel
> release that supports pNFS block clients (working with Linux pNFS recent
> block server). Could you please confirm this?

The big changes to make the block client useful went into 3.18.  Almost
nothing has changed in the client since.
