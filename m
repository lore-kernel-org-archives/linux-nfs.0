From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Bug in server's export -- List of security flavors
Date: Thu, 16 Jul 2009 14:56:42 -0400
Message-ID: <20090716185642.GB2495@fieldses.org>
References: <4A5F5C4C.3070308@excfb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:41050 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933019AbZGPS4m (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 16 Jul 2009 14:56:42 -0400
In-Reply-To: <4A5F5C4C.3070308-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jul 16, 2009 at 11:58:52AM -0500, Tom Haynes wrote:
> [tdh@adept tournament]> exportfs -rva
> exporting 192.168.2.0/255.255.255.0:/home
> exporting *:/
> exportfs: could not open /var/lib/nfs/etab for locking
> exportfs: can't lock /var/lib/nfs/etab for writing
> [tdh@adept tournament]> more /etc/exports
> / *(sync)
> /home  
> 192.168.2.0/255.255.255.0(rw,async,no_subtree_check,insecure,no_root_squash)
> [tdh@adept tournament]> uname -a
> Linux adept.internal.excfb.com 2.6.29.4-167.fc11.i586 #1 SMP Wed May 27  
> 17:14:37 EDT 2009 i686 i686 i386 GNU/Linux
>
> So, adept:/home is exported in a fairly typical way that I've had going for
> the past 3 years.
>
> [root@witch ~]> mount -o vers=3 adept:/home /mnt
> nfs mount: security mode does not match the server exporting adept:/home
>
> The server is not sending any authentication flavors:
>
> MOUNT:----- NFS MOUNT -----
> MOUNT:
> MOUNT:Proc = 1 (Add mount entry)
> MOUNT:Status = 0 (OK)
> MOUNT:File handle = [DADF]
> MOUNT: 01000700010005000000000053CF6DE4FF1C4572BB2950392EB6993C
> MOUNT:Authentication flavor =
> MOUNT:
>
> And yet this mount will work from a Linux box:
>
> root@slayer:~# uname -a
> Linux slayer 2.6.28-13-generic #45-Ubuntu SMP Tue Jun 30 19:49:51 UTC  
> 2009 i686 GNU/Linux
> root@slayer:~# mount -o vers=3 adept:/home /mnt
>
> I'm guessing that the Linux client is ignoring the list and trying the  
> default AUTH_SYS anyway. Is that
> also a bug on the client, using a flavor not advertised by the server?

I don't see how it could be a problem for the client to try an
unadvertised flavor.  The server has to enforce the choice of flavor
anyway.

(Um, but that's pretty weird that the server's advertising an empty
list.  What's the nfs-utils version?)

--b.
