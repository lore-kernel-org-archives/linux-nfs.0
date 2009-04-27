From: Anton Starikov <ant.starikov@gmail.com>
Subject: Re: NFS silent death
Date: Mon, 27 Apr 2009 23:12:02 +0200
Message-ID: <38C9A462-2199-4CA7-9EEC-050400D71C56@gmail.com>
References: <143DD9C8-CD7D-4D18-8295-D9ADBD8A0972@gmail.com> <1240866287.8818.89.camel@heimdal.trondhjem.org>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ew0-f176.google.com ([209.85.219.176]:45282 "EHLO
	mail-ew0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756472AbZD0VMH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 27 Apr 2009 17:12:07 -0400
Received: by ewy24 with SMTP id 24so184803ewy.37
        for <linux-nfs@vger.kernel.org>; Mon, 27 Apr 2009 14:12:04 -0700 (PDT)
In-Reply-To: <1240866287.8818.89.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks for your comment.


In fact, we have LDAP setup.
If I limit nss for idmapper with LDAP-only, this should remove  
problem, at least in theory, isn't it?

On Apr 27, 2009, at 11:04 PM, Trond Myklebust wrote:

>
>
> On Mon, 2009-04-27 at 22:13 +0200, Anton Starikov wrote:
>> Hello,
>>
>> I got stuck around NFS problem.
>>
>> There is a server which serve /home via NFSv4 and root via NFSv3.
>> There are number of diskless clients.
>>
>> At some points some of clients hang.
>> Nothing in the logs and in console most of time.
>>
>> I tried 2.6.27-2.6.30 kernels on both sides. It looks like generally
>> NFSv4 stable enough, if I just mount /home to diskNess host - no  
>> hangs
>> during couple of months. But if I start mix both of them - then
>> problems come. And, there is a problem to have nfs-root on NFSv4, at
>> least all my attempts failed. After some time it always endup with
>> broken id-mapping.
>> And with 2.6.27-2.6.29 nfs3 used to be absolutely non-usable, if you
>> need writing. At least all my games with different mount|export
>> options used end up with the same problem with writing:
>> echo "test" > test_file
>> when file doesn't preexist, fail with "Invalid argument"
>> So, I had to mix them.
>>
>> So far I come to 2.6.30 kernel  and finally got something in the  
>> logs,
>> but only for one of clients, rest is still die silent.
>>
>>
>> [ 9363.096013] INFO: task rpciod/0:745 blocked for more than 120
>> seconds.
>> [ 9363.102730] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
>> disables this message.
>> [ 9363.110905] rpciod/0      D ffffc20000010e00     0   745      2
>> [ 9363.117049]  ffff8805244a9b10 0000000000000046 ffff8805244a9aa0
>> 0000000000010e00
>> [ 9363.124876]  0000000000010e00 0000000000010e00 0000000000010e00
>> 0000000000010e00
>> [ 9363.132689]  0000000000010e00 0000000000010e00 ffff880524a667c0
>> ffff880124192840
>> [ 9363.140506] Call Trace:
>> [ 9363.143138]  [<ffffffff805e4bf0>] schedule+0x1c/0x44
>> [ 9363.148303]  [<ffffffffa011b720>] nfs_idmap_id+0x1ed/0x287 [nfs]
>> [ 9363.154567]  [<ffffffffa011b7f3>] nfs_map_group_to_gid+0x39/0x4f
>> [nfs]
>> [ 9363.161332]  [<ffffffffa011227d>] decode_attr_group+0x110/0x1af  
>> [nfs]
>> [ 9363.168011]  [<ffffffffa011277a>] decode_getfattr+0x45e/0x960  
>> [nfs]
>> [ 9363.174509]  [<ffffffffa01175ef>] nfs4_xdr_dec_open+0xa3/0xef  
>> [nfs]
>> [ 9363.181020]  [<ffffffffa00776eb>] rpcauth_unwrap_resp+0x89/0xac
>> [sunrpc]
>> [ 9363.187935]  [<ffffffffa006f857>] call_decode+0x14e/0x1d3 [sunrpc]
>> [ 9363.194326]  [<ffffffffa00768f3>] __rpc_execute+0x93/0x278  
>> [sunrpc]
>> [ 9363.200809]  [<ffffffffa0076b4d>] rpc_async_schedule+0x23/0x39
>> [sunrpc]
>> [ 9363.207624]  [<ffffffff8026926b>] run_workqueue+0xc9/0x189
>> [ 9363.213300]  [<ffffffff80269415>] worker_thread+0xea/0x10f
>> [ 9363.218972]  [<ffffffff8026de90>] kthread+0x69/0xac
>> [ 9363.224022]  [<ffffffff8020d26a>] child_rip+0xa/0x20
>> [ 9363.229174] INFO: task ntpd:4161 blocked for more than 120  
>> seconds.
>> [ 9363.235620] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
>> disables this message.
>> [ 9363.243787] ntpd          D ffffc20000010e00     0  4161      1
>> [ 9363.249931]  ffff880125831bf8 0000000000000082 ffff880126b49ad0
>> 0000000000010e00
>> [ 9363.257758]  0000000000010e00 0000000000010e00 0000000000010e00
>> 0000000000010e00
>> [ 9363.265583]  0000000000010e00 0000000000010e00 ffff880122c380c0
>> ffff8801264184c0
>> [ 9363.273419] Call Trace:
>> [ 9363.276035]  [<ffffffff805e4bf0>] schedule+0x1c/0x44
>> [ 9363.281174]  [<ffffffff805e4c8e>] io_schedule+0x76/0xd0
>> [ 9363.286581]  [<ffffffff802c4c1c>] sync_page+0x54/0x6c
>> [ 9363.291815]  [<ffffffff802c4cb6>] __lock_page+0x82/0xb8
>> [ 9363.297224]  [<ffffffff802c4e7a>] find_lock_page+0x48/0x82
>> [ 9363.302892]  [<ffffffff802c57a4>] filemap_fault+0x183/0x346
>> [ 9363.308647]  [<ffffffff802dc7a6>] __do_fault+0x77/0x449
>> [ 9363.314059]  [<ffffffff802df33c>] handle_mm_fault+0x1fe/0x31b
>> [ 9363.319986]  [<ffffffff805e96f2>] do_page_fault+0x273/0x29e
>> [ 9363.325741]  [<ffffffff805e6f95>] page_fault+0x25/0x30
>> [ 9363.331068]  [<00007fdd26f110e0>] 0x7fdd26f110e0
>> [ 9363.335865] INFO: task bash:4261 blocked for more than 120  
>> seconds.
>> [ 9363.342311] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs"
>> disables this message.
>> [ 9363.350480] bash          D ffffc20000810e00     0  4261   4259
>> [ 9363.356611]  ffff880925175468 0000000000000082 0000000000000088
>> 0000000000010e00
>> [ 9363.364441]  0000000000010e00 0000000000010e00 0000000000010e00
>> 0000000000010e00
>> [ 9363.372253]  0000000000010e00 0000000000010e00 ffff88092649e780
>> ffff880d26522040
>> [ 9363.380078] Call Trace:
>> [ 9363.382709]  [<ffffffff805e550d>] __mutex_lock_common+0x159/0x1fc
>> [ 9363.388985]  [<ffffffff805e55d7>] __mutex_lock_slowpath+0x27/0x3d
>> [ 9363.395262]  [<ffffffff805e5280>] mutex_lock+0x25/0x53
>> [ 9363.400600]  [<ffffffffa011b5c9>] nfs_idmap_id+0x96/0x287 [nfs]
>> [ 9363.406772]  [<ffffffffa011b842>] nfs_map_name_to_uid+0x39/0x4f  
>> [nfs]
>> [ 9363.413462]  [<ffffffffa01120ce>] decode_attr_owner+0x110/0x1af  
>> [nfs]
>> [ 9363.420140]  [<ffffffffa0112c02>] decode_getfattr+0x8e6/0x960  
>> [nfs]
>> [ 9363.426642]  [<ffffffffa01131d9>] nfs4_xdr_dec_access+0xfd/0x11e
>> [nfs]
>> [ 9363.433408]  [<ffffffffa00776eb>] rpcauth_unwrap_resp+0x89/0xac
>> [sunrpc]
>> [ 9363.440324]  [<ffffffffa006f857>] call_decode+0x14e/0x1d3 [sunrpc]
>
> Hmm... My guess is that you are deadlocked because rpciod appears to  
> be
> hanging on an idmapper upcall due to an NFSv4 open() call. At the same
> time, since /etc/passwd and /etc/group are on an NFSv3 partition, the
> idmapper will need to use rpciod in order to read them.
>
> We therefore apparently need to move the idmapper upcall out of the
> rpciod part of the open() call. I'll look into that...
>
> Trond
>

