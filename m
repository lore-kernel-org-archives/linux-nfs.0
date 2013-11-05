Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:43192 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754348Ab3KEMdP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Nov 2013 07:33:15 -0500
Date: Tue, 5 Nov 2013 04:33:09 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: Christoph Hellwig <hch@infradead.org>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 4/4] NFSD: Implement SEEK
Message-ID: <20131105123309.GA30798@infradead.org>
References: <20131029073558.GA10889@infradead.org>
 <526FB180.1060003@netapp.com>
 <20131029130721.GA32094@infradead.org>
 <20131029133006.GB29606@fieldses.org>
 <20131102134837.GA18961@infradead.org>
 <20131102143729.GA26983@fieldses.org>
 <20131102144107.GA28743@infradead.org>
 <20131104164658.GA4427@fieldses.org>
 <20131104170510.GB31499@infradead.org>
 <89CF7DF4-50B3-4EF4-B756-FDAFAC44F298@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <89CF7DF4-50B3-4EF4-B756-FDAFAC44F298@oracle.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Nov 04, 2013 at 09:22:11AM -0800, Chuck Lever wrote:
> The original proposal is
> 
>   http://tools.ietf.org/html/draft-eisler-nfsv4-enterprise-apps-01
> 
> and has been somewhat modified in its expression in NFSv4.2.

The INITIALIZE operation in that proposal look like a sane translation of
the SCSI WRITE SAME commands to NFS, but I have no idea
how that eveloved into the monster of ADHs in the NFS4.2 draft.

