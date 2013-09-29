Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60036 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751159Ab3I2MTw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Sep 2013 08:19:52 -0400
Date: Sun, 29 Sep 2013 05:19:51 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Benny Halevy <bhalevy@primarydata.com>
Cc: " J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH RFC v0 45/49] nfs: resolve compile dependency in nfs_xdr.h
Message-ID: <20130929121951.GH21083@infradead.org>
References: <52447EA0.7070004@primarydata.com>
 <1380220979-14761-1-git-send-email-bhalevy@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1380220979-14761-1-git-send-email-bhalevy@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Sep 26, 2013 at 02:42:59PM -0400, Benny Halevy wrote:
> From: Benny Halevy <bhalevy@panasas.com>
> 
> Include headers in nfs_xdr.h required for
> struct rpc_task, nfs4_verifier, nfs4_stateid

Is this actually dereferences or would it need a forward declaration?

Also should go to Trond straight outside of this series.

