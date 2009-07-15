From: Jeff Garzik <jeff@garzik.org>
Subject: Re: 2.6.31-rc3 nfsv4 client regression (oops)
Date: Tue, 14 Jul 2009 21:19:09 -0400
Message-ID: <4A5D2E8D.1080701@garzik.org>
References: <4A5C3858.6070303@garzik.org> <1247571788.19099.32.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: LKML <linux-kernel@vger.kernel.org>,
	Linux NFS ML <linux-nfs@vger.kernel.org>,
	"Rafael J. Wysocki" <rjw@sisk.pl>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:45651 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756855AbZGOBUx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jul 2009 21:20:53 -0400
In-Reply-To: <1247571788.19099.32.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Tue, 2009-07-14 at 03:48 -0400, Jeff Garzik wrote:
>> The NFSv4 client just oops'd on me...
>>
>> NFSv4 client: 2.6.31-rc3, Fedora 10, x86-64
>> 		    2.6.30 works, I think 2.6.31-rc1 worked too
>>
>> NFSv4 server: 2.6.29.4-167.fc11.x86_64 (Fedora 11 kernel), F11, x86-64
>>
>> Oops output captured at kerneloops.org: 
>> http://www.kerneloops.org/raw.php?rawid=537858&msgid=
>>
>> Kernel config for 2.6.31-rc3, the problematic kernel, attached.
>>
>>
>>> RIP: 0010:[<ffffffffa02db5b0>]  [<ffffffffa02db5b0>] nfs4_free_lock_state+0x20/0x80 [nfs]
>>> [...]
>>> Call Trace:
>>>  [<ffffffffa02db7dd>] nfs4_set_lock_state+0x1cd/0x220 [nfs]
>>>  [<ffffffffa02cc9db>] nfs4_proc_lock+0x2cb/0x4e0 [nfs]
>>>  [<ffffffff810b40dc>] ? __alloc_pages_nodemask+0x10c/0x600
>>>  [<ffffffffa02b6079>] do_setlk+0xb9/0xd0 [nfs]
>>>  [<ffffffffa02b6220>] nfs_lock+0xd0/0x1d0 [nfs]
>>>  [<ffffffff8111e883>] vfs_lock_file+0x23/0x50
>>>  [<ffffffff8111eaa3>] fcntl_setlk+0x133/0x2f0
>>>  [<ffffffff81192571>] ? __up_read+0x91/0xb0
>>>  [<ffffffff810f0fea>] sys_fcntl+0xca/0x420
>>>  [<ffffffff8100b4fb>] system_call_fastpath+0x16/0x1b
> 
> Wow... That bug appears to have been there for years. I'm surprised it
> hasn't been reported before.
> 
> Anyhow, it looks to me as if you are hitting the case in
> nfs4_get_lock_state() where the first call to __nfs4_find_lock_state()
> fails, (and so 'new' gets allocated) then the second call succeeds. When
> the routine attempts to free the now redundant 'new', the call to
> nfs4_free_lock_state() oopses because new->ls_state hasn't been set.
> 
> The following patch ought to fix it...
> 
> ---------------------
> From: Trond Myklebust <Trond.Myklebust@netapp.com>
> NFSv4: Fix an Oops in nfs4_free_lock_state
> 
> The oops http://www.kerneloops.org/raw.php?rawid=537858&msgid= appears to
> be due to the nfs4_lock_state->ls_state field being uninitialised. This
> happens if the call to nfs4_free_lock_state() is triggered at the end of
> nfs4_get_lock_state().
> 
> The fixe is to move the initialisation of ls_state into the allocator.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>

Thanks, I'll give it a try!

	Jeff



