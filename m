From: "Chuck Lever" <chucklever@gmail.com>
Subject: Re: [2.6.26-rc4] mount.nfsv4/memory poisoning issues...
Date: Thu, 19 Jun 2008 13:32:34 -0400
Message-ID: <76bd70e30806191032w6d2f1acao8fd4daad45597ffc@mail.gmail.com>
References: <6278d2220806041633n3bfe3dd2ke9602697697228b@mail.gmail.com>
	 <76bd70e30806041643j4d632a6exf64b29c34173d40f@mail.gmail.com>
	 <6278d2220806151110x68ee91fej8cf8e6b591ce1319@mail.gmail.com>
	 <20080619081420.24645bc4@tleilax.poochiereds.net>
	 <6278d2220806190537u7b781309q415f904390e02f3@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org, nfsv4@linux-nfs.org,
	"Linux Kernel" <linux-kernel@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	"Trond Myklebust" <trond.myklebust@fys.uio.no>
To: "Daniel J Blueman" <daniel.blueman@gmail.com>,
	"Jeff Layton" <jlayton@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.29]:21058 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbYFSRci (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 19 Jun 2008 13:32:38 -0400
Received: by yw-out-2324.google.com with SMTP id 9so492464ywe.1
        for <linux-nfs@vger.kernel.org>; Thu, 19 Jun 2008 10:32:35 -0700 (PDT)
In-Reply-To: <6278d2220806190537u7b781309q415f904390e02f3-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 19, 2008 at 8:37 AM, Daniel J Blueman
<daniel.blueman@gmail.com> wrote:
> On Thu, Jun 19, 2008 at 1:14 PM, Jeff Layton <jlayton@redhat.com> wrote:
>> On Sun, 15 Jun 2008 19:10:27 +0100
>> "Daniel J Blueman" <daniel.blueman@gmail.com> wrote:
>>
>>> On Thu, Jun 5, 2008 at 12:43 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>>> > Hi Daniel-
>>> >
>>> > On Wed, Jun 4, 2008 at 7:33 PM, Daniel J Blueman
>>> > <daniel.blueman@gmail.com> wrote:
>>> >> Having experienced 'mount.nfs4: internal error' when mounting nfsv4 in
>>> >> the past, I have a minimal test-case I sometimes run:
>>> >>
>>> >> $ while :; do mount -t nfs4 filer:/store /store; umount /store; done
>>> >>
>>> >> After ~100 iterations, I saw the 'mount.nfs4: internal error',
>>> >> followed by symptoms of memory corruption [1], a locking issue with
>>> >> the reporting [2] and another (related?) memory-corruption issue
>>> >> (off-by-1?) [3]. A little analysis shows memory being overwritten by
>>> >> (likely) a poison value, which gets complicated if it's not
>>> >> use-after-free...
>>> >>
>>> >> Anyone dare confirm this issue? NFSv4 server is x86-64 Ubuntu 8.04
>>> >> 2.6.24-18, client U8.04 2.6.26-rc4; batteries included [4].
>>> >
>>> > We have some other reports of late model kernels with memory
>>> > corruption issues during NFS mount.  The problem is that by the time
>>> > these canaries start singing, the evidence of what did the corrupting
>>> > is long gone.
>>> >
>>> >> I'm happy to decode addresses, test patches etc.
>>> >
>>> > If these crashes are more or less reliably reproduced, it would be
>>> > helpful if you could do a 'git bisect' on the client to figure out at
>>> > what point in the kernel revision history this problem was introduced.
>>> >
>>> > Have you seen the problem on client kernels earlier than 2.6.25?
>>>
>>> Firstly, I had omitted that I'd booted the kernel with
>>> debug_objects=1, which provides the canary here.
>>>
>>> The primary failure I see is 'mount.nfs4: internal error', and always
>>> after 358 umount/mount cycles (plus 1 initial mount) which gives us a
>>> clue; 'netstat' shows all these connections in a TIME_WAIT state, thus
>>> the bug relates to the inability to allocate a socket error path. I
>>> found that after the connection lifetime expired, you can mount again,
>>> which corroborates this theory.
>>>
>>> In this case, we saw the mount() syscall result in the mount.nfsv4
>>> process being SEGV'd when booted with 'debug_object=1', without this
>>> option, we see:
>>>
>>> # strace /sbin/mount.nfs4 x1:/ /store
>>> ...
>>> mount("x1:/", "/store", "nfs4", 0,
>>> "addr=192.168.0.250,clientaddr=19"...) = -1 EIO (Input/output error)
>>>
>>> So, it's impossible to tell when the corruption was introduced, as it
>>> has only become detectable recently.
>>>
>>> It's worth a look-over of the socket-allocation error path, if someone
>>> can check, and reproduces 100% with the 'debug_object=1' param,
>>> available since 2.6.26-rc1 and 359 mounts in quick succession.
>>>
>>
>> For some strange reason (probably something I'm doing wrong or maybe
>> something environmental), I've not been able to reproduce this panic on
>> a stock kernel. I did, however, apply the following fault injection
>> patch and was able to reproduce it on the second mount attempt. The 3
>> patch set that I posted last week definitely prevents the oops. If
>> you're able to confirm that it also fixes your panic it would be a
>> helpful data point.
>>
>> The fault injection patch I'm using is attached. It just simulates
>> nfs4_init_client() consistently returning an error.
>
> Thanks! I hope to get time for this tonight and will get back to you;
> I appreciate your help, Jeff.
>
> The config I used to reproduce it on the client is
> http://www.quora.org/config-debug and is relevant to (at least)
> 2.6.26-rc5. I was able to reproduce it by exporting a single NFSv4
> export on 2.6.25 (eg Ubuntu 8.04 server); client and server were
> x86-64.

For the record, I was able to reproduce with a dual core 2.6.26-rc4
x86 client (using SLUB, not SLAB) on Fedora 8 against a Solaris 2008.5
NFSv4 server.  When the client runs out of ports, the mount commands
start to fail with EIO.  Then after a few dozen of these, the mounting
process hangs.  Sometimes it will BUG because freed & poisoned memory
is passed to kthread_stop().  I haven't seen some of the other
subsequent issues that Daniel initially reported.

-- 
I am certain that these presidents will understand the cry of the
people of Bolivia, of the people of Latin America and the whole world,
which wants to have more food and not more cars. First food, then if
something's left over, more cars, more automobiles. I think that life
has to come first.
-- Evo Morales
