From: "Frank A. Kingswood" <frank-YzJE6wl5KmBjuoFY8sQqqY5Lr7LD32fptUK59QYPAWc@public.gmane.org>
Subject: Re: Text-based mount interface breaking non-UDP mounts
Date: Sat, 26 Apr 2008 16:23:16 +0100
Message-ID: <481348E4.3000003@kingswood-consulting.co.uk>
References: <20080423214929.GA24387@uio.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Cc: public-linux-nfs-u79uwXL29TY76Z2rM5mHXA-8ByrlEUxsivZ+VzJOa5vwg@public.gmane.org
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:57908 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753629AbYDZPZH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 26 Apr 2008 11:25:07 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1JpmGs-0005c2-5O
	for linux-nfs@vger.kernel.org; Sat, 26 Apr 2008 15:25:02 +0000
Received: from 88-97-16-53.dsl.zen.co.uk ([88.97.16.53])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 26 Apr 2008 15:25:02 +0000
Received: from frank by 88-97-16-53.dsl.zen.co.uk with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-nfs@vger.kernel.org>; Sat, 26 Apr 2008 15:25:02 +0000
In-Reply-To: <20080423214929.GA24387-6Z/AllhyZU4@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Steinar H. Gunderson wrote:
> Hi,
> 
> I've gotten a few bug reports lately that if UDP is blocked at the server,
> NFS mounts (even with -o tcp) fail. git bisect shows that the culprit is
> the change "Get rid of the "-i" option for mount.nfs[4] and always use the
> text-based mount(2) system call for kernel version 2.6.23 and later." -- in
> other words, the bug is specific to the text interface. Does anyone know why
> this would be the case?
This also fails for me. My setup is through an ssh tunnel
    ssh -L2049:srv:2049 -L2050:srv:2050 -L2051:srv:2051ser@gateway

and I follow that with
    strace mount localhost:/export /mountpoint \
              -o nfsvers=3,port=2049,mountport=2050,...

This hangs in this kernel call
   mount("localhost:/export", "/mountpoint", "nfs", 
MS_NOSUID|MS_NOATIME, 
"tcp,intr,fg,soft,nfsvers=3,port=2049,mountport=2050,nolock,addr=127.0.0.1"

This hack makes it work for me again:

diff -ru nfs-utils-1.1.2/utils/mount/mount.c 
nfs-utils-1.1.2-changed/utils/mount/mount.c
--- nfs-utils-1.1.2/utils/mount/mount.c	2008-03-14 15:46:29 +0000
+++ nfs-utils-hack/utils/mount/mount.c	2008-04-26 15:49:55 +0100
@@ -191,7 +191,8 @@
  		nfs_mount_data_version = NFS_MOUNT_VERSION;
  	else
  		if (kernel_version > MAKE_VERSION(2, 6, 22))
-			string++;
+			string=0;
  }

  static void print_one(char *spec, char *node, char *type, char *opts)

Frank

