Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wr0-f178.google.com ([209.85.128.178]:33274 "EHLO
        mail-wr0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754647AbdCIN1b (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Mar 2017 08:27:31 -0500
Received: by mail-wr0-f178.google.com with SMTP id u48so45042968wrc.0
        for <linux-nfs@vger.kernel.org>; Thu, 09 Mar 2017 05:27:20 -0800 (PST)
Received: from [192.168.64.116] (bzq-82-81-101-184.red.bezeqint.net. [82.81.101.184])
        by smtp.gmail.com with ESMTPSA id w17sm8277019wra.28.2017.03.09.05.27.18
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Mar 2017 05:27:18 -0800 (PST)
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
From: Sagi Grimberg <sagi@grimberg.me>
Subject: kmemleak complaint on 4.11-rc1
Message-ID: <34f7270f-ea05-4246-81db-a606f9d5c4bc@grimberg.me>
Date: Thu, 9 Mar 2017 15:27:17 +0200
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hey all,

I get this with nfs mount on my VM (4.11-rc1):

from dmesg:
[ 1889.676648] kmemleak: 8254 new suspected memory leaks (see 
/sys/kernel/debug/kmemleak)

$ cat /sys/kernel/debug/kmemleak
...
unreferenced object 0xffff96c67a192a80 (size 32):
   comm "kworker/0:3", pid 266, jiffies 4295080946 (age 6406.600s)
   hex dump (first 32 bytes):
     31 30 30 30 00 ff 0f 88 0a fc ff ff 41 83 ff 01  1000........A...
     0f 8e 75 01 00 00 41 8d 4f fc 83 f9 0b 0f 87 f3  ..u...A.O.......
   backtrace:
     [<ffffffffbb847eda>] kmemleak_alloc+0x4a/0xa0
     [<ffffffffbb205949>] __kmalloc+0x149/0x270
     [<ffffffffc0526590>] xdr_stream_decode_string_dup+0x80/0x110 [sunrpc]
     [<ffffffffc0a03168>] decode_getfattr_attrs+0x8b8/0x15a0 [nfsv4]
     [<ffffffffc0a03edc>] 
decode_getfattr_generic.constprop.108+0x8c/0xe0 [nfsv4]
     [<ffffffffc0a03fdd>] nfs4_xdr_dec_open+0xad/0xd0 [nfsv4]
     [<ffffffffc051cf99>] rpcauth_unwrap_resp+0x89/0xd0 [sunrpc]
     [<ffffffffc050db73>] call_decode+0x1e3/0x810 [sunrpc]
     [<ffffffffc0519632>] __rpc_execute+0x82/0x450 [sunrpc]
     [<ffffffffc0519a12>] rpc_async_schedule+0x12/0x20 [sunrpc]
     [<ffffffffbb099e3b>] process_one_work+0x16b/0x480
     [<ffffffffbb09a19b>] worker_thread+0x4b/0x500
     [<ffffffffbb0a0591>] kthread+0x101/0x140
     [<ffffffffbb85303c>] ret_from_fork+0x2c/0x40
     [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff96c67a192a60 (size 32):
   comm "kworker/0:3", pid 266, jiffies 4295080947 (age 6406.596s)
   hex dump (first 32 bytes):
     31 30 30 30 00 ff ff 41 c6 85 90 00 00 00 00 41  1000...A.......A
     0f b6 85 91 00 00 00 88 45 bf e9 db fd ff ff 44  ........E......D
   backtrace:
     [<ffffffffbb847eda>] kmemleak_alloc+0x4a/0xa0
     [<ffffffffbb205949>] __kmalloc+0x149/0x270
     [<ffffffffc0526590>] xdr_stream_decode_string_dup+0x80/0x110 [sunrpc]
     [<ffffffffc0a03168>] decode_getfattr_attrs+0x8b8/0x15a0 [nfsv4]
     [<ffffffffc0a03edc>] 
decode_getfattr_generic.constprop.108+0x8c/0xe0 [nfsv4]
     [<ffffffffc0a03fdd>] nfs4_xdr_dec_open+0xad/0xd0 [nfsv4]
     [<ffffffffc051cf99>] rpcauth_unwrap_resp+0x89/0xd0 [sunrpc]
     [<ffffffffc050db73>] call_decode+0x1e3/0x810 [sunrpc]
     [<ffffffffc0519632>] __rpc_execute+0x82/0x450 [sunrpc]
     [<ffffffffc0519a12>] rpc_async_schedule+0x12/0x20 [sunrpc]
     [<ffffffffbb099e3b>] process_one_work+0x16b/0x480
     [<ffffffffbb09a19b>] worker_thread+0x4b/0x500
     [<ffffffffbb0a0591>] kthread+0x101/0x140
     [<ffffffffbb85303c>] ret_from_fork+0x2c/0x40
     [<ffffffffffffffff>] 0xffffffffffffffff
...
