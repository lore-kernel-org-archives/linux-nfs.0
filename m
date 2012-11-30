Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.cim.mcgill.ca ([132.206.73.2]:37338 "EHLO
	orford.cim.mcgill.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751303Ab2K3BEw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Nov 2012 20:04:52 -0500
Message-ID: <50B8046F.7030308@cim.mcgill.ca>
Date: Thu, 29 Nov 2012 16:57:19 -0800
From: Patrick McLean <patrick@cim.mcgill.ca>
MIME-Version: 1.0
To: Al Viro <viro@ZenIV.linux.org.uk>
CC: Patrick McLean <patrickm@gaikai.com>, linux-fsdevel@vger.kernel.org,
        linux-kernel@vger.kernel.org,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-nfs@vger.kernel.org
Subject: Re: Regression with initramfs and nfsroot (appears to be in the dcache)
References: <CAE2NFgU+4QDcLaVE5dKDvZCxey7qEf7FAbYNjNmcjVU=HLhF=A@mail.gmail.com> <20121129213316.GU4939@ZenIV.linux.org.uk> <CAE2NFgWCnmgSCsw7MzRkqBLTHgRDG-FvKKcbTHN6UqePK6Ef+Q@mail.gmail.com> <20121129222109.GW4939@ZenIV.linux.org.uk> <50B7E759.9070007@gaikai.com> <20121129234326.GX4939@ZenIV.linux.org.uk> <50B7FBA7.2030300@gaikai.com> <20121130003502.GY4939@ZenIV.linux.org.uk>
In-Reply-To: <20121130003502.GY4939@ZenIV.linux.org.uk>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 29/11/12 04:35 PM, Al Viro wrote:
> On Thu, Nov 29, 2012 at 04:19:51PM -0800, Patrick McLean wrote:
>>>> [    8.821584] FH(0)]
>>>> [    8.821586] FH(36)[01 00 07 01 89 00 00 00 00 00 00 00 e1 21 fe c4 9e 38 44 dc bf 1b d5 95 d6 76 d6 d9 a7 3c 1b 80 33 38 e3 62]
>>>> [    8.821601] filename: proc
>>>
>>> *whoa*
>>>
>>> So we have zero entry->fh->size?  No wonder it doesn't match...  Which NFS
>>> version it is?  entry->fh->size is set by nfs[34]_decode_dirent().
>>
>> This is nfs v3 over TCP on Linus git at commit e9296e89b85604862bd9ec2d54dc43edad775c0d with nfs-utils-1.2.6 userspace.
> 
> So we have nfs3_decode_dirent(), stepping into
>                 /* In fact, a post_op_fh3: */
>                 p = xdr_inline_decode(xdr, 4);
>                 if (unlikely(p == NULL))
>                         goto out_overflow;
>                 if (*p != xdr_zero) {
>                         error = decode_nfs_fh3(xdr, entry->fh);
>                         if (unlikely(error)) {
>                                 if (error == -E2BIG)
>                                         goto out_truncated;
>                                 return error;
>                         }
>                 } else
>                         zero_nfs_fh3(entry->fh);
> Interesting...  Server-side that should've been produced by
> encode_entryplus_baggage(), which looks like failing compose_entry_fh()...
> which has explicit
>         if (d_mountpoint(dchild))
>                 goto out;
> resulting in ENOENT on everything that's overmounted on server.
> 
> Do you, by any chance, have the server really exporting its own root
> filesystem?  Another thing to check: have nfs_prime_dcache() print
> filename.name of everything that fails nfs_same_entry() and has
> zero entry->fh->size, regardless of d_invalidate() results.

The server is running 3.6.6 and is just exporting a subdir of an xfs filesystem (which does not happen to be the root filesystem).

The client is running as a KVM guest on the machine that is serving the NFS. I am reproducing this by booting the guest via an initramfs, and doing
"ls /" at in single user mode.

I added a check that prints the filename.name of everything that fails nfs_same_file, and it appears to just be triggered by the same filesystems that
are triggering the WARN_ON, the relevant dmesg is below.

[    9.495217] entry->fh->size is 0 on: proc
[    9.495222] ------------[ cut here ]------------
[    9.495230] WARNING: at fs/nfs/dir.c:464 nfs_readdir_page_filler+0x1ef/0x3eb()
[    9.495232] Hardware name: Bochs
[    9.495233] Modules linked in:
[    9.495237] Pid: 655, comm: ls Not tainted 3.7.0-rc7+ #40
[    9.495239] Call Trace:
[    9.495247]  [<ffffffff8108534c>] ? warn_slowpath_common+0x76/0x8a
[    9.495250]  [<ffffffff8117deb4>] ? nfs_readdir_page_filler+0x1ef/0x3eb
[    9.495254]  [<ffffffff8117e6cc>] ? nfs_readdir_xdr_to_array+0x1c0/0x22d
[    9.495257]  [<ffffffff8117e755>] ? nfs_readdir_filler+0x1c/0x6b
[    9.495263]  [<ffffffff810dca9a>] ? add_to_page_cache_lru+0x2c/0x36
[    9.495266]  [<ffffffff8117e739>] ? nfs_readdir_xdr_to_array+0x22d/0x22d
[    9.495269]  [<ffffffff810dcbe3>] ? do_read_cache_page+0x7d/0x12b
[    9.495274]  [<ffffffff811274f8>] ? sys_ioctl+0x7a/0x7a
[    9.495277]  [<ffffffff810dccc6>] ? read_cache_page+0x7/0x10
[    9.495280]  [<ffffffff8117e8d1>] ? nfs_readdir+0x12d/0x435
[    9.495285]  [<ffffffff8118e69b>] ? nfs3_xdr_dec_create3res+0xc5/0xc5
[    9.495288]  [<ffffffff811274f8>] ? sys_ioctl+0x7a/0x7a
[    9.495291]  [<ffffffff811274f8>] ? sys_ioctl+0x7a/0x7a
[    9.495294]  [<ffffffff811277b3>] ? vfs_readdir+0x6c/0xa7
[    9.495298]  [<ffffffff811278da>] ? sys_getdents+0x7e/0xdc
[    9.495302]  [<ffffffff814ac829>] ? system_call_fastpath+0x16/0x1b
[    9.495304] ---[ end trace e502c5d56c594e85 ]---
[    9.495306] FH(0)]
[    9.495308] FH(36)[01 00 07 01 89 00 00 00 00 00 00 00 e1 21 fe c4 9e 38 44 dc bf 1b d5 95 d6 76 d6 d9 a7 3c 1b 80 33 38 e3 62]
[    9.495323] filename: proc
[    9.495330] entry->fh->size is 0 on: dev
[    9.495332] ------------[ cut here ]------------
[    9.495335] WARNING: at fs/nfs/dir.c:464 nfs_readdir_page_filler+0x1ef/0x3eb()
[    9.495336] Hardware name: Bochs
[    9.495337] Modules linked in:
[    9.495340] Pid: 655, comm: ls Tainted: G        W    3.7.0-rc7+ #40
[    9.495341] Call Trace:
[    9.495345]  [<ffffffff8108534c>] ? warn_slowpath_common+0x76/0x8a
[    9.495348]  [<ffffffff8117deb4>] ? nfs_readdir_page_filler+0x1ef/0x3eb
[    9.495351]  [<ffffffff8117e6cc>] ? nfs_readdir_xdr_to_array+0x1c0/0x22d
[    9.495354]  [<ffffffff8117e755>] ? nfs_readdir_filler+0x1c/0x6b
[    9.495358]  [<ffffffff810dca9a>] ? add_to_page_cache_lru+0x2c/0x36
[    9.495361]  [<ffffffff8117e739>] ? nfs_readdir_xdr_to_array+0x22d/0x22d
[    9.495364]  [<ffffffff810dcbe3>] ? do_read_cache_page+0x7d/0x12b
[    9.495368]  [<ffffffff811274f8>] ? sys_ioctl+0x7a/0x7a
[    9.495371]  [<ffffffff810dccc6>] ? read_cache_page+0x7/0x10
[    9.495373]  [<ffffffff8117e8d1>] ? nfs_readdir+0x12d/0x435
[    9.495377]  [<ffffffff8118e69b>] ? nfs3_xdr_dec_create3res+0xc5/0xc5
[    9.495380]  [<ffffffff811274f8>] ? sys_ioctl+0x7a/0x7a
[    9.495383]  [<ffffffff811274f8>] ? sys_ioctl+0x7a/0x7a
[    9.495387]  [<ffffffff811277b3>] ? vfs_readdir+0x6c/0xa7
[    9.495390]  [<ffffffff811278da>] ? sys_getdents+0x7e/0xdc
[    9.495393]  [<ffffffff814ac829>] ? system_call_fastpath+0x16/0x1b
[    9.495395] ---[ end trace e502c5d56c594e86 ]---
[    9.495396] FH(0)]
[    9.495397] FH(36)[01 00 07 01 89 00 00 00 00 00 00 00 e1 21 fe c4 9e 38 44 dc bf 1b d5 95 d6 76 d6 d9 85 00 00 40 d6 39 e0 7d]
[    9.495412] filename: dev
[    9.495422] entry->fh->size is 0 on: sys
[    9.495423] ------------[ cut here ]------------
[    9.495426] WARNING: at fs/nfs/dir.c:464 nfs_readdir_page_filler+0x1ef/0x3eb()
[    9.495427] Hardware name: Bochs
[    9.495428] Modules linked in:
[    9.495430] Pid: 655, comm: ls Tainted: G        W    3.7.0-rc7+ #40
[    9.495431] Call Trace:
[    9.495435]  [<ffffffff8108534c>] ? warn_slowpath_common+0x76/0x8a
[    9.495438]  [<ffffffff8117deb4>] ? nfs_readdir_page_filler+0x1ef/0x3eb
[    9.495441]  [<ffffffff8117e6cc>] ? nfs_readdir_xdr_to_array+0x1c0/0x22d
[    9.495444]  [<ffffffff8117e755>] ? nfs_readdir_filler+0x1c/0x6b
[    9.495448]  [<ffffffff810dca9a>] ? add_to_page_cache_lru+0x2c/0x36
[    9.495450]  [<ffffffff8117e739>] ? nfs_readdir_xdr_to_array+0x22d/0x22d
[    9.495454]  [<ffffffff810dcbe3>] ? do_read_cache_page+0x7d/0x12b
[    9.495457]  [<ffffffff811274f8>] ? sys_ioctl+0x7a/0x7a
[    9.495460]  [<ffffffff810dccc6>] ? read_cache_page+0x7/0x10
[    9.495463]  [<ffffffff8117e8d1>] ? nfs_readdir+0x12d/0x435
[    9.495466]  [<ffffffff8118e69b>] ? nfs3_xdr_dec_create3res+0xc5/0xc5
[    9.495470]  [<ffffffff811274f8>] ? sys_ioctl+0x7a/0x7a
[    9.495473]  [<ffffffff811274f8>] ? sys_ioctl+0x7a/0x7a
[    9.495476]  [<ffffffff811277b3>] ? vfs_readdir+0x6c/0xa7
[    9.495479]  [<ffffffff811278da>] ? sys_getdents+0x7e/0xdc
[    9.495482]  [<ffffffff814ac829>] ? system_call_fastpath+0x16/0x1b
[    9.495484] ---[ end trace e502c5d56c594e87 ]---
[    9.495485] FH(0)]
[    9.495486] FH(36)[01 00 07 01 89 00 00 00 00 00 00 00 e1 21 fe c4 9e 38 44 dc bf 1b d5 95 d6 76 d6 d9 a3 0e 00 40 42 57 d3 90]
[    9.495511] filename: sys
