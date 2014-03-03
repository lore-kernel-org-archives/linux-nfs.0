Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:51392 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755307AbaCCTHd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 3 Mar 2014 14:07:33 -0500
Date: Mon, 3 Mar 2014 11:07:33 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Shirley Ma <shirley.ma@oracle.com>,
        Wendy Cheng <s.wendy.cheng@gmail.com>
Subject: Re: Proposal for simplifying NFS/RDMA client memory registration
Message-ID: <20140303190733.GA4556@infradead.org>
References: <01C4496A-F074-4F72-9DF0-6076C05E8A1F@oracle.com>
 <E755E683-C064-4ED3-8448-C61F4E5AF16E@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <E755E683-C064-4ED3-8448-C61F4E5AF16E@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Mar 03, 2014 at 12:02:33PM -0500, Chuck Lever wrote:
> All HCAs in 3.13 (and rxe) can support either MTHCA_FMR or FRMR or both. Wendy?s HCA supports only ALLPHYSICAL.

Is Wendy planning to submit her HCA driver ASAP?  If not there's not
reason to keep ALLPHYSICAL either.

> Does it make sense to deprecate then remove the registration modes in the first list?

Yes.

