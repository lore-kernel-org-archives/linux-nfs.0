Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34914 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761292Ab3JPTCr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 16 Oct 2013 15:02:47 -0400
Date: Wed, 16 Oct 2013 15:02:45 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Subject: Re: Here's a nugget...
Message-ID: <20131016190245.GD19067@fieldses.org>
References: <1381949943.17178.12.camel@leira.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1381949943.17178.12.camel@leira.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Oct 16, 2013 at 06:59:04PM +0000, Myklebust, Trond wrote:
> In gss_krb5_add_padding():
> 
> 	memset(p, padding, padding);

RFC 1964 1.2.2.3:

	"Data padding: Before encryption and/or signature calculation,
	plaintext data is padded to the next highest multiple of 8
	bytes, by appending between 1 and 8 bytes, the value of each
	such byte being the total number of pad bytes."

You could add a comment referencing that if you think the memset is
confusing.

--b.
