Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:33212 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751797AbbKXQD0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 Nov 2015 11:03:26 -0500
Date: Tue, 24 Nov 2015 08:03:23 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>, Tom Talpey <tom@talpey.com>,
        linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH v1 8/8] svcrdma: Remove svc_rdma_fastreg_mr::access_flags
 field
Message-ID: <20151124160323.GA16427@infradead.org>
References: <20151123221738.13040.26277.stgit@klimt.1015granger.net>
 <20151123222118.13040.24258.stgit@klimt.1015granger.net>
 <5653B4CA.5050806@talpey.com>
 <92B143FC-0F2C-48E4-9042-189883D76403@oracle.com>
 <20151124063903.GA12300@infradead.org>
 <7B9388F8-3A88-4F61-AB87-A1E6DB9902FE@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <7B9388F8-3A88-4F61-AB87-A1E6DB9902FE@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 24, 2015 at 09:08:21AM -0500, Chuck Lever wrote:
> Why don???t you fold my change into yours?

It's already included.  Well, sort of - I have removed used of the
field, but forgot to remove the definition.  I will update it.
