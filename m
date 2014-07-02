Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:60780 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752212AbaGBVmF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Jul 2014 17:42:05 -0400
Date: Wed, 2 Jul 2014 17:42:04 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kinglong Mee <kinglongmee@gmail.com>
Cc: Avi Kivity <avi@cloudius-systems.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] nfs: fix nfs4d readlink truncated packet
Message-ID: <20140702214204.GF11510@fieldses.org>
References: <1403792592-1517-1-git-send-email-avi@cloudius-systems.com>
 <53B2999C.6090401@cloudius-systems.com>
 <53B3C56F.20406@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <53B3C56F.20406@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 02, 2014 at 04:40:15PM +0800, Kinglong Mee wrote:
> 
> On 7/1/2014 19:21, Avi Kivity wrote:
> > On 06/26/2014 05:23 PM, Avi Kivity wrote:
> >> XDR requires 4-byte alignment; nfs4d READLINK reply writes out the padding,
> >> but truncates the packet to the padding-less size.
> >>
> >> Fix by taking the padding into consideration when truncating the packet.
> >>
> > 
> > Ping.  I should have mentioned that without this, readlink() returns an I/O error on the client.

Thanks, queueing up for 3.16.

> Yes, I got
> [root@localhost ~]# ll /mnt/
> ls: cannot read symbolic link /mnt/test: Input/output error
> total 4
> -rw-r--r--. 1 root root  0 Jun 14 01:21 123456
> lrwxrwxrwx. 1 root root  6 Jul  2 03:33 test
> drwxr-xr-x. 1 root root  0 Jul  2 23:50 tmp
> drwxr-xr-x. 1 root root 60 Jul  2 23:44 tree
> [root@localhost ~]# 
> 
> It's introduced by commit 476a7b1f4b2c (nfsd4: don't treat readlink like a zero-copy operation).
...
> >> +    xdr_truncate_encode(xdr, length_offset + 4 + ALIGN(maxcount, 4));
> 
> NFSD uses (XDR_QUADLEN(maxcount) << 2)) usually.

Eh, I didn't know about ALIGN()--I think I prefer it.

> Anyway, it's a nice fix.
> 
> Reviewed-by: Kinglong Mee <kinglongmee@gmail.com>

Thanks!  I've also added your symptoms and the problematic commit to the
changelog.

--b.
