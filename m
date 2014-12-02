Return-Path: linux-nfs-owner@vger.kernel.org
Received: from verein.lst.de ([213.95.11.211]:53278 "EHLO newverein.lst.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750780AbaLBRXx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Dec 2014 12:23:53 -0500
Date: Tue, 2 Dec 2014 18:23:50 +0100
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Christoph Hellwig <hch@lst.de>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH 2/2] nfsd: implement chage_attr_type attribute
Message-ID: <20141202172350.GA10312@lst.de>
References: <1415448664-25815-1-git-send-email-hch@lst.de> <1415448664-25815-3-git-send-email-hch@lst.de> <20141110175424.GC32702@fieldses.org> <20141111102735.GB17313@lst.de> <20141111214205.GG20062@fieldses.org> <20141201195021.GB30001@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141201195021.GB30001@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 01, 2014 at 02:50:21PM -0500, J. Bruce Fields wrote:
> Actually, I'm having second thoughts given that there still seems to be
> some argument about whether the change_attr_type thing is completely
> right.  Maybe that only affects values other than
> CHANGE_TYPE_IS_MONOTIC_INCR, but is there any urgency if we don't have a
> client user for it yet?

I don't see a real urgency, just wanted to make sure we have reference
implementations for more of 4.2 available.  I'd defintively be curious
about how the client could make use of these.
