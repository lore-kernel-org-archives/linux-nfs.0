Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37668 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758222Ab3ENV4s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 May 2013 17:56:48 -0400
Date: Tue, 14 May 2013 17:56:48 -0400
To: Alex Pillow <halibubaley@mail.ru>
Cc: linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: Hangs when do ls on mount directory
Message-ID: <20130514215648.GD16811@fieldses.org>
References: <1368522346.397819588@f140.mail.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <1368522346.397819588@f140.mail.ru>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, May 14, 2013 at 01:05:46PM +0400, Alex Pillow wrote:
>  Hello all!
> 
> Can someone help me with my problem?
> I have nfs-server on Centos 6 with kernel 2.6.32 and nfs-client on OpenSUSE 11.4 with kernel 2.6.37
> 
> /etc/exports on server:
> /data/input     10.100.0.65/32(rw,sync,no_root_squash,no_subtree_check,no_wdelay,no_acl)
> 
> /etc/fstab on client:
> 10.100.0.214:/data/input    /mnt/input  nfs     rw,sync,bg,auto,intr,hard,rsize=32768,wsize=32768,vers=4,timeo=600,tcp,noatime,nodiratime
> 
> Everything works fine, but in some cases i have a problem:
> In the first session on client i start to copy a large file (10-40Gb), and in second session on client i trying read /mnt/input

You're copying it from where to where?

There's a known problem with "ls -l" being slow in the presence of lots
of writes, for reasons that are a little hard to fix.  (There should be
a FAQ for this somewhere.)

--b.

> 
> w:/ # time ls -la /mnt/input
> total 68819848
> drwxrwxrwx 2 nobody nobody          68 May 14 12:17 .
> drwxr-xr-x 8 root   root          4096 May  6 14:18 ..
> -rw-r--r-- 1 nobody users  20722711568 May 14 04:22 14PR0035M.mxf
> -rw-r--r-- 1 root   root   20536435216 May 14 12:22 14PR0035T.mxf
> -rw-r--r-- 1 nobody users  13279567128 May 14 03:23 14VO0180M_1.mxf
> 
> real    0m31.796s
> user    0m0.000s
> sys     0m0.066s
> 
> In output of strace (strace ls -la /mnt/input) i see
> 
> lstat("/mnt/input/14PR0035M.mxf", {st_mode=S_IFREG|0644, st_size=20722711568, ...}) = 0
> lgetxattr("/mnt/input/14PR0035M.mxf", "security.selinux", 0x6295b0, 255) = -1 EOPNOTSUPP (Operation not supported)
> getxattr("/mnt/input/14PR0035M.mxf", "system.posix_acl_access", 0x0, 0) = -1 EOPNOTSUPP (Operation not supported)
> lstat("/mnt/input/14PR0035T.mxf",
> 
> And these output hang up on 15-40 seconds.
> 
> 14PR0035T.mxf - is the name of the file which now is transferred in first session. Output always hangs on the file that now is transferred.\
> 
> ls -la /data/input on server works fine. 
> 
> What can be done to solve this problem?
