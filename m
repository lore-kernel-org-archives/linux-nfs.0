From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [pnfs] [PATCH RFC v2 0/21] nfs4xdr cleanup v2
Date: Mon, 17 Aug 2009 12:53:29 -0400
Message-ID: <20090817165329.GC27331@fieldses.org>
References: <4A8571E2.8020800@panasas.com> <4A89338D.1040207@panasas.com> <1250513254.8475.20.camel@heimdal.trondhjem.org> <4A896125.2040506@panasas.com> <1250527692.20012.26.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Boaz Harrosh <bharrosh@panasas.com>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	NFS list <linux-nfs@vger.kernel.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:48015 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757365AbZHQQxb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Aug 2009 12:53:31 -0400
In-Reply-To: <1250527692.20012.26.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Aug 17, 2009 at 12:48:12PM -0400, Trond Myklebust wrote:
> On Mon, 2009-08-17 at 16:54 +0300, Boaz Harrosh wrote:
> > Only one request though. Please make nfs and nfsd use the same xdr mechanics
> 
> Bruce has already stated he wants to remove the macros on the nfsd side.

Yes, it all looks fine to me; patches welcome.

--b.
