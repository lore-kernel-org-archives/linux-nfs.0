Return-Path: linux-nfs-owner@vger.kernel.org
Received: from relay.parallels.com ([195.214.232.42]:58324 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751024AbaC1Gc5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 28 Mar 2014 02:32:57 -0400
Message-ID: <53351797.9020507@parallels.com>
Date: Fri, 28 Mar 2014 10:32:55 +0400
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
MIME-Version: 1.0
To: Jeff Layton <jlayton@redhat.com>, "J. Bruce Fields" <bfields@fieldses.org>
CC: <trond.myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>,
        <raphoszap@laposte.net>
Subject: Re: [PATCH] lockd: ensure we tear down any live sockets when socket
 creation fails during lockd_up
References: <1395773726-16510-1-git-send-email-jlayton@redhat.com>	<20140328021234.GE27633@fieldses.org> <20140327203751.1fbaf01f@ipyr.poochiereds.net>
In-Reply-To: <20140327203751.1fbaf01f@ipyr.poochiereds.net>
Content-Type: text/plain; charset="UTF-8"; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

28.03.2014 07:37, Jeff Layton пишет:
> On Thu, 27 Mar 2014 22:12:34 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>
>> Thanks, applying.
>>
>> (Can you tell if this has always been there, or if it was introduced
>> recently?  I guess it should go to stable, anyway....)
>>
>> --b.
>>
>
> (cc'ing Stanislav so he's aware...)
>

Looks reasonable.
Thanks for involving me into discussion, Jeff.

> Yeah, probably reasonable for stable...
>
> Looks like this bug crept in with 786185b5f8abefa. Prior to that we
> called svc_shutdown_net from svc_destroy, which cleaned up the sockets
> before the BUG_ON.
>
> FWIW, the Fedora bug report is here in case anyone is interested:
>
>      https://bugzilla.redhat.com/show_bug.cgi?id=1079700
>
>> On Tue, Mar 25, 2014 at 11:55:26AM -0700, Jeff Layton wrote:
>>> We had a Fedora ABRT report with a stack trace like this:
>>>
>>> kernel BUG at net/sunrpc/svc.c:550!
>>> invalid opcode: 0000 [#1] SMP
>>> [...]
>>> CPU: 2 PID: 913 Comm: rpc.nfsd Not tainted 3.13.6-200.fc20.x86_64 #1
>>> Hardware name: Hewlett-Packard HP ProBook 4740s/1846, BIOS 68IRR
>>> Ver. F.40 01/29/2013 task: ffff880146b00000 ti: ffff88003f9b8000
>>> task.ti: ffff88003f9b8000 RIP: 0010:[<ffffffffa0305fa8>]
>>> [<ffffffffa0305fa8>] svc_destroy+0x128/0x130 [sunrpc] RSP:
>>> 0018:ffff88003f9b9de0  EFLAGS: 00010206 RAX: ffff88003f829628 RBX:
>>> ffff88003f829600 RCX: 00000000000041ee RDX: 0000000000000000 RSI:
>>> 0000000000000286 RDI: 0000000000000286 RBP: ffff88003f9b9de8 R08:
>>> 0000000000017360 R09: ffff88014fa97360 R10: ffffffff8114ce57 R11:
>>> ffffea00051c9c00 R12: ffff88003f829600 R13: 00000000ffffff9e R14:
>>> ffffffff81cc7cc0 R15: 0000000000000000 FS:  00007f4fde284840(0000)
>>> GS:ffff88014fa80000(0000) knlGS:0000000000000000 CS:  0010 DS: 0000
>>> ES: 0000 CR0: 0000000080050033 CR2: 00007f4fdf5192f8 CR3:
>>> 00000000a569a000 CR4: 00000000001407e0 Stack:
>>>   ffff88003f792300 ffff88003f9b9e18 ffffffffa02de02a 0000000000000000
>>>   ffffffff81cc7cc0 ffff88003f9cb000 0000000000000008 ffff88003f9b9e60
>>>   ffffffffa033bb35 ffffffff8131c86c ffff88003f9cb000 ffff8800a5715008
>>> Call Trace:
>>>   [<ffffffffa02de02a>] lockd_up+0xaa/0x330 [lockd]
>>>   [<ffffffffa033bb35>] nfsd_svc+0x1b5/0x2f0 [nfsd]
>>>   [<ffffffff8131c86c>] ? simple_strtoull+0x2c/0x50
>>>   [<ffffffffa033c630>] ? write_pool_threads+0x280/0x280 [nfsd]
>>>   [<ffffffffa033c6bb>] write_threads+0x8b/0xf0 [nfsd]
>>>   [<ffffffff8114efa4>] ? __get_free_pages+0x14/0x50
>>>   [<ffffffff8114eff6>] ? get_zeroed_page+0x16/0x20
>>>   [<ffffffff811dec51>] ? simple_transaction_get+0xb1/0xd0
>>>   [<ffffffffa033c098>] nfsctl_transaction_write+0x48/0x80 [nfsd]
>>>   [<ffffffff811b8b34>] vfs_write+0xb4/0x1f0
>>>   [<ffffffff811c3f99>] ? putname+0x29/0x40
>>>   [<ffffffff811b9569>] SyS_write+0x49/0xa0
>>>   [<ffffffff810fc2a6>] ? __audit_syscall_exit+0x1f6/0x2a0
>>>   [<ffffffff816962e9>] system_call_fastpath+0x16/0x1b
>>> Code: 31 c0 e8 82 db 37 e1 e9 2a ff ff ff 48 8b 07 8b 57 14 48 c7
>>> c7 d5 c6 31 a0 48 8b 70 20 31 c0 e8 65 db 37 e1 e9 f4 fe ff ff 0f
>>> 0b <0f> 0b 66 0f 1f 44 00 00 0f 1f 44 00 00 55 48 89 e5 41 56 41 55
>>> RIP  [<ffffffffa0305fa8>] svc_destroy+0x128/0x130 [sunrpc] RSP
>>> <ffff88003f9b9de0>
>>>
>>> Evidently, we created some lockd sockets and then failed to create
>>> others. make_socks then returned an error and we tried to tear down
>>> the svc, but svc->sv_permsocks was not empty so we ended up
>>> tripping over the BUG() in svc_destroy().
>>>
>>> Fix this by ensuring that we tear down any live sockets we created
>>> when socket creation is going to return an error.
>>>
>>> Reported-by: Raphos <raphoszap@laposte.net>
>>> Signed-off-by: Jeff Layton <jlayton@redhat.com>
>>> ---
>>>   fs/lockd/svc.c | 1 +
>>>   1 file changed, 1 insertion(+)
>>>
>>> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
>>> index 10d6c41aecad..6bf06a07f3e0 100644
>>> --- a/fs/lockd/svc.c
>>> +++ b/fs/lockd/svc.c
>>> @@ -235,6 +235,7 @@ out_err:
>>>   	if (warned++ == 0)
>>>   		printk(KERN_WARNING
>>>   			"lockd_up: makesock failed, error=%d\n",
>>> err);
>>> +	svc_shutdown_net(serv, net);
>>>   	return err;
>>>   }
>>>
>>> --
>>> 1.8.5.3
>>>
>
>
>


-- 
Best regards,
Stanislav Kinsbursky
