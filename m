Return-Path: linux-nfs-owner@vger.kernel.org
Received: from zeniv.linux.org.uk ([195.92.253.2]:56846 "EHLO
	ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303Ab2K2Xn2 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 18:43:28 -0500
Date: Thu, 29 Nov 2012 23:43:26 +0000
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Patrick McLean <patrickm@gaikai.com>
Cc: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: Regression with initramfs and nfsroot (appears to be in the
 dcache)
Message-ID: <20121129234326.GX4939@ZenIV.linux.org.uk>
References: <CAE2NFgU+4QDcLaVE5dKDvZCxey7qEf7FAbYNjNmcjVU=HLhF=A@mail.gmail.com>
 <20121129213316.GU4939@ZenIV.linux.org.uk>
 <CAE2NFgWCnmgSCsw7MzRkqBLTHgRDG-FvKKcbTHN6UqePK6Ef+Q@mail.gmail.com>
 <20121129222109.GW4939@ZenIV.linux.org.uk>
 <50B7E759.9070007@gaikai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <50B7E759.9070007@gaikai.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 29, 2012 at 02:53:13PM -0800, Patrick McLean wrote:
> On 29/11/12 02:21 PM, Al Viro wrote:
> > On Thu, Nov 29, 2012 at 02:06:22PM -0800, Patrick McLean wrote:
> > 
> >> I have a trivial reproducer and am happy to help debug in any way that
> >> I can. That patch seems to fix the problem, and produces these
> >> warnings in dmesg:
> > 
> > OK...  So we have differing entry->fh and NFS_FH(dentry->d_inode).  Something
> > like
> > static void dump_fh(const struct nfs_fh *fh)
> > {
> > 	int i;
> > 	printk(KERN_INFO "FH(%d)", fh->size);
> > 	for (i = 0; i < fh->size; i++)
> > 		printk(KERN_CONT "%c%02x", i ? ' ' : '[', fh->data[i]);
> > 	printk(KERN_CONT "]\n");
> > }
> > with dump_fh(entry->fh); dump_fh(NFS_FH(dentry->d_inode)); added next to
> > that WARN_ON(1) would probably be interesting.  And probably would make
> > sense to print filename->name as well, to see which files it is about.

> [    8.821584] FH(0)]
> [    8.821586] FH(36)[01 00 07 01 89 00 00 00 00 00 00 00 e1 21 fe c4 9e 38 44 dc bf 1b d5 95 d6 76 d6 d9 a7 3c 1b 80 33 38 e3 62]
> [    8.821601] filename: proc

*whoa*

So we have zero entry->fh->size?  No wonder it doesn't match...  Which NFS
version it is?  entry->fh->size is set by nfs[34]_decode_dirent().

NFS folks: any ideas on best way to debug it?  The brute-force way would be
to capture all NFS traffic with tcpdump and see what's going on, but that
would be a lot of work...

Looks like we have READDIRPLUS attempted and succeeded, but fhandle was not
given.  Result: nfs_prime_dcache() is doing blind d_drop() on perfectly
valid dentries, no matter how busy.
