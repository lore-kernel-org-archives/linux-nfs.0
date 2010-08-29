Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:36868 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753897Ab0H2TbX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 29 Aug 2010 15:31:23 -0400
Date: Sun, 29 Aug 2010 15:31:02 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Jeff Layton <jlayton@redhat.com>
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        chuck.lever@oracle.com, steved@redhat.com
Subject: Re: [PATCH] rpc.nfsd: mount up nfsdfs is it doesn't appear to be
 mounted yet
Message-ID: <20100829193102.GA1627@fieldses.org>
References: <1282995314-8317-1-git-send-email-jlayton@redhat.com>
 <20100829083853.4e95d2ee@notabene>
 <20100828222450.7ca62e49@corrin.poochiereds.net>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20100828222450.7ca62e49@corrin.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sat, Aug 28, 2010 at 10:24:50PM -0400, Jeff Layton wrote:
> I considered that when I did this, but didn't know if we could count on
> nfsdfs automatically being mounted up when nfsd.ko is plugged in. I
> went with calling system() since I figured we'd be making less
> assumptions about modprobe.conf configuration.
> 
> FWIW, at least on fedora the /bin/mount here usually returns an
> error. /bin/mount calls mount() and that triggers a request_module()
> for nfsdfs. That triggers modprobe to mount the fs, and /bin/mount then
> returns an error since it's already mounted. The error though is
> harmless in this case since the fs gets mounted up anyway.
> 
> If the consensus is that using a no-op nfsctl() call is better than
> shelling out to /bin/mount here, then I'll go with that. It seems
> though like the patch I've already proposed would allow for nfsdfs to
> end up mounted even when modprobe.conf isn't set up to do it.

I'd rather not rely on modprobe.  It's partly a personal grudge: I
usually build nfsd into kernels when I test, and that always requires
a minor scuffle or two with init scripts that assume nfsd should be a
module.

--b.
