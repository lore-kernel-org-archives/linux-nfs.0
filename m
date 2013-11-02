Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:60432 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750957Ab3KBPU3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 2 Nov 2013 11:20:29 -0400
Date: Sat, 2 Nov 2013 08:20:29 -0700
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Anna Schumaker <bjschuma@netapp.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/4] NFSD: Add WRITE_PLUS support for hole punches
Message-ID: <20131102152029.GA30427@infradead.org>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
 <1382972247-1108-4-git-send-email-bjschuma@netapp.com>
 <20131028214030.GO31322@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20131028214030.GO31322@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 28, 2013 at 05:40:30PM -0400, J. Bruce Fields wrote:
> On Mon, Oct 28, 2013 at 10:57:25AM -0400, Anna Schumaker wrote:
> > This patch only implements DATA_CONTENT_HOLE support, but I tried to
> > write it so other arms of the discriminated union can be added easily
> > later.
> 
> And there's an NFS4ERR_UNION_NOTSUPP to handle that case, OK.  (Though
> the spec language is a little ambiguous:
> 
> 	If the client asks for a hole and the server does not support
> 	that arm of the discriminated union, but does support one or
> 	more additional arms, it can signal to the client that it
> 	supports the operation, but not the arm with
> 	NFS4ERR_UNION_NOTSUPP.

Where is this language coming from?  Seems like the latest document in
NFSv4.2/ repo still calls WRITE_PLUS INITIALIZE and doesn't have
anything content related, just a weird "ADB" concept.

