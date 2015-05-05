Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:36776 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753293AbbEETMb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 May 2015 15:12:31 -0400
Date: Tue, 5 May 2015 12:12:31 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: RFC: combine xprtrdma and svcrdma
Message-ID: <20150505191231.GA28818@infradead.org>
References: <CE0356DB-12BA-4208-83B1-E51B34B25388@oracle.com>
 <20150505173207.GA14409@infradead.org>
 <4A99CF87-4AA6-4F60-9678-AE4F8B45E5AF@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4A99CF87-4AA6-4F60-9678-AE4F8B45E5AF@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 05, 2015 at 02:15:07PM -0400, Chuck Lever wrote:
> bc_svc.c struck me as left over from a prototype.
> 
> It would be reasonable to move bc_send into xprtsock.c (or some other
> convenient file) and then pass its address into the server code via
> a virtual function (eg. as an rpc_xprt op).

Given that they always sit in the same module direct calls should just
work fine.

> I?ve been scratching my head wondering why we have still have
> CONFIG_SUNRPC_BACKCHANNEL, which is not exposed in menuconfig. Is it
> time to remove it?

It's selected by CONFIG_NFS_V4_1, and thus isn't build if you don't
select 4.1 support.
