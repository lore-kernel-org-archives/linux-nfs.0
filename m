Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:27891 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752988Ab1F0SmH convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Jun 2011 14:42:07 -0400
Subject: Re: Mounstats keying on fsid or ipaddr?
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Joe Frost <joef@pixar.com>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 27 Jun 2011 14:41:36 -0400
In-Reply-To: <4E08C8BE.2000407@pixar.com>
References: <4E08C8BE.2000407@pixar.com>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1309200096.25643.10.camel@lade.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2011-06-27 at 11:15 -0700, Joe Frost wrote: 
> We've been using mountstats to graph/track NFS usage based on path. 
> We've recently made some changes on how we mount filesystems here where 
> it's possible the same IP will be used for multiple mounts. Since that 
> we've noticed that all mounts to the same IPaddr are showing the same 
> statistics. Wondering if anyone had ideas why it might be keying off of 
> IPaddr?

mountstats keys off the fsid as reported on the _server_. If your server
is reporting that these directories are all contained in one big volume,
then that will suffice to confuse the client.

One way to work around this, is to tell the client that the
subdirectories are on different volumes. You can do that using the
"nosharecache" mount option. Beware, however, that if you have hard
linked files that appear under more than one of these mountpoints, then
the client will treat them as if they are completely separate files for
the purposes of caching and close-to-open cache consistency checking.

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

