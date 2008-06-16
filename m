Return-Path: <nfsv4-bounces@linux-nfs.org>
Message-Id: <79627297-6825-4894-880C-8451A89C4077@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Daniel J Blueman <daniel.blueman@gmail.com>
In-Reply-To: <6278d2220806151110x68ee91fej8cf8e6b591ce1319@mail.gmail.com>
Subject: Re: [2.6.26-rc4] mount.nfsv4/memory poisoning issues...
Date: Mon, 16 Jun 2008 12:17:06 -0400
References: <6278d2220806041633n3bfe3dd2ke9602697697228b@mail.gmail.com>
	<76bd70e30806041643j4d632a6exf64b29c34173d40f@mail.gmail.com>
	<6278d2220806151110x68ee91fej8cf8e6b591ce1319@mail.gmail.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Jeff Layton <jlayton@redhat.com>, chucklever@gmail.com,
        nfsv4 <nfsv4@linux-nfs.org>,
        Linux Kernel <linux-kernel@vger.kernel.org>
List-Unsubscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=unsubscribe>
List-Archive: <http://linux-nfs.org/pipermail/nfsv4>
List-Post: <mailto:nfsv4@linux-nfs.org>
List-Help: <mailto:nfsv4-request@linux-nfs.org?subject=help>
List-Subscribe: <http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4>,
	<mailto:nfsv4-request@linux-nfs.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Sender: nfsv4-bounces@linux-nfs.org
Errors-To: nfsv4-bounces@linux-nfs.org
MIME-Version: 1.0
List-ID: <linux-nfs.vger.kernel.org>

Hi Daniel-

On Jun 15, 2008, at 2:10 PM, Daniel J Blueman wrote:
> On Thu, Jun 5, 2008 at 12:43 AM, Chuck Lever  
> <chuck.lever@oracle.com> wrote:
>> Hi Daniel-
>>
>> On Wed, Jun 4, 2008 at 7:33 PM, Daniel J Blueman
>> <daniel.blueman@gmail.com> wrote:
>>> Having experienced 'mount.nfs4: internal error' when mounting  
>>> nfsv4 in
>>> the past, I have a minimal test-case I sometimes run:
>>>
>>> $ while :; do mount -t nfs4 filer:/store /store; umount /store; done
>>>
>>> After ~100 iterations, I saw the 'mount.nfs4: internal error',
>>> followed by symptoms of memory corruption [1], a locking issue with
>>> the reporting [2] and another (related?) memory-corruption issue
>>> (off-by-1?) [3]. A little analysis shows memory being overwritten by
>>> (likely) a poison value, which gets complicated if it's not
>>> use-after-free...
>>>
>>> Anyone dare confirm this issue? NFSv4 server is x86-64 Ubuntu 8.04
>>> 2.6.24-18, client U8.04 2.6.26-rc4; batteries included [4].
>>
>> We have some other reports of late model kernels with memory
>> corruption issues during NFS mount.  The problem is that by the time
>> these canaries start singing, the evidence of what did the corrupting
>> is long gone.
>>
>>> I'm happy to decode addresses, test patches etc.
>>
>> If these crashes are more or less reliably reproduced, it would be
>> helpful if you could do a 'git bisect' on the client to figure out at
>> what point in the kernel revision history this problem was  
>> introduced.
>>
>> Have you seen the problem on client kernels earlier than 2.6.25?
>
> Firstly, I had omitted that I'd booted the kernel with
> debug_objects=1, which provides the canary here.
>
> The primary failure I see is 'mount.nfs4: internal error', and always
> after 358 umount/mount cycles (plus 1 initial mount) which gives us a
> clue; 'netstat' shows all these connections in a TIME_WAIT state, thus
> the bug relates to the inability to allocate a socket error path. I
> found that after the connection lifetime expired, you can mount again,
> which corroborates this theory.
>
> In this case, we saw the mount() syscall result in the mount.nfsv4
> process being SEGV'd when booted with 'debug_object=1', without this
> option, we see:
>
> # strace /sbin/mount.nfs4 x1:/ /store
> ...
> mount("x1:/", "/store", "nfs4", 0,
> "addr=192.168.0.250,clientaddr=19"...) = -1 EIO (Input/output error)
>
> So, it's impossible to tell when the corruption was introduced, as it
> has only become detectable recently.
>
> It's worth a look-over of the socket-allocation error path, if someone
> can check, and reproduces 100% with the 'debug_object=1' param,
> available since 2.6.26-rc1 and 359 mounts in quick succession.


That's nicely specific.

I'm juggling several other problems at the moment, but I will try to  
get back to this again in a day or two.

There's a lot of new code in the NFS mount path.  "internal error"  
means the mount command has encountered something entirely  
unexpected.  So when anyone sees this message, please go ahead and  
report it on the linux-nfs@vger.kernel.org list.  Thanks!

I will see if I can make that message a little more explicit.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
_______________________________________________
NFSv4 mailing list
NFSv4@linux-nfs.org
http://linux-nfs.org/cgi-bin/mailman/listinfo/nfsv4
