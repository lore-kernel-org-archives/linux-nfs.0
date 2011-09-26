Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51369 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752054Ab1IZLpP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 26 Sep 2011 07:45:15 -0400
Message-ID: <4E8065C7.3060809@RedHat.com>
Date: Mon, 26 Sep 2011 07:45:11 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Jim Rees <rees@umich.edu>
CC: Linux NFS Mailing list <linux-nfs@vger.kernel.org>,
        peter honeyman <honey@citi.umich.edu>
Subject: Re: ANNOUNCE: nfs-utils-1.2.5 released.
References: <4E7DD35D.9080800@RedHat.com> <20110925165641.GA6088@umich.edu>
In-Reply-To: <20110925165641.GA6088@umich.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hey Jim,

On 09/25/2011 12:56 PM, Jim Rees wrote:
> Steve Dickson wrote:
> 
>   New Features in this release:
>   
>      * With the addition of the blkmapd daemon, the client 
>        now supports every pNFS layout type. 
>   
>      * The usual assorted bug fixes. 
>   
>   The tarball can only be found at Sourceforge.net since 
>   master.kernel.org is still down:
>   
>     http://sourceforge.net/projects/nfs
>   
>   [ Maybe we should start thinking about putting the rpms on linux-nfs.org?? ]
>   
>   The git tree is at:
>      git://linux-nfs.org/nfs-utils
>   
>   The change log is also only on Sourceforge.net:
>   
>   http://sourceforge.net/projects/nfs/files/nfs-utils/1.2.5/Changelog-1.2.5/download
> 
> I can't get it to configure.  I re-ran autogen then:
> 
> configure --prefix=/usr --sysconfdir=/etc --enable-nfsv41 --enable-ipv6 --disable-gss --disable-uuid --enable-tirpc --without-tcp-wrappers --disable-libmount-mount
> 
> The test for _doprnt seems to be failing and I end up with this in conftest.c:
> 
> ...
> #define HAVE_VPRINTF 1
> #define  1
> 
> where I think I should have something like "#define HAVE_DOPRNT 1".  All
> subsequent tests fail.
> 
> I put the config log here:
> http://www.citi.umich.edu/projects/nfsv4/pnfs/block/download/config.log
I'm not seeing this problem... I've run the configs on both F15 and F16

Try runing ./autogen.sh before running the ./configure script.

steved.
