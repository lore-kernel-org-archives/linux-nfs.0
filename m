Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from verein.lst.de ([213.95.11.211]:50943 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750794AbbD3Oig (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 30 Apr 2015 10:38:36 -0400
Date: Thu, 30 Apr 2015 16:38:34 +0200
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Chuck Lever <chuck.lever@oracle.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/3] nfsd: split transport vs operation errors for
	callbacks
Message-ID: <20150430143834.GA25346@lst.de>
References: <1430387365-24348-1-git-send-email-hch@lst.de> <1430387365-24348-2-git-send-email-hch@lst.de> <20150430142456.GA1704@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150430142456.GA1704@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 30, 2015 at 10:24:56AM -0400, J. Bruce Fields wrote:
> On Thu, Apr 30, 2015 at 11:49:23AM +0200, Christoph Hellwig wrote:
> > We must only increment the sequence id if the client has seen and responded
> > to a request.  If we failed to deliver it to the client we must resend with
> > the same sequence id.  So just like the client track errors at the transport
> > level differently from those returned in the XDR.
> 
> Looks good.
> 
> Though errors to the CB_SEQUENCE op itself don't bump the sequence id
> either--maybe we need the equivalent of the logic in
> fs/nfs/nfs4proc.c:nfs41_sequence_done().

For now the server logic could be a bit simpler, but that looks like a
good model indeed.
