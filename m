From: suzuki <suzuki@in.ibm.com>
Subject: Re: [BUG] 2.6.23-rc5 kernel BUG at fs/nfs/nfs4xdr.c:945
Date: Mon, 10 Sep 2007 13:41:27 +0530
Message-ID: <46E4FC2F.6040105@in.ibm.com>
References: <46E121B8.4080105@linux.vnet.ibm.com>
	<6bffcb0e0709071656o6881fa17y61818a9733293a4c@mail.gmail.com>
	<1189289549.13713.4.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	neilb@suse.de, linux-kernel@vger.kernel.org,
	Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>, bfields@fieldses.org,
	nfs@lists.sourceforge.net, ffilz@us.ibm.com,
	Poornima <bnpoorni@in.ibm.com>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUeOZ-0007Wu-5U
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 01:13:23 -0700
Received: from e4.ny.us.ibm.com ([32.97.182.144])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IUeOd-0007IU-14
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 01:13:27 -0700
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l8A8DILK001897
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 04:13:18 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id
	l8A8DJ26552040
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 04:13:19 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id
	l8A8DIHX004418
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 04:13:18 -0400
In-Reply-To: <1189289549.13713.4.camel@localhost.localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Hi

I have been trying to debug this issue from my side and could find the 
following.

The pathconf() request gets a reply with :

pathinfo.max_namelen = (unsiged int) -1
pathinfo.max_link    = 255

Is this really an expected answer from a server for a proper connection 
( for mount requests on an exported dir) ? Is there something that needs 
to be fixed at server side ?

Thanks

Suzuki

Trond Myklebust wrote:
> On Sat, 2007-09-08 at 01:56 +0200, Michal Piotrowski wrote:
>> Hi,
>>
>> On 07/09/2007, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
>>> Sep  7 11:42:49 p55lp2 kernel: kernel BUG at fs/nfs/nfs4xdr.c:945!
>>> Sep  7 11:42:49 p55lp2 kernel: Oops: Exception in kernel mode, sig: 5 [#1]
>>> Sep  7 11:42:49 p55lp2 kernel: SMP NR_CPUS=128 NUMA pSeries
>>> Sep  7 11:42:49 p55lp2 kernel: Modules linked in: nfs lockd nfs_acl
>>> sunrpc ipv6 loop dm_mod ibmveth sg ibmvscsic sd_mod scsi_mod
>>> Sep  7 11:42:49 p55lp2 kernel: NIP: d000000000378044 LR:
>>> d000000000378034 CTR: 80000000001c5840
>>> Sep  7 11:42:49 p55lp2 kernel: REGS: c0000000d971b050 TRAP: 0700   Not
>>> tainted  (2.6.23-rc5-ppc64)
>>> Sep  7 11:42:49 p55lp2 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR:
>>> 28000444  XER: 00000014
>>> Sep  7 11:42:49 p55lp2 kernel: TASK = c000000002787740[11508] 'fsstress'
>>> THREAD: c0000000d9718000 CPU: 1
>>> Sep  7 11:42:49 p55lp2 kernel: GPR00: 0000000000000001 c0000000d971b2d0
>>> d0000000003bd648 0000000000000037
>>> Sep  7 11:42:49 p55lp2 kernel: GPR04: 0000000000000000 0000000000000000
>>> 0000000000000000 0000000000000000
>>> Sep  7 11:42:49 p55lp2 kernel: GPR08: 0000000000000002 c000000000616538
>>> c0000000ef7afb58 c000000000616540
>>> Sep  7 11:42:49 p55lp2 kernel: GPR12: 0000000000004000 c0000000005e4a80
>>> 0000000000000000 00000000200b2510
>>> Sep  7 11:42:49 p55lp2 kernel: GPR16: 0000000020105550 00000000200b2534
>>> 000000002008c15c 0000000000000001
>>> Sep  7 11:42:49 p55lp2 kernel: GPR20: 0000000000000000 0000000000000001
>>> fffffffffffff000 c0000000d971ba30
>>> Sep  7 11:42:49 p55lp2 kernel: GPR24: d00000000034f524 c0000000dc4f8054
>>> c0000000d971b7d0 c0000000d9d313f0
>>> Sep  7 11:42:49 p55lp2 kernel: GPR28: 0000000000000276 0000000022000000
>>> d0000000003b8d78 0000000000000000
>>> Sep  7 11:42:49 p55lp2 kernel: NIP [d000000000378044]
>>> .encode_lookup+0x6c/0xbc [nfs]
>>> Sep  7 11:42:49 p55lp2 kernel: LR [d000000000378034]
>>> .encode_lookup+0x5c/0xbc [nfs]
>>> Sep  7 11:42:49 p55lp2 kernel: Call Trace:
>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b2d0] [d000000000378034]
>>> .encode_lookup+0x5c/0xbc [nfs] (unreliable)
>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b370] [d000000000379f8c]
>>> .nfs4_xdr_enc_lookup+0x78/0xbc [nfs]
>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b440] [d000000000314534]
>>> .rpcauth_wrap_req+0xe4/0x124 [sunrpc]
>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b4f0] [d00000000030a790]
>>> .call_transmit+0x218/0x2b8 [sunrpc]
>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b590] [d0000000003124d8]
>>> .__rpc_execute+0xd4/0x368 [sunrpc]
>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b630] [d00000000030b114]
>>> .rpc_do_run_task+0xc8/0x104 [sunrpc]
>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b6e0] [d00000000030b224]
>>> .rpc_call_sync+0x2c/0x64 [sunrpc]
>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b760] [d00000000036ef04]
>>> ._nfs4_proc_lookupfh+0xd4/0x124 [nfs]
>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b850] [d0000000003719a0]
>>> ._nfs4_proc_lookup+0x80/0x21c [nfs]
>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b910] [d000000000371ba4]
>>> .nfs4_proc_lookup+0x68/0xac [nfs]
>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b9c0] [d000000000354bf4]
>>> .nfs_lookup+0x158/0x334 [nfs]
>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971bbc0] [c0000000000f3a28]
>>> .lookup_hash+0xfc/0x140
>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971bc60] [c0000000000f7b28]
>>> .sys_renameat+0x164/0x228
>>> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971be30] [c000000000008534]
>>> syscall_exit+0x0/0x40
>>> Sep  7 11:42:49 p55lp2 kernel: Instruction dump:
>>> Sep  7 11:42:49 p55lp2 kernel: e8410028 7fa4eb78 7c7f1b79 7fb80026
>>> 40820014 e8be83a8 e87e8350 4800c5f9
>>> Sep  7 11:42:49 p55lp2 kernel: e8410028 7fb80120 7c180026 54001ffe
>>> <0b000000> 3800000f 7b850020 387f0008
>> Is this a post 2.6.22 regression? Have you tried 2.6.23-rc5-git1?
>> (There are a few nfs fixes)
>>
>> Regards,
>> Michal
> 
> It looks like a bug that has been there at least since 2.6.18. Could you
> see if this fixes it?
> 
> Trond
> 
> 
> 
> 
> ------------------------------------------------------------------------
> 
> Subject:
> No Subject
> From:
> Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:
> Sun, 9 Sep 2007 00:10:51 +0200
> 
> 
> It doesn't look as if the NFSv4 name length is being initialised correctly
> in the struct nfs_server. We need to limit any entry there to
> NFS4_MAXNAMLEN.
> 
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
> 
>  fs/nfs/client.c |    3 +++
>  1 files changed, 3 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index a49f9fe..54068fb 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -928,6 +928,9 @@ static int nfs4_init_server(struct nfs_server *server,
> 
>  	error = nfs_init_server_rpcclient(server, authflavour);
> 
> +	if (server->namelen == 0 || server->namelen > NFS4_MAXNAMLEN)
> +		server->namelen = NFS4_MAXNAMLEN;
> +
>  	/* Done */
>  	dprintk("<-- nfs4_init_server() = %d\n", error);
>  	return error;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
