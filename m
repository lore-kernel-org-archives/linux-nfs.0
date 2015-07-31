Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:41826 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750804AbbGaOe3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 31 Jul 2015 10:34:29 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: Sven Geggus <lists@fuchsschwanzdomain.de>
Cc: linux-kernel@vger.kernel.org, trond.myklebust@primarydata.com,
        linux-nfs@vger.kernel.org
References: <20150731114230.GA31037@geggus.net>
Date: Fri, 31 Jul 2015 09:27:51 -0500
In-Reply-To: <20150731114230.GA31037@geggus.net> (Sven Geggus's message of
	"Fri, 31 Jul 2015 13:42:30 +0200")
Message-ID: <87r3noieqg.fsf@x220.int.ebiederm.org>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: nfs-root: destructive call to __detach_mounts /dev
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


I have added the linux-nfs list to hopefully add a wider interested audience.

Sven Geggus <lists@fuchsschwanzdomain.de> writes:

> Hello,
>
> I have a couple of machines running Debian GNU/Linux 8 using an NFS-ro-mounted
> root filesystem.
>
> The systems seem to get bitten by VFS changes in some (unfortunaly
> somewhat difficult to reproduce) circumstances.
>
> The effect is, that /dev (dectmpfs) gets unmounted for some strange reason.
>
> I added the following debug code to fs/namespace.c
>
> printk(KERN_DEBUG "%s: %s\n", __func__, dentry->d_name.name);
> dump_stack();
>
> And this is what I get if one of those events happen:

The only way to get to d_invalidate in lookup_fast is if d_revalidate
fails.

Which yields two functions to look at:
nfs_lookup_revalidate and nfs4_lookup_revalidate

If what is being revalidated is a mount point nfs4_lookup_revalidate
calls nfs_lookup_revalidate.  So nfs_lookup_revalidate is the only
interesting function.

The last round of this was with readdir having problems and invalidating
the dcache.  So now apparently we are down to something weird happening
in revalidate.

I don't understand the what nfs_lookup_revalidate is doing particularly
well.  However it appears that if you enable the kconfig SUNRPC_DEBUG
option there will be more relevant information.

I am not certain what more to print out that SUNRPC_DEBUG won't, but I
have verified that SUNRPC_DEBUG will report when a failure path is hit
in nfs_lookup_revalidate and which failure path was hit (out_bad or
out_error).

Which should be sufficient to start narrowing down what is happening
even further.

I hope that helps a little bit in tracking down what is happening.

Eric

> __detach_mounts: dev
> CPU: 1 PID: 5551 Comm: modtrack Not tainted 4.1.3-debug-00287-g0fe8050-dirty #1
> Hardware name: Dell Inc. Precision WorkStation T3400  /0TP412, BIOS A03 01/31/2008
>  ffff880127183c18 ffff880127183bc8 ffffffff815605f8 ffff88012bc4fcb0
>  ffff880126c16198 ffff880127183bf8 ffffffff81106cf7 000000000000000f
>  ffff880126c16198 ffff880127183c18 ffff880127183d00 ffff880127183c48
> Call Trace:
>  [<ffffffff815605f8>] dump_stack+0x4c/0x6e
>  [<ffffffff81106cf7>] __detach_mounts+0x2b/0x12c
>  [<ffffffff810ffbb6>] d_invalidate+0x9a/0xc8
>  [<ffffffff810f6b13>] lookup_fast+0x1f5/0x26f
>  [<ffffffff810f6dba>] do_last.isra.43+0xd6/0x9fb
>  [<ffffffff810f916e>] path_openat+0x1d1/0x53e
>  [<ffffffff810f9f41>] ? user_path_at_empty+0x63/0x93
>  [<ffffffff810f9fe6>] do_filp_open+0x35/0x85
>  [<ffffffff811f1893>] ? find_next_zero_bit+0x17/0x1d
>  [<ffffffff81104225>] ? __alloc_fd+0xdd/0xef
>  [<ffffffff810ec966>] do_sys_open+0x146/0x1d5
>  [<ffffffff810eca1f>] SyS_openat+0xf/0x11
>  [<ffffffff81565a17>] system_call_fastpath+0x12/0x6a
>
> Regards
>
> Sven
>
> P.S.: Kernel is vanilla 4.1.3 with aufs patches, but aufs is not related in
> this problem.
