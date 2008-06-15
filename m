From: "Daniel J Blueman" <daniel.blueman@gmail.com>
Subject: Re: [2.6.26-rc4] mount.nfsv4/memory poisoning issues...
Date: Sun, 15 Jun 2008 19:10:27 +0100
Message-ID: <6278d2220806151110x68ee91fej8cf8e6b591ce1319@mail.gmail.com>
References: <6278d2220806041633n3bfe3dd2ke9602697697228b@mail.gmail.com>
	 <76bd70e30806041643j4d632a6exf64b29c34173d40f@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	"Linux Kernel" <linux-kernel@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>,
	"Jeff Layton" <jlayton@redhat.com>
To: chucklever@gmail.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:33905 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758753AbYFOSKa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 15 Jun 2008 14:10:30 -0400
Received: by wa-out-1112.google.com with SMTP id j37so4042409waf.23
        for <linux-nfs@vger.kernel.org>; Sun, 15 Jun 2008 11:10:27 -0700 (PDT)
In-Reply-To: <76bd70e30806041643j4d632a6exf64b29c34173d40f-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 5, 2008 at 12:43 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
> Hi Daniel-
>
> On Wed, Jun 4, 2008 at 7:33 PM, Daniel J Blueman
> <daniel.blueman@gmail.com> wrote:
>> Having experienced 'mount.nfs4: internal error' when mounting nfsv4 in
>> the past, I have a minimal test-case I sometimes run:
>>
>> $ while :; do mount -t nfs4 filer:/store /store; umount /store; done
>>
>> After ~100 iterations, I saw the 'mount.nfs4: internal error',
>> followed by symptoms of memory corruption [1], a locking issue with
>> the reporting [2] and another (related?) memory-corruption issue
>> (off-by-1?) [3]. A little analysis shows memory being overwritten by
>> (likely) a poison value, which gets complicated if it's not
>> use-after-free...
>>
>> Anyone dare confirm this issue? NFSv4 server is x86-64 Ubuntu 8.04
>> 2.6.24-18, client U8.04 2.6.26-rc4; batteries included [4].
>
> We have some other reports of late model kernels with memory
> corruption issues during NFS mount.  The problem is that by the time
> these canaries start singing, the evidence of what did the corrupting
> is long gone.
>
>> I'm happy to decode addresses, test patches etc.
>
> If these crashes are more or less reliably reproduced, it would be
> helpful if you could do a 'git bisect' on the client to figure out at
> what point in the kernel revision history this problem was introduced.
>
> Have you seen the problem on client kernels earlier than 2.6.25?

Firstly, I had omitted that I'd booted the kernel with
debug_objects=1, which provides the canary here.

The primary failure I see is 'mount.nfs4: internal error', and always
after 358 umount/mount cycles (plus 1 initial mount) which gives us a
clue; 'netstat' shows all these connections in a TIME_WAIT state, thus
the bug relates to the inability to allocate a socket error path. I
found that after the connection lifetime expired, you can mount again,
which corroborates this theory.

In this case, we saw the mount() syscall result in the mount.nfsv4
process being SEGV'd when booted with 'debug_object=1', without this
option, we see:

# strace /sbin/mount.nfs4 x1:/ /store
...
mount("x1:/", "/store", "nfs4", 0,
"addr=192.168.0.250,clientaddr=19"...) = -1 EIO (Input/output error)

So, it's impossible to tell when the corruption was introduced, as it
has only become detectable recently.

It's worth a look-over of the socket-allocation error path, if someone
can check, and reproduces 100% with the 'debug_object=1' param,
available since 2.6.26-rc1 and 359 mounts in quick succession.

Thanks!
  Daniel
-- 
Daniel J Blueman
