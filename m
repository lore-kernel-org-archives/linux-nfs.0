Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:10724 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753807Ab1LLXpO convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Dec 2011 18:45:14 -0500
Message-ID: <1323733511.13849.19.camel@lade.trondhjem.org>
Subject: Re: ceph, cifs, nfs, fuse: boolean and / or confusion
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: roel <roel.kluin@gmail.com>, LKML <linux-kernel@vger.kernel.org>,
        sage@newdream.net, Steve French <sfrench@samba.org>,
        linux-cifs@vger.kernel.org, Miklos Szeredi <miklos@szeredi.hu>,
        fuse-devel@lists.sourceforge.net, linux-nfs@vger.kernel.org
Date: Mon, 12 Dec 2011 18:45:11 -0500
In-Reply-To: <1323733153.13849.17.camel@lade.trondhjem.org>
References: <4EE688FC.8090606@gmail.com>
	 <20111212152856.871a8301.akpm@linux-foundation.org>
	 <1323733153.13849.17.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2011-12-12 at 18:39 -0500, Trond Myklebust wrote:

> As far as NFS is concerned, it reverts a regression. NFS only used to
> run revalidate_file_size() for SEEK_END prior to commit
> 06222e491e663dac939f04b125c9dc52126a75c4. I accept that we now also need
> to run it for SEEK_HOLE and SEEK_DATA, but we've never had to do so for
> SEEK_SET and SEEK_CUR.

BTW: The regression exists in 3.1, so this is probably a stable
candidate...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

