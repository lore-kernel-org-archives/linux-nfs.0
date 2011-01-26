Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57907 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753465Ab1AZUnH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 26 Jan 2011 15:43:07 -0500
Subject: Re: 2.6.38-rc2... NFS sillyrename is broken...
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "J. R. Okajima" <hooanon05@yahoo.co.jp>
Cc: linux-nfs@vger.kernel.org, Nick Piggin <npiggin@gmail.com>,
        Linux Filesystem Development <linux-fsdevel@vger.kernel.org>
In-Reply-To: <1296072867.7127.26.camel@heimdal.trondhjem.org>
References: <1295998215.6867.22.camel@heimdal.trondhjem.org>
	 <21515.1296030022@jrobl>  <1296072867.7127.26.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 26 Jan 2011 15:43:05 -0500
Message-ID: <1296074585.7127.33.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-01-26 at 15:14 -0500, Trond Myklebust wrote: 
> The alternative would be to add a callback that can be called after
> dentry_iput() if DCACHE_NFSFS_RENAMED is true, and that takes the parent
> and (negative) dentry as the arguments.
> sillyrename doesn't need the inode as an argument, but it definitely
> needs the parent dentry so that it can check for races with
> ->lookup()...

The following (compile tested only!) patch illustrates what I mean.

Cheers
  Trond
8<-------------------------------------------------------------------------- 
