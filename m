Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:54674 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756726Ab1FVW6S (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 18:58:18 -0400
Date: Wed, 22 Jun 2011 23:58:15 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [nfs, rpc] crap with refcounting and rmmod races
Message-ID: <20110622225815.GG11521@ZenIV.linux.org.uk>
References: <20110622191239.GD11521@ZenIV.linux.org.uk>
 <20110622215145.GF11521@ZenIV.linux.org.uk>
 <1308782934.25875.22.camel@lade.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1308782934.25875.22.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, Jun 22, 2011 at 06:48:54PM -0400, Trond Myklebust wrote:

> It is fairly trivial to define a 'struct nfs_path' that takes a
> reference to the dentry and a reference to the super block if you'd
> prefer that we get rid of the 'struct path' in nfs_open_context.

Er...  as opposed to struct dentry *dentry and its ->d_sb? ;-)
See the last few patches in #untested (vfs-2.6.git) doing more
or less that (and nfs4_closedata is just fine with data->inode->i_sb -
it doesn't need to pin any dentries at all; nfs4_opendata and
nfs_open_context need dentry, of course).
