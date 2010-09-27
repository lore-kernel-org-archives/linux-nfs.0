Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:42352 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756307Ab0I0RMb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 27 Sep 2010 13:12:31 -0400
Date: Mon, 27 Sep 2010 13:12:27 -0400
To: Malte Zacharias <kernel-ml-alias@asenwelt.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: NFS+krb5 ID mapping always maps to nobody
Message-ID: <20100927171227.GA12033@fieldses.org>
References: <4C9E72BB.5080000@asenwelt.de>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4C9E72BB.5080000@asenwelt.de>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Sun, Sep 26, 2010 at 12:07:55AM +0200, Malte Zacharias wrote:
> Hello,
> 
> I have been trying to configure an nfsv4 client and server for my
> network for some time now, but there is one issue I can't resolve.
> 
> I run a small (2-5 clients) network using .local as a domain suffix and
> for mDNS resolution. For "historical" reasons, my Kerberos Realm is
> TADPOLE. I setup an NFSv4 server and Client that uses Kerberos for
> authentication.
> 
> My problem is that everytime my client accesses the server, its ID is
> mapped to nobody, but I can't find any reason as to why this is
> happening. I verified this by creating a file via NFS and it always is
> created under user nobody. Test scenarios were:
>  - Identical usernames, different UIDs
>  - Identical usernames, Identical groupnames, Identical UIDs/GIDs

If you're using kerberos then it's the kerberos principal name->uid
mapping that matters here.

So:

> This is a sample command sequence for my problem:
> /mnt/nfs/heap is writeable by everyone, /mnt/nfs/nfstest01 only by
> nfstest01:
> ===============================================
> nfstest01@desktop:/$ touch /mnt/nfs/heap/test
> nfstest01@desktop:/$ touch /mnt/nfs/nfstest01/test
> touch: cannot touch `/mnt/nfs/nfstest01/test': Permission denied
> nfstest01@desktop:/$ ls -l /mnt/nfs/heap/test
> -rw-r--r-- 1 nobody nogroup 0 2010-09-26 00:02 /mnt/nfs/heap/test
> nfstest01@desktop:/$ ls -l /mnt/nfs/
> drwxr-xrwx  8 malte     users     8192 2010-09-26 00:02 heap
> drwxr-x---  2 nfstest01 nfstest01 4096 2010-09-25 22:34 nfstest01
> nfstest01@desktop:/$ id
> uid=4321(nfstest01) gid=4321(nfstest01) groups=4321(nfstest01)
> 
> ===============================================

who did you kinit as before doing this?  (What does klist say?)

--b.
