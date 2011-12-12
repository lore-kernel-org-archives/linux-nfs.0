Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.linuxfoundation.org ([140.211.169.12]:57732 "EHLO
	mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346Ab1LLXyZ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2011 18:54:25 -0500
Date: Mon, 12 Dec 2011 15:54:23 -0800
From: Andrew Morton <akpm@linux-foundation.org>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: roel <roel.kluin@gmail.com>, LKML <linux-kernel@vger.kernel.org>,
        sage@newdream.net, Steve French <sfrench@samba.org>,
        linux-cifs@vger.kernel.org, Miklos Szeredi <miklos@szeredi.hu>,
        fuse-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Subject: Re: ceph, cifs, nfs, fuse: boolean and / or confusion
Message-Id: <20111212155423.24543d6a.akpm@linux-foundation.org>
In-Reply-To: <1323733511.13849.19.camel@lade.trondhjem.org>
References: <4EE688FC.8090606@gmail.com>
	<20111212152856.871a8301.akpm@linux-foundation.org>
	<1323733153.13849.17.camel@lade.trondhjem.org>
	<1323733511.13849.19.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 12 Dec 2011 18:45:11 -0500
Trond Myklebust <Trond.Myklebust@netapp.com> wrote:

> On Mon, 2011-12-12 at 18:39 -0500, Trond Myklebust wrote:
> 
> > As far as NFS is concerned, it reverts a regression. NFS only used to
> > run revalidate_file_size() for SEEK_END prior to commit
> > 06222e491e663dac939f04b125c9dc52126a75c4. I accept that we now also need
> > to run it for SEEK_HOLE and SEEK_DATA, but we've never had to do so for
> > SEEK_SET and SEEK_CUR.
> 
> BTW: The regression exists in 3.1, so this is probably a stable
> candidate...
> 

I'd prefer not to merge this one unless all four fs maintainers have
reviewed and preferably tested it.  Also, in view of your earlier email
the changelog for this patch needs updating for NFS and probably other
filesystems.

So please prepare and send the NFS patch, with a Reported-by:roel?
