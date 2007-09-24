From: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Subject: Re: [NFS] [BUG] 2.6.23-rc5 kernel BUG at fs/nfs/nfs4xdr.c:945
Date: Tue, 25 Sep 2007 00:31:37 +0530
Message-ID: <46F80991.6010001@linux.vnet.ibm.com>
References: <46E121B8.4080105@linux.vnet.ibm.com> <6bffcb0e0709071656o6881fa17y61818a9733293a4c@mail.gmail.com> <1189289549.13713.4.camel@localhost.localdomain> <46E54156.8060706@linux.vnet.ibm.com> <1190223091.6734.2.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762443AbXIXTCU@vger.kernel.org>
In-Reply-To: <1190223091.6734.2.camel@heimdal.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Trond Myklebust wrote:
> On Mon, 2007-09-10 at 18:36 +0530, Kamalesh Babulal wrote:
>> Trond Myklebust wrote:
>>> On Sat, 2007-09-08 at 01:56 +0200, Michal Piotrowski wrote:
>>>   
>>>> Hi,
>>>>
>>>> On 07/09/2007, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
>>>>     
>>>>> Sep  7 11:42:49 p55lp2 kernel: kernel BUG at fs/nfs/nfs4xdr.c:945!
>>>>> Sep  7 11:42:49 p55lp2 kernel: Oops: Exception in kernel mode, sig: 5 [#1]
>>>>> Sep  7 11:42:49 p55lp2 kernel: SMP NR_CPUS=128 NUMA pSeries
>>>>> Sep  7 11:42:49 p55lp2 kernel: Modules linked in: nfs lockd nfs_acl
>>>>> sunrpc ipv6 loop dm_mod ibmveth sg ibmvscsic sd_mod scsi_mod
>>>>> Sep  7 11:42:49 p55lp2 kernel: NIP: d000000000378044 LR:
>>>>> d000000000378034 CTR: 80000000001c5840
>>>>> Sep  7 11:42:49 p55lp2 kernel: REGS: c0000000d971b050 TRAP: 0700   Not
>>>>> tainted  (2.6.23-rc5-ppc64)
>>>>> Sep  7 11:42:49 p55lp2 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR:
>>>>> 28000444  XER: 00000014
>>>>> Sep  7 11:42:49 p55lp2 kernel: TASK = c000000002787740[11508] 'fsstress'
>>>>> THREAD: c0000000d9718000 CPU: 1
>>>>> Sep  7 11:42:49 p55lp2 kernel: GPR00: 0000000000000001 c0000000d971b2d0
>>>>> d0000000003bd648 0000000000000037
>>>>> Sep  7 11:42:49 p55lp2 kernel: GPR04: 0000000000000000 0000000000000000
>>>>> 0000000000000000 0000000000000000
>>>>> Sep  7 11:42:49 p55lp2 kernel: GPR08: 0000000000000002 c000000000616538
>>>>> c0000000ef7afb58 c000000000616540
>>>>> Sep  7 11:42:49 p55lp2 kernel: GPR12: 0000000000004000 c0000000005e4a80
>>>>> 0000000000000000 00000000200b2510
>>>>> Sep  7 11:42:49 p55lp2 kernel: GPR16: 0000000020105550 00000000200b2534
>>>>> 000000002008c15c 0000000000000001
>>>>> Sep  7 11:42:49 p55lp2 kernel: GPR20: 0000000000000000 0000000000000001
>>>>> fffffffffffff000 c0000000d971ba30
>>>>> Sep  7 11:42:49 p55lp2 kernel: GPR24: d00000000034f524 c0000000dc4f8054
>>>>> c0000000d971b7d0 c0000000d9d313f0
>>>>> Sep  7 11:42:49 p55lp2 kernel: GPR28: 0000000000000276 0000000022000000
>>>>> d0000000003b8d78 0000000000000000
>>>>> Sep  7 11:42:49 p55lp2 kernel: NIP [d000000000378044]
>>>>> .encode_lookup+0x6c/0xbc [nfs]
>>>>> Sep  7 11:42:49 p55lp2 kernel: LR [d000000000378034]
>>>>> .encode_lookup+0x5c/0xbc [nfs]
>>>>> Sep  7 11:42:49 p55lp2 kernel: Call Trace:
>>>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b2d0] [d000000000378034]
>>>>> .encode_lookup+0x5c/0xbc [nfs] (unreliable)
>>>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b370] [d000000000379f8c]
>>>>> .nfs4_xdr_enc_lookup+0x78/0xbc [nfs]
>>>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b440] [d000000000314534]
>>>>> .rpcauth_wrap_req+0xe4/0x124 [sunrpc]
>>>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b4f0] [d00000000030a790]
>>>>> .call_transmit+0x218/0x2b8 [sunrpc]
>>>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b590] [d0000000003124d8]
>>>>> .__rpc_execute+0xd4/0x368 [sunrpc]
>>>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b630] [d00000000030b114]
>>>>> .rpc_do_run_task+0xc8/0x104 [sunrpc]
>>>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b6e0] [d00000000030b224]
>>>>> .rpc_call_sync+0x2c/0x64 [sunrpc]
>>>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b760] [d00000000036ef04]
>>>>> ._nfs4_proc_lookupfh+0xd4/0x124 [nfs]
>>>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b850] [d0000000003719a0]
>>>>> ._nfs4_proc_lookup+0x80/0x21c [nfs]
>>>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b910] [d000000000371ba4]
>>>>> .nfs4_proc_lookup+0x68/0xac [nfs]
>>>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b9c0] [d000000000354bf4]
>>>>> .nfs_lookup+0x158/0x334 [nfs]
>>>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971bbc0] [c0000000000f3a28]
>>>>> .lookup_hash+0xfc/0x140
>>>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971bc60] [c0000000000f7b28]
>>>>> .sys_renameat+0x164/0x228
>>>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971be30] [c000000000008534]
>>>>> syscall_exit+0x0/0x40
>>>>> Sep  7 11:42:49 p55lp2 kernel: Instruction dump:
>>>>> Sep  7 11:42:49 p55lp2 kernel: e8410028 7fa4eb78 7c7f1b79 7fb80026
>>>>> 40820014 e8be83a8 e87e8350 4800c5f9
>>>>> Sep  7 11:42:49 p55lp2 kernel: e8410028 7fb80120 7c180026 54001ffe
>>>>> <0b000000> 3800000f 7b850020 387f0008
>>>>>       
>>>> Is this a post 2.6.22 regression? Have you tried 2.6.23-rc5-git1?
>>>> (There are a few nfs fixes)
>>>>
>>>> Regards,
>>>> Michal
>>>>     
>>> It looks like a bug that has been there at least since 2.6.18. Could you
>>> see if this fixes it?
>>>
>>> Trond
>>>
>>>
>>>   
>>>
>>> ------------------------------------------------------------------------
>>>
>>> Subject:
>>> No Subject
>>> From:
>>> Trond Myklebust <Trond.Myklebust@netapp.com>
>>> Date:
>>> Sun, 9 Sep 2007 00:10:51 +0200
>>>
>>>
>>> It doesn't look as if the NFSv4 name length is being initialised correctly
>>> in the struct nfs_server. We need to limit any entry there to
>>> NFS4_MAXNAMLEN.
>>>
>>> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
>>> ---
>>>
>>>  fs/nfs/client.c |    3 +++
>>>  1 files changed, 3 insertions(+), 0 deletions(-)
>>>
>>> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
>>> index a49f9fe..54068fb 100644
>>> --- a/fs/nfs/client.c
>>> +++ b/fs/nfs/client.c
>>> @@ -928,6 +928,9 @@ static int nfs4_init_server(struct nfs_server *server,
>>>
>>>  	error = nfs_init_server_rpcclient(server, authflavour);
>>>
>>> +	if (server->namelen == 0 || server->namelen > NFS4_MAXNAMLEN)
>>> +		server->namelen = NFS4_MAXNAMLEN;
>>> +
>>>  	/* Done */
>>>  	dprintk("<-- nfs4_init_server() = %d\n", error);
>>>  	return error;
>>>   
>> Hi Trond,
>>
>> After applying the patch, i get the same kernel Bug
>>
>> cpu 0x0: Vector: 700 (Program Check) at [c0000000e2d5f050]
>>     pc: d000000000841668: .encode_lookup+0x6c/0xbc [nfs]
>>     lr: d000000000841658: .encode_lookup+0x5c/0xbc [nfs]
>>     sp: c0000000e2d5f2d0
>>    msr: 8000000000029032
>>   current = 0xc0000000e6358790
>>   paca    = 0xc0000000005ead00
>>     pid   = 3452, comm = fsstress
>> kernel BUG at fs/nfs/nfs4xdr.c:945!
>> enter ? for help
>> [c0000000e2d5f370] d0000000008435b0 .nfs4_xdr_enc_lookup+0x78/0xbc [nfs]
>> [c0000000e2d5f440] d00000000019a2d4 .rpcauth_wrap_req+0xe4/0x124 [sunrpc]
>> [c0000000e2d5f4f0] d000000000190774 .call_transmit+0x218/0x2b8 [sunrpc]
>> [c0000000e2d5f590] d000000000198308 .__rpc_execute+0xd4/0x34c [sunrpc]
>> [c0000000e2d5f630] d0000000001910f8 .rpc_do_run_task+0xc8/0x104 [sunrpc]
>> [c0000000e2d5f6e0] d000000000191208 .rpc_call_sync+0x2c/0x64 [sunrpc]
>> [c0000000e2d5f760] d0000000008386f0 ._nfs4_proc_lookupfh+0xd4/0x124 [nfs]
>> [c0000000e2d5f850] d00000000083b14c ._nfs4_proc_lookup+0x80/0x21c [nfs]
>> [c0000000e2d5f910] d00000000083b350 .nfs4_proc_lookup+0x68/0xac [nfs]
>> [c0000000e2d5f9c0] d00000000081ea40 .nfs_lookup+0x158/0x314 [nfs]
>> [c0000000e2d5fbc0] c0000000000f4ba8 .lookup_hash+0xfc/0x140
>> [c0000000e2d5fc60] c0000000000f8a70 .sys_renameat+0x164/0x228
>> [c0000000e2d5fe30] c000000000008534 syscall_exit+0x0/0x40
>> --- Exception: c01 (System Call) at 000000000feeb3d4
>> SP (ffe805a0) is in userspace
>>
>>
>> Thanks & Regards,
>> Kamalesh Babulal.
> 
> I'm mystified. I'm quite unable to reproduce this on my own setup: the
> ENAMETOOLONG error reporting mechanism prevents me from even getting
> near the above bug.
> 
> Could you add a little printk into the 'encode_lookup' routine on line
> 944 of fs/nfs/nfs4xdr.c to display the value of 'len'?
> 
> Cheers
>   Trond

Hi Trond,

Sorry, for replying so late, i have included the printk as you have requested.

len passed on encode_lookup [811]RESERVE_SPACE(819) failed in function encode_lookup
Sep 24 13:20:02 p55lp2 kernel: ------------[ cut here ]------------
Sep 24 13:20:02 p55lp2 kernel: kernel BUG at fs/nfs/nfs4xdr.c:947!
Sep 24 13:20:02 p55lp2 kernel: Oops: Exception in kernel mode, sig: 5 [#1]
Sep 24 13:20:02 p55lp2 kernel: SMP NR_CPUS=128 NUMA pSeries
Sep 24 13:20:02 p55lp2 kernel: Modules linked in: nfs lockd nfs_acl sunrpc ipv6 loop dm_mod ibmveth sg ibmvscsic sd_mod scsi_mod
Sep 24 13:20:02 p55lp2 kernel: NIP: d000000000378228 LR: d000000000378218 CTR: 0000000000000001
Sep 24 13:20:02 p55lp2 kernel: REGS: c0000000e7daec50 TRAP: 0700   Not tainted  (2.6.23-rc6-2-ppc64)
Sep 24 13:20:02 p55lp2 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR: 28022424  XER: 00000014
Sep 24 13:20:02 p55lp2 kernel: TASK = c000000004bc05c0[3446] 'touch' THREAD: c0000000e7dac000 CPU: 1
Sep 24 13:20:02 p55lp2 kernel: GPR00: 0000000000000001 c0000000e7daeed0 d0000000003bda08 0000000000000034
Sep 24 13:20:02 p55lp2 kernel: GPR04: 0000000000000001 0000000000000001 0000000000000000 c0000000005c8bb0
Sep 24 13:20:02 p55lp2 kernel: GPR08: 0000000000002e35 c000000000616540 c00000000071c510 c00000000071c508
Sep 24 13:20:02 p55lp2 kernel: GPR12: 00000000000186a0 c0000000005e4a80 0000000010020000 0000000010000000
Sep 24 13:20:02 p55lp2 kernel: GPR16: 0000000010000000 000000001000765c 0000000000000000 0000000010020000
Sep 24 13:20:02 p55lp2 kernel: GPR20: 0000000000000001 0000000010020000 0000000000000001 c0000000e7daf630
Sep 24 13:20:02 p55lp2 kernel: GPR24: d00000000034f524 c0000000e750f054 c0000000e7daf3d0 c0000000e5026ce0
Sep 24 13:20:02 p55lp2 kernel: GPR28: 0000000000000000 0000000022000000 d0000000003b9100 000000000000032b
Sep 24 13:20:02 p55lp2 kernel: NIP [d000000000378228] .encode_lookup+0x84/0xd4 [nfs]
Sep 24 13:20:02 p55lp2 kernel: LR [d000000000378218] .encode_lookup+0x74/0xd4 [nfs]
Sep 24 13:20:02 p55lp2 kernel: Call Trace:
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7daeed0] [d000000000378218] .encode_lookup+0x74/0xd4 [nfs] (unreliable)
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7daef70] [d00000000037a170] .nfs4_xdr_enc_lookup+0x78/0xbc [nfs]
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7daf040] [d000000000314534] .rpcauth_wrap_req+0xe4/0x124 [sunrpc]
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7daf0f0] [d00000000030a790] .call_transmit+0x218/0x2b8 [sunrpc]
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7daf190] [d0000000003124d8] .__rpc_execute+0xd4/0x368 [sunrpc]
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7daf230] [d00000000030b114] .rpc_do_run_task+0xc8/0x104 [sunrpc]
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7daf2e0] [d00000000030b224] .rpc_call_sync+0x2c/0x64 [sunrpc]
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7daf360] [d00000000036f0c4] ._nfs4_proc_lookupfh+0xd4/0x124 [nfs]
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7daf450] [d000000000371b60] ._nfs4_proc_lookup+0x80/0x21c [nfs]
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7daf510] [d000000000371d64] .nfs4_proc_lookup+0x68/0xac [nfs]
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7daf5c0] [d000000000354c0c] .nfs_lookup+0x158/0x334 [nfs]
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7daf7c0] [c0000000000f3738] .do_lookup+0xfc/0x24c
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7daf880] [c0000000000f6c48] .__link_path_walk+0xce4/0x13b4
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7daf960] [c0000000000f73b4] .link_path_walk+0x9c/0x184
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7dafaa0] [c0000000000f7964] .do_path_lookup+0x2fc/0x3ac
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7dafb50] [c0000000000f83d4] .__user_walk_fd+0x58/0x88
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7dafbf0] [c00000000011648c] .do_utimes+0x7c/0x24c
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7dafd70] [c00000000012a260] .compat_sys_futimesat+0x18c/0x1c4
Sep 24 13:20:02 p55lp2 kernel: [c0000000e7dafe30] [c000000000008534] syscall_exit+0x0/0x40
Sep 24 13:20:02 p55lp2 kernel: Instruction dump:
Sep 24 13:20:02 p55lp2 kernel: e8410028 7fa4eb78 7c7c1b79 7fb80026 40820014 e8be83b0 e87e8350 4800c5fd
Sep 24 13:20:02 p55lp2 kernel: e8410028 7fb80120 7c180026 54001ffe <0b000000> 3800000f 7be50020 387c0008




-- 
Thanks & Regards,
Kamalesh Babulal,
Linux Technology Center,
IBM, ISTL.
