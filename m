Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx.gnuher.de ([144.76.235.56]:59751 "EHLO mx.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755082AbbHNLXs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Aug 2015 07:23:48 -0400
Date: Fri, 14 Aug 2015 13:01:40 +0200
From: Sven Geggus <lists@fuchsschwanzdomain.de>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, trond.myklebust@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: nfs-root: destructive call to __detach_mounts /dev
Message-ID: <20150814110140.GA25799@geggus.net>
References: <20150731114230.GA31037@geggus.net>
 <87r3noieqg.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <87r3noieqg.fsf@x220.int.ebiederm.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 31-07-15 09:27 Eric W. Biederman wrote:

> I have added the linux-nfs list to hopefully add a wider interested
> audience.

... which made your mail get burried in my linux-nfs mailinglist folder :(
But I finaly found it.

> If what is being revalidated is a mount point nfs4_lookup_revalidate
> calls nfs_lookup_revalidate.  So nfs_lookup_revalidate is the only
> interesting function.

OK.

> I don't understand the what nfs_lookup_revalidate is doing particularly
> well.  

Neither do I.

Here is what I get from a broken machine (Kernel 4.1.5) using
"rpcdebug -m nfs -s lookupcache":

The mountpoint which got unmounted in this case is /proc not /dev, but the
stack-trace points to the same place.

Aug 14 11:49:37 banthonytwarog kernel: NFS: nfs_lookup_revalidate(/proc) is valid
Aug 14 11:49:37 banthonytwarog kernel: NFS: nfs_lookup_revalidate(/proc) is invalid
Aug 14 11:49:37 banthonytwarog kernel: NFSROOT __detach_mounts: proc
Aug 14 11:49:37 banthonytwarog kernel: CPU: 2 PID: 28350 Comm: modtrack Tainted: P        W  O    4.1.5-lomac3-00293-gfdd763a #6
Aug 14 11:49:37 banthonytwarog kernel: Hardware name: System manufacturer System Product Name/P8H67, BIOS 3506 03/02/2012
Aug 14 11:49:37 banthonytwarog kernel: ffff8800d9b93bb8 ffff8800d9b93b78 ffffffff81560488 00000000446c446c
Aug 14 11:49:37 banthonytwarog kernel: ffff88040c427d98 ffff8800d9b93b98 ffffffff81106d36 00000000000000a2
Aug 14 11:49:37 banthonytwarog kernel: ffff88040c427d98 ffff8800d9b93be8 ffffffff810ffc0c 00000000d9b93c08
Aug 14 11:49:37 banthonytwarog kernel: Call Trace:
Aug 14 11:49:37 banthonytwarog kernel: [<ffffffff81560488>] dump_stack+0x4c/0x6e
Aug 14 11:49:37 banthonytwarog kernel: [<ffffffff81106d36>] __detach_mounts+0x20/0xdf
Aug 14 11:49:37 banthonytwarog kernel: [<ffffffff810ffc0c>] d_invalidate+0x9a/0xc8
Aug 14 11:49:37 banthonytwarog kernel: [<ffffffff810f6b60>] lookup_fast+0x1f5/0x26f
Aug 14 11:49:37 banthonytwarog kernel: [<ffffffff810f5a44>] ? __inode_permission+0x37/0x95
Aug 14 11:49:37 banthonytwarog kernel: [<ffffffff810f7c02>] link_path_walk+0x204/0x749
Aug 14 11:49:37 banthonytwarog kernel: [<ffffffff810f4db2>] ? terminate_walk+0x10/0x2e
Aug 14 11:49:37 banthonytwarog kernel: [<ffffffff810f75e7>] ? do_last.isra.43+0x8b6/0x9fb
Aug 14 11:49:37 banthonytwarog kernel: [<ffffffff810f846f>] path_init+0x328/0x337
Aug 14 11:49:37 banthonytwarog kernel: [<ffffffff810f919a>] path_openat+0x1b0/0x53e
Aug 14 11:49:37 banthonytwarog kernel: [<ffffffff810fa073>] do_filp_open+0x75/0x85
Aug 14 11:49:37 banthonytwarog kernel: [<ffffffff8110427b>] ? __alloc_fd+0xdd/0xef
Aug 14 11:49:37 banthonytwarog kernel: [<ffffffff810ec9b3>] do_sys_open+0x146/0x1d5
Aug 14 11:49:37 banthonytwarog kernel: [<ffffffff810d1c5c>] ? vm_munmap+0x4b/0x59
Aug 14 11:49:37 banthonytwarog kernel: [<ffffffff810eca5b>] SyS_open+0x19/0x1b
Aug 14 11:49:37 banthonytwarog kernel: [<ffffffff81565897>] system_call_fastpath+0x12/0x6a

I suppose, that the first two lines are particularly interesting as we have
"is valid" and a fraction of a second later we have "is invalid" at the same
mountpoint.

To me this looks like a job for the NFS client maintainers now, right?

Sven

-- 
Exploits and holes are a now a necessary protection against large
corporate interests. (Alan Cox)

/me is giggls@ircnet, http://sven.gegg.us/ on the Web
