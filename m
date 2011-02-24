Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from lvps87-230-0-242.dedicated.hosteurope.de ([87.230.0.242]:56313
	"EHLO lvps87-230-0-242.dedicated.hosteurope.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754887Ab1BXJUY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Feb 2011 04:20:24 -0500
Date: Thu, 24 Feb 2011 10:13:34 +0100
From: Michael Guntsche <mike@it-loops.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org
Subject: Re: Page alloc error on nfs4 via automount
Message-ID: <20110224091334.GA24111@gibson.comsick.at>
References: <20100816061644.GA2401@gibson.comsick.at>
 <1282087292.18385.34.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1282087292.18385.34.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 17 Aug 10 19:21, Trond Myklebust wrote:
> On Mon, 2010-08-16 at 08:16 +0200, Michael Guntsche wrote:
> > Good morning,
> > 
> > I hit this problem once again, the backtrace is completely the same.
> > 
> > The server in question is exporting the same filesystem (a
> > subdirectory) as nfs3 and a second client is using this with automount
> > too. I do not see any problems there, it is an older kernel version
> > though.
> > 
> > I get this backtrace on first access to the autofs directory. Subsequent
> > access works and the filesystem gets mounted ok.
> > 
This is still happening with 2.6.38-rc5+ on the client side.

[506826.480330] mount.nfs4: page allocation failure. order:4, mode:0xc0d0
[506826.488114] Call Trace:
[506826.492244] [c799fbc0] [c0008908] show_stack+0x70/0x1bc (unreliable)
[506826.501169] [c799fc00] [c006aa08] __alloc_pages_nodemask+0x5f0/0x6fc
[506826.509391] [c799fcb0] [c006ab34] __get_free_pages+0x20/0x50
[506826.517247] [c799fcc0] [c9dd8538] nfs_idmap_new+0x40/0x100 [nfs]
[506826.525327] [c799fce0] [c9da2dd0] nfs4_set_client+0x128/0x2d8 [nfs]
[506826.533309] [c799fd30] [c9da35e4] nfs4_create_server+0xc8/0x37c [nfs]
[506826.540360] [c799fd80] [c9daec9c] nfs4_remote_mount+0x50/0x1bc [nfs]
[506826.547240] [c799fdb0] [c009cccc] vfs_kern_mount+0x6c/0x15c
[506826.553367] [c799fde0] [c9daf0c0] nfs_do_root_mount+0x84/0xc0 [nfs]
[506826.560283] [c799fe10] [c9daf5a4] nfs4_try_mount+0x64/0x104 [nfs]
[506826.566596] [c799fe40] [c9daf700] nfs4_get_sb+0xbc/0x3dc [nfs]
[506826.572928] [c799fe70] [c009cd80] vfs_kern_mount+0x120/0x15c
[506826.579071] [c799fea0] [c009ce20] do_kern_mount+0x54/0x118
[506826.585077] [c799fec0] [c00b9934] do_mount+0x410/0x7f0
[506826.590388] [c799ff10] [c00b9db4] sys_mount+0xa0/0xf8
[506826.595891] [c799ff40] [c0010184] ret_from_syscall+0x0/0x38
[506826.602029] --- Exception: c01 at 0xff5de64
[506826.602043]     LR = 0x1000af4c
[506826.609918] Mem-Info:
[506826.612299] DMA per-cpu:
[506826.615042] CPU    0: hi:   42, btch:   7 usd:   0
[506826.620449] active_anon:2420 inactive_anon:20 isolated_anon:6
[506826.620465]  active_file:12609 inactive_file:11601 isolated_file:25
[506826.620476]  unevictable:493 dirty:0 writeback:0 unstable:0
[506826.620486]  free:612 slab_reclaimable:802 slab_unreclaimable:1992
[506826.620497]  mapped:1438 shmem:32 pagetables:200 bounce:0
[506826.650982] DMA free:2448kB min:1440kB low:1800kB high:2160kB active_anon:9680kB inactive_anon:80kB active_file:50436kB inactive_file:46404kB unevictable:1972kB isolated(anon):24kB isolated(file):100kB present:130048kB mlocked:1972kB dirty:0kB writeback:0kB mapped:5752kB shmem:128kB slab_reclaimable:3208kB slab_unreclaimable:7968kB kernel_stack:568kB pagetables:800kB unstable:0kB bounce:0kB writeback_tmp:0kB pages_scanned:0 all_unreclaimable? no
[506826.691851] lowmem_reserve[]: 0 0 0
[506826.695867] DMA: 408*4kB 30*8kB 14*16kB 9*32kB 1*64kB 0*128kB 0*256kB 0*512kB 0*1024kB 0*2048kB 0*4096kB = 2448kB
[506826.707258] 24680 total pagecache pages
[506826.711533] 0 pages in swap cache
[506826.715150] Swap cache stats: add 0, delete 0, find 0/0
[506826.720858] Free swap  = 0kB
[506826.724007] Total swap = 0kB
[506826.733886] 32768 pages RAM
[506826.737069] 1203 pages reserved
[506826.740597] 22349 pages shared
[506826.744047] 13330 pages non-shared

The setup is still the same NFS4 automount. It is not happening
repeatedly though. Is it possible that memory gets fragmented over time
and therefore this error is occuring? As always subsequent access
succeeds.

Kind regards,
Michael
