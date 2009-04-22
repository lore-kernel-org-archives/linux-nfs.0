From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 0/3] nfs-utils: nfsd support for minor version, take 2
Date: Wed, 22 Apr 2009 17:54:58 -0400
Message-ID: <20090422215458.GL9541@fieldses.org>
References: <49E2F6E4.2080501@panasas.com> <49EF0846.5030800@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Steve Dickson <steved@redhat.com>,
	NFS list <linux-nfs@vger.kernel.org>,
	pNFS Mailing List <pnfs@linux-nfs.org>,
	Chuck Lever <chuck.lever@oracle.com>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([141.211.133.115]:35218 "EHLO
	pickle.fieldses.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752127AbZDVVzB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 22 Apr 2009 17:55:01 -0400
In-Reply-To: <49EF0846.5030800@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Apr 22, 2009 at 03:06:30PM +0300, Benny Halevy wrote:
> Following the discussion we had last week
> (see http://linux-nfs.org/pipermail/pnfs/2009-April/007283.html)
> 
> I made the following changes:
> * minorvers4 enabled by default.
> * No new -n option.
> 
> This makes minorvers control essentially the same as
> the major protocol version.  minorvers4 is enabled by default
> and can be disabled using -N 4.1.
> 
> On Fedora, /etc/sysconfig/nfs can be changed as follows
> to configure the service startup script to disable 4.1:

Why couldn't nfs-utils just respect the kernel's default and make no
attempt to set the minor version?  A (possibly undocumented) -P 4.1
option (or some other name) could be used by testers to specify that
they want 4.1.  After things have settled down a little we'd change the
kernel's default, and then only -N 4.1 would be needed.

If I'd known we'd be enabling 4.1 by default in nfs-utils, I wouldn't
have been so happy about removing the 4.1 config option--how confident
are we that the 4.1 code to be in 2.6.30 has no security holes?

--b.

> 
> --- /etc/sysconfig/nfs.orig	2009-04-22 14:57:15.000000000 +0300
> +++ /etc/sysconfig/nfs	2009-04-22 14:46:52.000000000 +0300
> @@ -26,6 +26,8 @@
>  #RPCNFSDARGS="-N 2 -N 3"
>  # Turn off v4 protocol support
>  #RPCNFSDARGS="-N 4"
> +# Turn off v4.1 minorversion support
> +RPCNFSDARGS="-N 4.1"
>  # Number of nfs server processes to be started.
>  # The default is 8. 
>  #RPCNFSDCOUNT=8
> 
> The patches in this set are:
> [PATCH 1/3] utils/nfsd: add support for minorvers4
> [PATCH 2/3] utils/nfsd: disable minorvers4 via command line
> [PATCH 3/3] utils/nfsd: enable nfs minorvers4 by default
> 
> Benny
