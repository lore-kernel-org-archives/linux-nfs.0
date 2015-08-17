Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx.gnuher.de ([144.76.235.56]:54355 "EHLO mx.gnuher.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754671AbbHQMhJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Aug 2015 08:37:09 -0400
Date: Mon, 17 Aug 2015 14:37:04 +0200
From: Sven Geggus <lists@fuchsschwanzdomain.de>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: linux-kernel@vger.kernel.org, trond.myklebust@primarydata.com,
        linux-nfs@vger.kernel.org
Subject: Re: nfs-root: destructive call to __detach_mounts /dev
Message-ID: <20150817123703.GA25546@geggus.net>
References: <20150731114230.GA31037@geggus.net>
 <87r3noieqg.fsf@x220.int.ebiederm.org>
 <20150814110140.GA25799@geggus.net>
 <87lhddhpso.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <87lhddhpso.fsf@x220.int.ebiederm.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Eric W. Biederman wrote:

> I don't have a clue what the issue would be but I would start with
> something like the patch below.

OK using it I got the following...
This time with /dev on another machine (same nfs root-fs):

Aug 17 13:57:04 dhcp195 kernel: NFS: nfs_lookup_revalidate(/dev): nfs_lookup_verify_inode() failed
Aug 17 13:57:04 dhcp195 kernel: NFS: nfs_lookup_revalidate(/dev) is invalid
Aug 17 13:57:04 dhcp195 kernel: NFSROOT __detach_mounts: dev
Aug 17 13:57:04 dhcp195 kernel: CPU: 3 PID: 32644 Comm: modtrack Tainted: P O    4.1.6-lomac1-00296-gfeae456 #7
Aug 17 13:57:04 dhcp195 kernel: Hardware name: System manufacturer System Product Name/P7P55D, BIOS 1807    07/22/2010
Aug 17 13:57:04 dhcp195 kernel: ffff88021315bc18 ffff88021315bbd8 ffffffff81560638 000000000000b413
Aug 17 13:57:04 dhcp195 kernel: ffff880216460f18 ffff88021315bbf8 ffffffff81106e1f 000000000000001b
Aug 17 13:57:04 dhcp195 kernel: ffff880216460f18 ffff88021315bc48 ffffffff810ffcf5 0000000005dd05dd
Aug 17 13:57:04 dhcp195 kernel: Call Trace:
Aug 17 13:57:04 dhcp195 kernel: [<ffffffff81560638>] dump_stack+0x4c/0x6e
Aug 17 13:57:04 dhcp195 kernel: [<ffffffff81106e1f>] __detach_mounts+0x20/0xdf
Aug 17 13:57:04 dhcp195 kernel: [<ffffffff810ffcf5>] d_invalidate+0x9a/0xc8
Aug 17 13:57:04 dhcp195 kernel: [<ffffffff810f6c49>] lookup_fast+0x1f5/0x26f
Aug 17 13:57:04 dhcp195 kernel: [<ffffffff810f6ef0>] do_last.isra.43+0xd6/0x9fb
Aug 17 13:57:04 dhcp195 kernel: [<ffffffff810f92a4>] path_openat+0x1d1/0x53e
Aug 17 13:57:04 dhcp195 kernel: [<ffffffff810fa077>] ? user_path_at_empty+0x63/0x93
Aug 17 13:57:04 dhcp195 kernel: [<ffffffff810fa11c>] do_filp_open+0x35/0x85
Aug 17 13:57:04 dhcp195 kernel: [<ffffffff811f1aa9>] ? find_next_zero_bit+0x17/0x1d
Aug 17 13:57:04 dhcp195 kernel: [<ffffffff81104364>] ? __alloc_fd+0xdd/0xef
Aug 17 13:57:04 dhcp195 kernel: [<ffffffff810eca9c>] do_sys_open+0x146/0x1d5
Aug 17 13:57:04 dhcp195 kernel: [<ffffffff810ecb55>] SyS_openat+0xf/0x11
Aug 17 13:57:04 dhcp195 kernel: [<ffffffff81565a57>] system_call_fastpath+0x12/0x6a

So this looks like I would need to add some debug output to
"nfs_lookup_verify_inode" then right?

Sven

-- 
Why are there so many Unix-haters-handbooks and not even one
Microsoft-Windows-haters handbook?
Gurer vf ab arrq sbe n unaqobbx gb ungr Zvpebfbsg Jvaqbjf!
/me is giggls@ircnet, http://sven.gegg.us/ on the Web
