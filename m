Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:42568 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751405AbZD3UZ6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 16:25:58 -0400
Date: Thu, 30 Apr 2009 16:25:58 -0400
From: Christoph Hellwig <hch@infradead.org>
To: Brian R Cowan <brcowan@us.ibm.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: Read/Write NFS I/O performance degraded by FLUSH_STABLE page
	flushing
Message-ID: <20090430202558.GA22295@infradead.org>
References: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <OF3EBF546E.60A83A8F-ON852575A8.006EBB38-852575A8.006EFDE6@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Apr 30, 2009 at 04:12:19PM -0400, Brian R Cowan wrote:
> Hello all,
> 
> This is my first post, so please be gentle.... I have been working with a 
> customer who is attempting to build their product in ClearCase dynamic 
> views on Linux.

> I know that this is a 3+ year old update, but RHEL 4 is based on a 2.4 
> kernel, and SLES 9 is based on something in the same ballpark. And our 
> customers see problems when they go to SLES 10/RHEL 5 from the prior major 
> distro version.

You should probably complain to the distro vendors if you use distro
kernels.  And even when the change might not be diretly related please
reproduce anything posted to upstream projects without binary only
module junk like clearcase.

