Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:52039 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757743Ab1FVXFx convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Jun 2011 19:05:53 -0400
Subject: Re: [nfs, rpc] crap with refcounting and rmmod races
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Al Viro <viro@ZenIV.linux.org.uk>
Cc: linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 22 Jun 2011 19:05:42 -0400
In-Reply-To: <20110622225815.GG11521@ZenIV.linux.org.uk>
References: <20110622191239.GD11521@ZenIV.linux.org.uk>
	 <20110622215145.GF11521@ZenIV.linux.org.uk>
	 <1308782934.25875.22.camel@lade.trondhjem.org>
	 <20110622225815.GG11521@ZenIV.linux.org.uk>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1308783942.25875.34.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-06-22 at 23:58 +0100, Al Viro wrote: 
> On Wed, Jun 22, 2011 at 06:48:54PM -0400, Trond Myklebust wrote:
> 
> > It is fairly trivial to define a 'struct nfs_path' that takes a
> > reference to the dentry and a reference to the super block if you'd
> > prefer that we get rid of the 'struct path' in nfs_open_context.
> 
> Er...  as opposed to struct dentry *dentry and its ->d_sb? ;-)
> See the last few patches in #untested (vfs-2.6.git) doing more
> or less that (and nfs4_closedata is just fine with data->inode->i_sb -
> it doesn't need to pin any dentries at all; nfs4_opendata and
> nfs_open_context need dentry, of course).

Sure. As far as we're concerned, the main purpose of the vfsmount in
nfs_open_context is to prevent triggering generic_shutdown_super() while
we're finishing writebacks. It is convenient to carry that all the way
through to the nfs4_closedata, but I agree that it is not necessary...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

