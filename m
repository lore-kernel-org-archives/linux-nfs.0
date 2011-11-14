Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:34013 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832Ab1KNR5k (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Nov 2011 12:57:40 -0500
Received: by fagn18 with SMTP id n18so3272905fag.19
        for <linux-nfs@vger.kernel.org>; Mon, 14 Nov 2011 09:57:38 -0800 (PST)
Message-ID: <4EC1568E.9090708@tonian.com>
Date: Mon, 14 Nov 2011 19:57:34 +0200
From: Benny Halevy <bhalevy@tonian.com>
MIME-Version: 1.0
To: Peng Tao <bergwolf@gmail.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: Re: pnfs git tree status pnfs-all-3.1-2011-11-14 pnfs-all-3.2-rc1-2011-11-14
References: <4EC13EEA.3030404@tonian.com> <CA+a=Yy66VOW+nY3LZHxymZv5j5TAehFRav2EC4_kgDqrDVD2EQ@mail.gmail.com>
In-Reply-To: <CA+a=Yy66VOW+nY3LZHxymZv5j5TAehFRav2EC4_kgDqrDVD2EQ@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-11-14 19:23, Peng Tao wrote:
> On Tue, Nov 15, 2011 at 12:16 AM, Benny Halevy <bhalevy@tonian.com> wrote:
>> I merged the following patches into pnfs-all-3.1-2011-11-14
>> and rebased the tree onto v3.2-rc1 as pnfs-all-3.2-rc1-2011-11-14.
>>
>> pnfs-block:
>>  Peng Tao         e5b35df pnfsblock: cleanup bl_mark_sectors_init
>>  Peng Tao         60d5135 pnfsblock: move find lock page logic out of bl_write_pagelist
>>  Peng Tao         ab0c07d pnfsblock: set read/write tk_status to pnfs_error
>>  Peng Tao         85e8c84 pnfsblock: remove rpc_call_ops from struct parallel_io
>>  Peng Tao         7c93c37 pnfsblock: clean up _add_entry
>>  Peng Tao         ec11faf pnfsblock: alloc short extent before submit bio
> Thanks, Benny. It seems this one is still missing.
> http://www.spinics.net/lists/linux-nfs/msg25358.html
> 
> Would you please merge it as well? verg keeps dropping the patch so I
> sent it as an attachment. Did you get it?

Argh, sorry, it's actually already merged. It's just that my
reporting script happened to miss it.
657c2f4 pnfsblock: acquire im_lock in _preload_range

> 
> BTW, checkpatch.pl doesn't complain anything on the patch:
> $./scripts/checkpatch.pl 0002-pnfsblock-acquire-im_lock-in-_preload_range.patch
> total: 0 errors, 0 warnings, 36 lines checked
> 
> 0002-pnfsblock-acquire-im_lock-in-_preload_range.patch has no obvious
> style problems and is ready for submission.
> 
> 
>>
>> pnfsd:
>>  Boaz Harrosh     5e57e48 SQUASHME: pnfsd: Don't call fs_layout_return on a none-file
>>
>> spnfs-block:
>>  Benny Halevy     400ab8f SQUASHME: spnfs-block: fix oops in device_slice
>>  Benny Halevy     bd6bc0a SQUASHME: spnfs-block: add dprints for device_slice
>>
>> Both versions pass connectathon tests against pnfsd-lexp server using the files layout.
>>
>> Block layout fails as the server ctl process crashes as follows:
> Was it working before?
> 

It's been languished for quite a while so the answer is
that it worked before, once upon a time.

Benny

> Thanks,
> Tao
>>
>> kernel: nfsv4 compound op #2/2: 47 (OP_GETDEVICEINFO)
>> kernel: nfsd4_getdevinfo: layout_type 3 dev_id 28d:1f maxcnt 135168
>> kernel: nfsd4_getdevinfo: sb ffff88002c535cd0
>> kernel: pnfs_set_device_notify: -->
>> kernel: renewing client (clientid 4ec13510/00000003)
>> kernel: pnfs_set_device_notify: Incr device count (clnt ffff88002d310000) to 2
>> kernel: nfsd4_encode_getdevinfo: err 0
>> kernel: device_slice: dev_id=0:31
>> kernel: device_slice: ret=1
>> kernel: ctl[1028]: segfault at 497 ip 00007f74b7909f24 sp 00007fffd2a43948 error 4 in libc-2.13.90.so[7f74b788d000+192000]
>>
>> Benny
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
