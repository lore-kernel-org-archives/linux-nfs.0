Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:34585 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932464AbbLPPR4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Dec 2015 10:17:56 -0500
Date: Wed, 16 Dec 2015 07:17:55 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Sagi Grimberg <sagig@dev.mellanox.co.il>, anna.schumaker@netapp.com,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v3 04/11] xprtrdma: Move struct ib_send_wr off the stack
Message-ID: <20151216151755.GA27249@infradead.org>
References: <20151214211317.16295.70115.stgit@manet.1015granger.net>
 <20151214211811.16295.47695.stgit@manet.1015granger.net>
 <56716E6C.4020604@dev.mellanox.co.il>
 <F2E992ED-2698-43DE-B7C5-4F02DA75AE42@oracle.com>
 <20151216151115.GA16905@infradead.org>
 <D5B6F9FD-FF8F-4F37-A3E5-B287B91B1EA4@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <D5B6F9FD-FF8F-4F37-A3E5-B287B91B1EA4@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Dec 16, 2015 at 10:13:31AM -0500, Chuck Lever wrote:
> > Shouldn't be an issue with transparent unions these days:
> > 
> > 	union {
> > 		struct ib_reg_wr                fr_regwr;
> > 		struct ib_send_wr               fr_invwr;
> > 	};
> 
> Right, but isn't that a gcc-ism that Al hates? If
> everyone is OK with that construction, I will use it.

I started out as a GNUism, but now is supported in C11.  We use it
a lot all over the kernel.
