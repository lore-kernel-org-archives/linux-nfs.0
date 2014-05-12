Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:38953 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752128AbaELVsH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 12 May 2014 17:48:07 -0400
Date: Mon, 12 May 2014 17:47:46 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Christoph Hellwig <hch@infradead.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 06/43] nfsd4: fix encoding of out-of-space replies
Message-ID: <20140512214746.GB11493@pad.redhat.com>
References: <1399841568-19716-1-git-send-email-bfields@redhat.com>
 <1399841568-19716-7-git-send-email-bfields@redhat.com>
 <20140512081801.GA14194@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140512081801.GA14194@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 12, 2014 at 01:18:01AM -0700, Christoph Hellwig wrote:
> On Sun, May 11, 2014 at 04:52:11PM -0400, J. Bruce Fields wrote:
...
> > -	op->status = nfsd4_enc_ops[op->opnum](resp, op->status, &op->u);
> > +	encoder = nfsd4_enc_ops[op->opnum];
> > +	op->status = encoder(resp, op->status, &op->u);
> 
> What is the point of the encoder variable that gets set and used a line
> later the only time?

I find the two new lines above a little easier to read than the single
original line.  That's all.  But I don't feel strongly about it.

--b.
