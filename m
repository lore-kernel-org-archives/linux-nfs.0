Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:29555 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751250Ab0IVQGo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Sep 2010 12:06:44 -0400
Subject: Re: [PATCH] nfs: introduce mount option '-olocal_lock' to make
 locks local (try++)
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Suresh Jayaraman <sjayaraman@suse.de>
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
        Neil Brown <neilb@suse.de>
In-Reply-To: <4C97416F.7020504@suse.de>
References: <4C97416F.7020504@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 22 Sep 2010 12:06:42 -0400
Message-ID: <1285171602.4811.54.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-09-20 at 16:41 +0530, Suresh Jayaraman wrote:
> Changes since last post:
> 
>    - NFS_MOUNT_NONLM definition remains unmodified as legacy binary mount
>      interface uses it
>    - Fixed an Oops in _nfs4_do_setlk() found during NFSv4 reboot recovery
>    - Rebased against Trond's nfs-2.6.git (nfs-for-2.6.37 branch)
> 
> Thanks,
> Suresh Jayaraman
> 

Suresh,

This still appears to break the binary mount interface. You need
something in nfs_validate_mount_data() to convert the NFS_MOUNT_NONLM
flag into (NFS_MOUNT_LOCAL_FLOCK | NFS_MOUNT_LOCAL_FCNTL).

Cheers
  Trond
