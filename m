From: Tom Haynes <tdh-8AdZ+HgO7noAvxtiuMwx3w@public.gmane.org>
Subject: Bug in server's export -- List of security flavors
Date: Thu, 16 Jul 2009 11:58:52 -0500
Message-ID: <4A5F5C4C.3070308@excfb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from eastrmmtao105.cox.net ([68.230.240.47]:39734 "EHLO
	eastrmmtao105.cox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932617AbZGPQ7F (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jul 2009 12:59:05 -0400
Received: from eastrmimpo03.cox.net ([68.1.16.126])
          by eastrmmtao105.cox.net
          (InterMail vM.7.08.02.01 201-2186-121-102-20070209) with ESMTP
          id <20090716165903.WJGK14338.eastrmmtao105.cox.net-jOUDVclVbkx9GQUQ9EqIheTW4wlIGRCZ@public.gmane.org>
          for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2009 12:59:03 -0400
Received: from [192.168.2.115] (kanigix.internal.excfb.com [192.168.2.115])
	by adept.internal.excfb.com (8.14.3/8.14.2) with ESMTP id n6GGx0r1008530
	for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2009 11:59:02 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

[tdh@adept tournament]> exportfs -rva
exporting 192.168.2.0/255.255.255.0:/home
exporting *:/
exportfs: could not open /var/lib/nfs/etab for locking
exportfs: can't lock /var/lib/nfs/etab for writing
[tdh@adept tournament]> more /etc/exports
/ *(sync)
/home 
192.168.2.0/255.255.255.0(rw,async,no_subtree_check,insecure,no_root_squash)
[tdh@adept tournament]> uname -a
Linux adept.internal.excfb.com 2.6.29.4-167.fc11.i586 #1 SMP Wed May 27 
17:14:37 EDT 2009 i686 i686 i386 GNU/Linux

So, adept:/home is exported in a fairly typical way that I've had going for
the past 3 years.

[root@witch ~]> mount -o vers=3 adept:/home /mnt
nfs mount: security mode does not match the server exporting adept:/home

The server is not sending any authentication flavors:

MOUNT:----- NFS MOUNT -----
MOUNT:
MOUNT:Proc = 1 (Add mount entry)
MOUNT:Status = 0 (OK)
MOUNT:File handle = [DADF]
MOUNT: 01000700010005000000000053CF6DE4FF1C4572BB2950392EB6993C
MOUNT:Authentication flavor =
MOUNT:

And yet this mount will work from a Linux box:

root@slayer:~# uname -a
Linux slayer 2.6.28-13-generic #45-Ubuntu SMP Tue Jun 30 19:49:51 UTC 
2009 i686 GNU/Linux
root@slayer:~# mount -o vers=3 adept:/home /mnt

I'm guessing that the Linux client is ignoring the list and trying the 
default AUTH_SYS anyway. Is that
also a bug on the client, using a flavor not advertised by the server?
