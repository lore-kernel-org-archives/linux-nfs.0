Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:48933 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751188AbaKEI4K (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Nov 2014 03:56:10 -0500
Date: Wed, 5 Nov 2014 00:56:09 -0800
From: Christoph Hellwig <hch@infradead.org>
To: Chris Siebenmann <cks@cs.toronto.edu>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        libc-alpha@sourceware.org
Subject: Re: Best approach for authenticating hosts for NFS (v3)?
Message-ID: <20141105085609.GA21735@infradead.org>
References: <20141104165313.CA9025A04C1@testapps.cs.toronto.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20141104165313.CA9025A04C1@testapps.cs.toronto.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Nov 04, 2014 at 11:53:13AM -0500, Chris Siebenmann wrote:
> [*: Building a NSS module that supports netgroup lookups requires using
>     an internal glibc header file to get a definition of a struct that
>     is passed to NSS netgroup lookup functions.

It seems like that's where you should attack the problem.  I've Cced the
glibc list to open the question if they really intended it to be a
private interface.

And even if they do using it anyway and dealign with the fact that you
have to be extremly careful with libc updates still sounds a lot less
painful than the other options.
