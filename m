Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46842 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753236AbcEMUbj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 13 May 2016 16:31:39 -0400
Date: Fri, 13 May 2016 16:31:35 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Christoph Hellwig <hch@infradead.org>
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, linux-nfs@vger.kernel.org,
        Trond.Myklebust@primarydata.com
Subject: Re: [PATCH v4 0/3] NFSv4.2: Add support for the COPY operation
Message-ID: <20160513203135.GE5658@fieldses.org>
References: <1461962533-26534-1-git-send-email-Anna.Schumaker@Netapp.com>
 <20160501173733.GA556@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160501173733.GA556@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, May 01, 2016 at 10:37:33AM -0700, Christoph Hellwig wrote:
> I might sound like a broken record, but I'd feel much happier if this
> had extensive xfstests coverage.  Xfstests has over one hundred tests for
> file clones, and many of them should be easily adapatable.

Anna, have you looked at this yet?

I don't see any obvious problem with the nfsd code, other than the
obvious issue with large synchronous copies tying up server threads and
leaving clients waiting--but maybe we should just see how people end up
using it and deal with the problems as they come up.

--b.
