Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:33095 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752816AbbLPPLS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2015 10:11:18 -0500
Date: Wed, 16 Dec 2015 07:11:15 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Sagi Grimberg <sagig@dev.mellanox.co.il>, anna.schumaker@netapp.com,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 04/11] xprtrdma: Move struct ib_send_wr off the stack
Message-ID: <20151216151115.GA16905@infradead.org>
References: <20151214211317.16295.70115.stgit@manet.1015granger.net>
 <20151214211811.16295.47695.stgit@manet.1015granger.net>
 <56716E6C.4020604@dev.mellanox.co.il>
 <F2E992ED-2698-43DE-B7C5-4F02DA75AE42@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <F2E992ED-2698-43DE-B7C5-4F02DA75AE42@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 16, 2015 at 10:06:33AM -0500, Chuck Lever wrote:
> > Would it make sense to unionize these as they are guaranteed not to
> > execute together? Some people don't like this sort of savings.
> 
> I dislike unions because they make the code that uses
> them less readable. I can define macros to help that,
> but sigh! OK.

Shouldn't be an issue with transparent unions these days:

	union {
		struct ib_reg_wr                fr_regwr;
		struct ib_send_wr               fr_invwr;
	};
