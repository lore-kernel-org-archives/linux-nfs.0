Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:30185 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932277Ab3CDUnV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 4 Mar 2013 15:43:21 -0500
From: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
To: Jan Engelhardt <jengelh@inai.de>
CC: Chuck Lever <chuck.lever@oracle.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: Inconsistent error codes between NFSv4 and v3 on network issues
Date: Mon, 4 Mar 2013 20:43:17 +0000
Message-ID: <4FA345DA4F4AE44899BD2B03EEEC2FA9286ADBED@sacexcmbx05-prd.hq.netapp.com>
References: <alpine.LNX.2.01.1303011240350.11154@nerf07.vanv.qr>
	 <6AADB1AD-6FB9-42AD-8BF2-6B0B706927E5@oracle.com>
	 <alpine.LNX.2.01.1303041957050.18372@nerf07.vanv.qr>
In-Reply-To: <alpine.LNX.2.01.1303041957050.18372@nerf07.vanv.qr>
Content-Type: text/plain; charset=US-ASCII
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 2013-03-04 at 20:10 +0100, Jan Engelhardt wrote:
> On Monday 2013-03-04 18:47, Chuck Lever wrote:
> >> 
> >> linux-3lzm:~ # strace -fe mount mount -t nfs 134.76.12.5:/X /mnt
> >> Process 1477 attached
> >> [pid  1515] mount("134.76.12.5:/X", "/mnt", "nfs", 0, "vers=4,addr=134.76.12.5,clientaddr=0.0.0.0") = -1 EIO (Input/output error)
> >
> >"clientaddr=0.0.0.0" is interesting: perhaps the mount.nfs command
> >should have failed right there.
> 
> Maybe (since there is no route). Maybe not: I would interpret 0.0.0.0
> as "kernel will pick something".
> 
> This kernel 3.7.9 system has rpcbind-0.2.0_git201103171419-7.1.1.x86_64
> and nfs-client-1.2.7-2.1.1.x86_64.
> 
> 
> >But, let's find out why the kernel is returning EIO.  Enter:
> >
> > # rpcdebug -m nfs -s all
> > # rpcdebug -m rpc -s call xprt
> >
> >Try your NFSv4 mount command again, then post relevant excerpts from the kernel log.
> 
> [205196.949572] NFS: nfs mount opts='vers=4,addr=134.76.12.5,clientaddr=0.0.0.0'
> [205196.949580] NFS:   parsing nfs mount option 'vers=4'
> [205196.949586] NFS:   parsing nfs mount option 'addr=134.76.12.5'
> [205196.949592] NFS:   parsing nfs mount option 'clientaddr=0.0.0.0'
> [205196.949597] NFS: MNTPATH: '/X'
> [205196.949600] --> nfs4_try_mount()
> [205196.949607] --> nfs4_create_server()
> [205196.949639] --> nfs4_init_server()
> [205196.949641] --> nfs4_set_client()
> [205196.949644] --> nfs_get_client(134.76.12.5,v4)
> [205196.949651] NFS: get client cookie (0xffff88007abe3800/0xffff88007ba29420)
> [205196.949666] RPC:       created transport ffff88007ba50800 with 65536 slots
> [205196.949670] RPC:       creating nfs client for 134.76.12.5 (xprt ffff88007ba50800)
> [205196.949693] RPC:     2 call_start nfs4 proc NULL (sync)
> [205196.949705] RPC:     2 call_reserve (status 0)
> [205196.949709] RPC:     2 reserved req ffff88007b342800 xid 11fca56c
> [205196.949712] RPC:     2 call_reserveresult (status 0)
> [205196.949714] RPC:     2 call_refresh (status 0)
> [205196.949716] RPC:     2 call_refreshresult (status 0)
> [205196.949718] RPC:     2 call_allocate (status 0)
> [205196.949722] RPC:     2 call_bind (status 0)
> [205196.949724] RPC:     2 call_connect xprt ffff88007ba50800 is not connected
> [205196.949727] RPC:     2 xprt_connect xprt ffff88007ba50800 is not connected
> [205196.949765] RPC:     2 xprt_connect_status: error 101 connecting to server 134.76.12.5
> [205196.949779] RPC:     2 call_connect_status (status -5)
> [205196.949791] RPC:     2 release request ffff88007b342800
> [205196.949794] RPC:       rpc_release_client(ffff88007b342e00)
> [205196.949797] RPC:       shutting down nfs client for 134.76.12.5
> [205196.949798] RPC:       rpc_release_client(ffff88007b342e00)
> [205196.949801] RPC:       destroying nfs client for 134.76.12.5
> [205196.949803] RPC:       destroying transport ffff88007ba50800
> [205196.949812] RPC:       disconnected transport ffff88007ba50800
> [205196.949816] nfs_create_rpc_client: cannot create RPC client. Error = -5
> [205196.949818] --> nfs_put_client({1})
> [205196.949820] --> nfs_free_client(4)
> [205196.949822] NFS: releasing client cookie (0xffff88007abe3800/0xffff88007ba29420)
> [205196.949824] <-- nfs_free_client()
> [205196.949826] <-- nfs4_init_client() = xerror -5
> [205196.949828] <-- nfs4_set_client() = xerror -5
> [205196.949829] <-- nfs4_init_server() = -5
> [205196.949831] --> nfs_free_server()
> [205196.949850] <-- nfs_free_server()
> [205196.949852] <-- nfs4_create_server() = error -5
> [205196.949856] <-- nfs4_try_mount() = -5 [error]
> 
> Just nuke your default route, and it should be easily reproducible.
> 

The problem is that call_connect_status() is converting that ENETUNREACH
into a EIO. We shouldn't be doing that, but should leave it up to the
caller (i.e. the NFS layer) to perform that kind of mapping.

Cheers
  Trond
