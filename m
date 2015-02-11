Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:42327 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751313AbbBKMev (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 11 Feb 2015 07:34:51 -0500
Date: Wed, 11 Feb 2015 04:34:48 -0800
From: Christoph Hellwig <hch@infradead.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: hang on xfstests generic/074
Message-ID: <20150211123448.GA30174@infradead.org>
References: <20150210154306.GF28949@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150210154306.GF28949@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Feb 10, 2015 at 10:43:06AM -0500, J. Bruce Fields wrote:
> I finally got around to running xfstests as part of my regular testing
> and ran across a reproduceable hang on generic/074:

Yes, I reported this about half a year ago.  It was caused (or at least
unhidden) by commit 2aca5b869ace67a63aab895659e5dc14c33a4d6e ("SUNRPC:
Add missing support for RPC_CLNT_CREATE_NO_RETRANS_TIMEOUT"). Reverting
that commit fixes the issue for me.

