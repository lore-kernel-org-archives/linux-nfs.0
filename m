From: "Michal Piotrowski" <michal.k.k.piotrowski@gmail.com>
Subject: Re: [BUG] 2.6.23-rc5 kernel BUG at fs/nfs/nfs4xdr.c:945
Date: Sat, 8 Sep 2007 01:56:34 +0200
Message-ID: <6bffcb0e0709071656o6881fa17y61818a9733293a4c@mail.gmail.com>
References: <46E121B8.4080105@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: bfields@fieldses.org, neilb@suse.de, nfs@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: "Kamalesh Babulal" <kamalesh@linux.vnet.ibm.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1ITngd-0001bx-He
	for nfs@lists.sourceforge.net; Fri, 07 Sep 2007 16:56:31 -0700
Received: from rv-out-0910.google.com ([209.85.198.189])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1ITngg-0004fU-Vw
	for nfs@lists.sourceforge.net; Fri, 07 Sep 2007 16:56:36 -0700
Received: by rv-out-0910.google.com with SMTP id g11so1838164rvb
	for <nfs@lists.sourceforge.net>; Fri, 07 Sep 2007 16:56:34 -0700 (PDT)
In-Reply-To: <46E121B8.4080105@linux.vnet.ibm.com>
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

Hi,

On 07/09/2007, Kamalesh Babulal <kamalesh@linux.vnet.ibm.com> wrote:
> Sep  7 11:42:49 p55lp2 kernel: kernel BUG at fs/nfs/nfs4xdr.c:945!
> Sep  7 11:42:49 p55lp2 kernel: Oops: Exception in kernel mode, sig: 5 [#1]
> Sep  7 11:42:49 p55lp2 kernel: SMP NR_CPUS=128 NUMA pSeries
> Sep  7 11:42:49 p55lp2 kernel: Modules linked in: nfs lockd nfs_acl
> sunrpc ipv6 loop dm_mod ibmveth sg ibmvscsic sd_mod scsi_mod
> Sep  7 11:42:49 p55lp2 kernel: NIP: d000000000378044 LR:
> d000000000378034 CTR: 80000000001c5840
> Sep  7 11:42:49 p55lp2 kernel: REGS: c0000000d971b050 TRAP: 0700   Not
> tainted  (2.6.23-rc5-ppc64)
> Sep  7 11:42:49 p55lp2 kernel: MSR: 8000000000029032 <EE,ME,IR,DR>  CR:
> 28000444  XER: 00000014
> Sep  7 11:42:49 p55lp2 kernel: TASK = c000000002787740[11508] 'fsstress'
> THREAD: c0000000d9718000 CPU: 1
> Sep  7 11:42:49 p55lp2 kernel: GPR00: 0000000000000001 c0000000d971b2d0
> d0000000003bd648 0000000000000037
> Sep  7 11:42:49 p55lp2 kernel: GPR04: 0000000000000000 0000000000000000
> 0000000000000000 0000000000000000
> Sep  7 11:42:49 p55lp2 kernel: GPR08: 0000000000000002 c000000000616538
> c0000000ef7afb58 c000000000616540
> Sep  7 11:42:49 p55lp2 kernel: GPR12: 0000000000004000 c0000000005e4a80
> 0000000000000000 00000000200b2510
> Sep  7 11:42:49 p55lp2 kernel: GPR16: 0000000020105550 00000000200b2534
> 000000002008c15c 0000000000000001
> Sep  7 11:42:49 p55lp2 kernel: GPR20: 0000000000000000 0000000000000001
> fffffffffffff000 c0000000d971ba30
> Sep  7 11:42:49 p55lp2 kernel: GPR24: d00000000034f524 c0000000dc4f8054
> c0000000d971b7d0 c0000000d9d313f0
> Sep  7 11:42:49 p55lp2 kernel: GPR28: 0000000000000276 0000000022000000
> d0000000003b8d78 0000000000000000
> Sep  7 11:42:49 p55lp2 kernel: NIP [d000000000378044]
> .encode_lookup+0x6c/0xbc [nfs]
> Sep  7 11:42:49 p55lp2 kernel: LR [d000000000378034]
> .encode_lookup+0x5c/0xbc [nfs]
> Sep  7 11:42:49 p55lp2 kernel: Call Trace:
> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b2d0] [d000000000378034]
> .encode_lookup+0x5c/0xbc [nfs] (unreliable)
> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b370] [d000000000379f8c]
> .nfs4_xdr_enc_lookup+0x78/0xbc [nfs]
> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b440] [d000000000314534]
> .rpcauth_wrap_req+0xe4/0x124 [sunrpc]
> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b4f0] [d00000000030a790]
> .call_transmit+0x218/0x2b8 [sunrpc]
> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b590] [d0000000003124d8]
> .__rpc_execute+0xd4/0x368 [sunrpc]
> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b630] [d00000000030b114]
> .rpc_do_run_task+0xc8/0x104 [sunrpc]
> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b6e0] [d00000000030b224]
> .rpc_call_sync+0x2c/0x64 [sunrpc]
> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b760] [d00000000036ef04]
> ._nfs4_proc_lookupfh+0xd4/0x124 [nfs]
> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b850] [d0000000003719a0]
> ._nfs4_proc_lookup+0x80/0x21c [nfs]
> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b910] [d000000000371ba4]
> .nfs4_proc_lookup+0x68/0xac [nfs]
> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971b9c0] [d000000000354bf4]
> .nfs_lookup+0x158/0x334 [nfs]
> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971bbc0] [c0000000000f3a28]
> .lookup_hash+0xfc/0x140
> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971bc60] [c0000000000f7b28]
> .sys_renameat+0x164/0x228
> Sep  7 11:42:49 p55lp2 kernel: [c0000000d971be30] [c000000000008534]
> syscall_exit+0x0/0x40
> Sep  7 11:42:49 p55lp2 kernel: Instruction dump:
> Sep  7 11:42:49 p55lp2 kernel: e8410028 7fa4eb78 7c7f1b79 7fb80026
> 40820014 e8be83a8 e87e8350 4800c5f9
> Sep  7 11:42:49 p55lp2 kernel: e8410028 7fb80120 7c180026 54001ffe
> <0b000000> 3800000f 7b850020 387f0008

Is this a post 2.6.22 regression? Have you tried 2.6.23-rc5-git1?
(There are a few nfs fixes)

Regards,
Michal

-- 
LOG
http://www.stardust.webpages.pl/log/

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
