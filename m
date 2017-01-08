Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:35408 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751303AbdAHOeD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 8 Jan 2017 09:34:03 -0500
Date: Sun, 8 Jan 2017 06:34:02 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 00/22] convert NFS server to new rdma_rw API
Message-ID: <20170108143402.GA2243@infradead.org>
References: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20170107170258.14126.8503.stgit@klimt.1015granger.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jan 07, 2017 at 12:15:15PM -0500, Chuck Lever wrote:
> This series converts the Linux NFS server RPC-over-RDMA
> implementation to use the new core rdma_rw API and to poll its CQs
> in workqueue mode.
> 
> Previously published work prototyped only the path that sends RPC
> replies. This series converts both send and receive sides, and
> includes significant clean ups that result from using the new API.
> 
> This series has been successfully tested with NFSv3, 4.0, and 4.1;
> with clients that use FRWR and FMR; and with sec=sys, krb5, krb5i,
> and krb5p.

Any performane improvements (or regressions) with it?

>  10 files changed, 1621 insertions(+), 1656 deletions(-)

Hmm, that's not much less code, especially compared to the
other target side drivers where we remove a very substantial amount of
code.  I guess I need to spend some time with the individual patches
to understand why.
