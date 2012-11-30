Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-pb0-f46.google.com ([209.85.160.46]:63814 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753766Ab2K3ATy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 19:19:54 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so20078pbc.19
        for <linux-nfs@vger.kernel.org>; Thu, 29 Nov 2012 16:19:53 -0800 (PST)
Message-ID: <50B7FBA7.2030300@gaikai.com>
Date: Thu, 29 Nov 2012 16:19:51 -0800
From: Patrick McLean <patrickm@gaikai.com>
MIME-Version: 1.0
To: Al Viro <viro@ZenIV.linux.org.uk>
CC: linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: Regression with initramfs and nfsroot (appears to be in the dcache)
References: <CAE2NFgU+4QDcLaVE5dKDvZCxey7qEf7FAbYNjNmcjVU=HLhF=A@mail.gmail.com> <20121129213316.GU4939@ZenIV.linux.org.uk> <CAE2NFgWCnmgSCsw7MzRkqBLTHgRDG-FvKKcbTHN6UqePK6Ef+Q@mail.gmail.com> <20121129222109.GW4939@ZenIV.linux.org.uk> <50B7E759.9070007@gaikai.com> <20121129234326.GX4939@ZenIV.linux.org.uk>
In-Reply-To: <20121129234326.GX4939@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 29/11/12 03:43 PM, Al Viro wrote:
> On Thu, Nov 29, 2012 at 02:53:13PM -0800, Patrick McLean wrote:
>> On 29/11/12 02:21 PM, Al Viro wrote:
>>> On Thu, Nov 29, 2012 at 02:06:22PM -0800, Patrick McLean wrote:
>>>
>>>> I have a trivial reproducer and am happy to help debug in any way that
>>>> I can. That patch seems to fix the problem, and produces these
>>>> warnings in dmesg:
>>>
>>> OK...  So we have differing entry->fh and NFS_FH(dentry->d_inode).  Something
>>> like
>>> static void dump_fh(const struct nfs_fh *fh)
>>> {
>>> 	int i;
>>> 	printk(KERN_INFO "FH(%d)", fh->size);
>>> 	for (i = 0; i < fh->size; i++)
>>> 		printk(KERN_CONT "%c%02x", i ? ' ' : '[', fh->data[i]);
>>> 	printk(KERN_CONT "]\n");
>>> }
>>> with dump_fh(entry->fh); dump_fh(NFS_FH(dentry->d_inode)); added next to
>>> that WARN_ON(1) would probably be interesting.  And probably would make
>>> sense to print filename->name as well, to see which files it is about.
> 
>> [    8.821584] FH(0)]
>> [    8.821586] FH(36)[01 00 07 01 89 00 00 00 00 00 00 00 e1 21 fe c4 9e 38 44 dc bf 1b d5 95 d6 76 d6 d9 a7 3c 1b 80 33 38 e3 62]
>> [    8.821601] filename: proc
> 
> *whoa*
> 
> So we have zero entry->fh->size?  No wonder it doesn't match...  Which NFS
> version it is?  entry->fh->size is set by nfs[34]_decode_dirent().

This is nfs v3 over TCP on Linus git at commit e9296e89b85604862bd9ec2d54dc43edad775c0d with nfs-utils-1.2.6 userspace.

> NFS folks: any ideas on best way to debug it?  The brute-force way would be
> to capture all NFS traffic with tcpdump and see what's going on, but that
> would be a lot of work...
> 
> Looks like we have READDIRPLUS attempted and succeeded, but fhandle was not
> given.  Result: nfs_prime_dcache() is doing blind d_drop() on perfectly
> valid dentries, no matter how busy.
> 
