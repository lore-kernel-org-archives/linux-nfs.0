From: Steve Dickson <SteveD@redhat.com>
Subject: Re: nfs-utils mountd getfh failed: No such file or directory
Date: Wed, 17 Dec 2008 17:41:45 -0500
Message-ID: <49498029.1080307@RedHat.com>
References: <x6k5a0166x@gzp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "Gabor Z. Papp" <gzp-2g/1Y3AqmNE@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:53011 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751440AbYLQWn7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 17 Dec 2008 17:43:59 -0500
In-Reply-To: <x6k5a0166x@gzp>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>



Gabor Z. Papp wrote:
> Hello,
> 
> I would like to use nfs-utils 1.1.4 (and 1.1.*) in the following environment:
> 
> [kernel]
> Linux gzp 2.6.27.9-gzp2 #1 Tue Dec 16 15:17:04 CET 2008 i686 GNU/Linux
> 
> [glibc]
> GNU C Library stable release version 2.3.6, by Roland McGrath et al.
> Compiled by GNU CC version 4.1.2.
> Compiled on a Linux 2.4.34-gzp1 system on 2007-04-04.
> 
> But getting this error after trying to mount from remote:
> 
> 2008 Dec 16 15:48:44 <daemon.info> gzp portmap[1843]: connect from 192.168.1.1 to getport(nfs)
> 2008 Dec 16 15:48:44 <daemon.info> gzp portmap[1844]: connect from 192.168.1.1 to getport(mountd)
> 2008 Dec 16 15:48:44 <daemon.notice> gzp mountd[1748]: authenticated mount request from 192.168.1.1:835 for /var/archive/sda1 (/var/archive/sda1)
> 2008 Dec 16 15:48:44 <daemon.warning> gzp mountd[1748]: getfh failed: No such file or directory
> 
> Found the revelant code in the mountd source, but I don't know what is this error.
This might be due to the fact that the nfsd module is not loaded when
mountd is started since it appears mountd is not using the new caching.

Make sure a 'modprobe nfsd' happens before mountd is started...

steved.

