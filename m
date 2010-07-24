Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:38556 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757675Ab0GXBi3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 23 Jul 2010 21:38:29 -0400
Subject: Re: config delegation lease time
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Yudong Gao <stgyd@umich.edu>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <AANLkTikMa7FzBewHyZ=7Pxrf=EmKU3jb8y9hrO+QhfWd@mail.gmail.com>
References: <AANLkTikMa7FzBewHyZ=7Pxrf=EmKU3jb8y9hrO+QhfWd@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 23 Jul 2010 21:38:24 -0400
Message-ID: <1279935504.5268.23.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Fri, 2010-07-23 at 17:29 -0700, Yudong Gao wrote:
> Hi,
> 
> I am trying to change the delegation lease time in NFS4.1, but I can
> not find any documentation talking about this.
> 
> Do I need to change the source code directly to change the lease time?

Change the contents of /proc/fs/nfsd/nfsv4leasetime on the server.

Trond

