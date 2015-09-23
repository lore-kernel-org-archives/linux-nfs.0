Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:35297 "EHLO
	mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754770AbbIWNQB (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Sep 2015 09:16:01 -0400
Received: by oiww128 with SMTP id w128so23241623oiw.2
        for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2015 06:16:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150923122714.GA31569@omega>
References: <20150923102953.GA8918@omega>
	<5602809D.2020500@cumulusnetworks.com>
	<20150923115757.GA23260@omega>
	<20150923122714.GA31569@omega>
Date: Wed, 23 Sep 2015 09:16:00 -0400
Message-ID: <CAHQdGtSuhAVMWqm__UYvuKCrAGW54KO10XTWoju0Singq1SbqQ@mail.gmail.com>
Subject: Re: Race with ip=dhcp bootparameter in ip_rcv_finish on am335x
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Alexander Aring <alex.aring@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
        Linux Network Devel Mailing List <netdev@vger.kernel.org>,
        Steven Rostedt <rostedt@goodmis.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

+linux-nfs mailing list

On Wed, Sep 23, 2015 at 8:27 AM, Alexander Aring <alex.aring@gmail.com> wrote:
> Hi,
>
> On Wed, Sep 23, 2015 at 01:57:57PM +0200, Alexander Aring wrote:
> ...
>> >
>>
>> Ok, I think I have two issues with two different races the first one was
>> fixed by bde6f9ded1bd ("net: Initialize table in fib result"), but the
>> second one is still there:
>>
>> [    8.615806] ------------[ cut here ]------------
>> [    8.620678] Kernel BUG at c016c3d0 [verbose debug info unavailable]
>> [    8.627229] Internal error: Oops - BUG: 0 [#1] SMP ARM
>> [    8.632611] Modules linked in:
>> [    8.635836] CPU: 0 PID: 766 Comm: kworker/0:1H Tainted: G        W       4.2.0-11248-gfbd0351 #140
>> [    8.645208] Hardware name: Generic AM33XX (Flattened Device Tree)
>> [    8.651616] Workqueue: rpciod xprt_autoclose
>> [    8.656091] task: ce3c52c0 ti: ce642000 task.ti: ce642000
>> [    8.661744] PC is at iput+0x1a8/0x1f0
>> [    8.665579] LR is at xprt_autoclose+0x2c/0x54
>> [    8.670136] pc : [<c016c3d0>]    lr : [<c066c884>]    psr: 20000113
>> [    8.670136] sp : ce643e80  ip : 00000000  fp : c0b56688
>> [    8.682133] r10: 00000001  r9 : ce643ec8  r8 : 00000000
>> [    8.687599] r7 : feff3000  r6 : ce615800  r5 : ce615bc0  r4 : ce615b54
>> [    8.694421] r3 : 00000060  r2 : 0000000f  r1 : 0f10e000  r0 : cdbed720
>> [    8.701254] Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment none
>> [    8.708718] Control: 10c5387d  Table: 80004019  DAC: 00000051
>> [    8.714732] Process kworker/0:1H (pid: 766, stack limit = 0xce642218)
>> [    8.721464] Stack: (0xce643e80 to 0xce644000)
>> [    8.726033] 3e80: c066f828 ce615b54 ce615bc0 ce615800 feff3000 00000000 ce643ec8 c066c884
>> [    8.734596] 3ea0: ce615b54 ce5ff440 cfb9e340 c0057928 00000001 00000000 c00578b4 cfb9e340
>> [    8.743152] 3ec0: c0057cc8 00000000 c137972c c0cc1960 00000000 c09979f4 cfb9e340 cfb9e340
>> [    8.751714] 3ee0: ce5ff458 cfb9e370 ce642000 00000008 c0b55ba0 ce5ff440 cfb9e340 c0057c54
>> [    8.760274] 3f00: ce659940 ce5ff440 c0057c18 00000000 ce659940 ce5ff440 c0057c18 00000000
>> [    8.768834] 3f20: 00000000 00000000 00000000 c005d918 c0b5697c 00000000 00000000 ce5ff440
>> [    8.777390] 3f40: 00000000 00000000 dead4ead ffffffff ffffffff c0b65d60 00000000 00000000
>> [    8.785951] 3f60: c0922088 ce643f64 ce643f64 00000000 00000000 dead4ead ffffffff ffffffff
>> [    8.794513] 3f80: c0b65d60 00000000 00000000 c0922088 ce643f90 ce643f90 ce643fac ce659940
>> [    8.803069] 3fa0: c005d844 00000000 00000000 c000f770 00000000 00000000 00000000 00000000
>> [    8.811628] 3fc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
>> [    8.820185] 3fe0: 00000000 00000000 00000000 00000000 00000013 00000000 8fdf6861 8fdf6c61
>> [    8.828741] [<c016c3d0>] (iput) from [<c066c884>] (xprt_autoclose+0x2c/0x54)
>> [    8.836133] [<c066c884>] (xprt_autoclose) from [<c0057928>] (process_one_work+0x19c/0x48c)
>> [    8.844784] [<c0057928>] (process_one_work) from [<c0057c54>] (worker_thread+0x3c/0x4a0)
>> [    8.853256] [<c0057c54>] (worker_thread) from [<c005d918>] (kthread+0xd4/0xf0)
>> [    8.860827] [<c005d918>] (kthread) from [<c000f770>] (ret_from_fork+0x14/0x24)
>> [    8.868387] Code: e59f0044 e59f1044 ebfb467a eaffffc1 (e7f001f2)
>
> Additional missing information is that I am booting via nfsroot and
> xprt_autoclose is something from sunrpc.
>
> Finally I figured out that commit
> 4876cc779ff525b9c2376d8076edf47815e71f2c ("SUNRPC: Ensure we release the
> TCP socket once it has been closed") occur this races. After reverting
> this commit everything works fine.
>
> I added now:
>
> Steven Rostedt <rostedt@goodmis.org>
> Trond Myklebust <trond.myklebust@primarydata.com>
>
> to cc to report about this issue.
>

Is that happening when the transport is being torn down? If so, is it
fixed by http://git.linux-nfs.org/?p=trondmy/linux-nfs.git;a=commitdiff;h=79234c3db6842a3de03817211d891e0c2878f756
?
