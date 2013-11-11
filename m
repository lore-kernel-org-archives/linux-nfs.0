Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:41426 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752326Ab3KKVK3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Nov 2013 16:10:29 -0500
Date: Mon, 11 Nov 2013 13:10:29 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] nfs: fix pnfs Kconfig defaults
Message-ID: <20131111211029.GA19062@infradead.org>
References: <20131102102201.GA3860@infradead.org>
 <6C8CF6D6-0456-4195-B00B-F35A37B64E12@netapp.com>
 <20131111210141.GB13942@infradead.org>
 <1384203889.7614.17.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1384203889.7614.17.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 11, 2013 at 09:04:54PM +0000, Myklebust, Trond wrote:
> > Probably should.  For some reason I had NFS_V4_1 in mind as a bool.
> 
> NFS_V4_1 is indeed a bool, but it just defines whether or not we compile
> v4.1 behaviour into the 'nfsv4 module' (which is controlled by the
> tristate NFS_V4).

Oh right, nfsv4 is a module, but 4.1 is just a flavor inside it.  I'll
resend it after testing that it will actually work is intended.

