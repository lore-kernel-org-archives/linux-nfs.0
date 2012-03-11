Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56399 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754144Ab2CKXCw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 11 Mar 2012 19:02:52 -0400
Date: Sun, 11 Mar 2012 19:02:49 -0400
From: Dr James Bruce Fields <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Kevin Coffman <kwc@citi.umich.edu>,
        Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Bug in gss_krb5_crypto.c
Message-ID: <20120311230249.GA1305@fieldses.org>
References: <1331504084.2792.7.camel@lade.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1331504084.2792.7.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sun, Mar 11, 2012 at 10:14:44PM +0000, Myklebust, Trond wrote:
> Hi Kevin & Bruce,
> 
> When running sparse on the sunrpc code, I'm seeing the following error
> message:
> "net/sunrpc/auth_gss/gss_krb5_crypto.c:603:52: error: bad constant
> expression"
> 
> This boils down to the line:
>         u8 data[crypto_blkcipher_blocksize(cipher) * 2];

Oops.

> which is using a GNU Cc-ism in order to do dynamic allocation on the
> stack. This is not acceptable in kernel code, and really needs to be
> changed. How should we move forward with this? Is there an upper limit
> on the value of crypto_blkcipher_blocksize(cipher) that we can use?

I think it's always either 8 or 16.

--b.
