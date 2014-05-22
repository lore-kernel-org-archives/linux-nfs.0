Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:38694 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752404AbaEVP4u (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 May 2014 11:56:50 -0400
Date: Thu, 22 May 2014 11:56:41 -0400
To: Christoph Hellwig <hch@infradead.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 05/43] nfsd4: move nfsd4_operation to xdr4.h
Message-ID: <20140522155640.GB20943@fieldses.org>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <1399841568-19716-6-git-send-email-bfields@redhat.com>
 <20140512054115.GF29134@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140512054115.GF29134@infradead.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 11, 2014 at 10:41:15PM -0700, Christoph Hellwig wrote:
> > +struct nfsd4_operation *OPDESC(struct nfsd4_op *op)
> 
> I don't think OPDESC is a good name for a non-static function.
> 
> 
> But looking at the whoile tree we only need the exposed information
> in two simple places in nfs4xdr.c, so I'd suggest to export something
> higher level instead, e.g. move nfsd4_max_reply into nfs4proc.c
> and have a helper to check that the op doesn't modify anything and
> warn if it does.
> 

Sure, makes sense; done.

--b.
