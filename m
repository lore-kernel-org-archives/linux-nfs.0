From: Jiri Slaby <jirislaby@gmail.com>
Subject: Re: mount.nfs oops [was: mmotm 2009-09-03-16-35 uploaded]
Date: Sat, 05 Sep 2009 00:26:40 +0200
Message-ID: <4AA19420.5060503@gmail.com>
References: <200909032340.n83Ne6E6004708@imap1.linux-foundation.org>	 <4AA17E74.8060100@gmail.com> <1252102337.5274.4.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Cc: linux-kernel@vger.kernel.org, mm-commits@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f217.google.com ([209.85.220.217]:56016 "EHLO
	mail-fx0-f217.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934292AbZIDW0k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2009 18:26:40 -0400
In-Reply-To: <1252102337.5274.4.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 09/05/2009 12:12 AM, Trond Myklebust wrote:
> On Fri, 2009-09-04 at 22:54 +0200, Jiri Slaby wrote:
>> On 09/04/2009 01:40 AM, akpm@linux-foundation.org wrote:
>>> The mm-of-the-moment snapshot 2009-09-03-16-35 has been uploaded to
>>
>> Hi, I got an oops while mounting an nfs:
>> BUG: unable to handle kernel NULL pointer dereference at 000000000000001d
>> IP: [<ffffffffa003924f>] rpcauth_lookupcred+0x4f/0xc0 [sunrpc]
> 
> This looks like the auth->au_ops->lookup_cred() call failing due to a
> faulty pointer, which should be impossible.
> 
> I note that you had a kernel taint due to a warning before this Oops
> happened. Any details?

Ah, I didn't notice. It's:
Pid: 3423, comm: pm-suspend Not tainted 2.6.31-rc8-mm1_64 #762
Call Trace:
 [<ffffffff8103fc48>] warn_slowpath_common+0x78/0xb0
 [<ffffffff8103fc8f>] warn_slowpath_null+0xf/0x20
 [<ffffffff8106950d>] __generic_smp_call_function_interrupt+0xfd/0x110
 [<ffffffff8106956a>] hotplug_cfd+0x4a/0xa0
 [<ffffffff81434e47>] notifier_call_chain+0x47/0x90
 [<ffffffff8105b311>] raw_notifier_call_chain+0x11/0x20
 [<ffffffff8141ece0>] _cpu_down+0x150/0x2d0
 [<ffffffff8104169b>] disable_nonboot_cpus+0xab/0x130
 [<ffffffff8106ee3d>] suspend_devices_and_enter+0xad/0x1a0
 [<ffffffff8106f00b>] enter_state+0xdb/0xf0
 [<ffffffff8106e741>] state_store+0x91/0x100
 [<ffffffff8116c157>] kobj_attr_store+0x17/0x20
 [<ffffffff8111c6a0>] sysfs_write_file+0xe0/0x160
 [<ffffffff810c3ce8>] vfs_write+0xb8/0x1b0
 [<ffffffff81434c35>] ? do_page_fault+0x185/0x350
 [<ffffffff810c434c>] sys_write+0x4c/0x80
 [<ffffffff8100be2b>] system_call_fastpath+0x16/0x1b
---[ end trace 73264e95657dec65 ]---
CPU1 is down

> Also, were you doing anything special at the time (for instance removing
> a module)?

Not at all. I just did
# mount /work
# grep work /etc/fstab
XXX.YYY.ZZZ:/work     /work           nfs     defaults,intr   0 0

Thanks.
