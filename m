From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] nfs: introduce mount option '-olocal_lock' to make
 locks local (try++)
Date: Thu, 23 Sep 2010 08:56:54 -0400
Message-ID: <1285246614.7809.0.camel@heimdal.trondhjem.org>
References: <4C97416F.7020504@suse.de>
	 <1285171602.4811.54.camel@heimdal.trondhjem.org> <4C9AFD56.4090603@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux NFS mailing list <linux-nfs@vger.kernel.org>,
	Neil Brown <neilb@suse.de>
To: Suresh Jayaraman <sjayaraman@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:62672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754826Ab0IWM5L convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Sep 2010 08:57:11 -0400
In-Reply-To: <4C9AFD56.4090603@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-09-23 at 12:40 +0530, Suresh Jayaraman wrote:
> On 09/22/2010 09:36 PM, Trond Myklebust wrote:
> > On Mon, 2010-09-20 at 16:41 +0530, Suresh Jayaraman wrote:
> >> Changes since last post:
> >>
> >>    - NFS_MOUNT_NONLM definition remains unmodified as legacy binary mount
> >>      interface uses it
> >>    - Fixed an Oops in _nfs4_do_setlk() found during NFSv4 reboot recovery
> >>    - Rebased against Trond's nfs-2.6.git (nfs-for-2.6.37 branch)
> >>
> >> Thanks,
> >> Suresh Jayaraman
> >>
> > 
> > Suresh,
> > 
> > This still appears to break the binary mount interface. You need
> > something in nfs_validate_mount_data() to convert the NFS_MOUNT_NONLM
> > flag into (NFS_MOUNT_LOCAL_FLOCK | NFS_MOUNT_LOCAL_FCNTL).
> > 
> 
> Good catch, thanks. Here's the fixed version (haven't tested it as I don't
> find a simple way to test it and it looks obvious):

Hi Suresh,

This one looks good to me.

Thanks!
  Trond
