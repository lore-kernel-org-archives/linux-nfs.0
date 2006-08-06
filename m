From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH 010 of 11] knfsd: make rpc threads pools numa aware
Date: Sun, 6 Aug 2006 02:47:03 -0700
Message-ID: <20060806024703.2fb9f307.akpm@osdl.org>
References: <20060731103458.29040.patches@notabene>
	<1060731004234.29291@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	Greg Banks <gnb@melbourne.sgi.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1G9fDy-00061y-Af
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 02:47:10 -0700
Received: from smtp.osdl.org ([65.172.181.4])
	by mail.sourceforge.net with esmtps (TLSv1:DES-CBC3-SHA:168)
	(Exim 4.44) id 1G9fDx-0007KC-Gp
	for nfs@lists.sourceforge.net; Sun, 06 Aug 2006 02:47:10 -0700
To: NeilBrown <neilb@suse.de>
In-Reply-To: <1060731004234.29291@suse.de>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Mon, 31 Jul 2006 10:42:34 +1000
NeilBrown <neilb@suse.de> wrote:

> knfsd: Actually implement multiple pools.  On NUMA machines, allocate
> a svc_pool per NUMA node; on SMP a svc_pool per CPU; otherwise a single
> global pool.  Enqueue sockets on the svc_pool corresponding to the CPU
> on which the socket bh is run (i.e. the NIC interrupt CPU).  Threads
> have their cpu mask set to limit them to the CPUs in the svc_pool that
> owns them.
> 
> This is the patch that allows an Altix to scale NFS traffic linearly
> beyond 4 CPUs and 4 NICs.
> 
> Incorporates changes and feedback from Neil Brown, Trond Myklebust,
> and Christoph Hellwig.

This makes the NFS client go BUG.  Simple nfsv3 workload (ie: mount, read
stuff).  Uniproc, FC5.  

+	BUG_ON(m->mode == SVC_POOL_NONE);


kernel BUG at net/sunrpc/svc.c:244!
invalid opcode: 0000 [#1]
4K_STACKS 
last sysfs file: /class/net/eth1/flags
Modules linked in: nfs lockd nfs_acl ipw2200 sonypi autofs4 hidp l2cap bluetooth sunrpc ip_conntrack_netbios_ns ipt_REJECT xt_state ip_conntrack nfnetlink xt_tcpudp iptable_filter ip_tables x_tables video sony_acpi sbs i2c_ec button battery asus_acpi ac nvram ohci1394 ieee1394 ehci_hcd uhci_hcd sg joydev snd_hda_intel snd_hda_codec snd_seq_dummy snd_seq_oss snd_seq_midi_event snd_seq snd_seq_device ieee80211 snd_pcm_oss snd_mixer_oss ieee80211_crypt snd_pcm snd_timer snd i2c_i801 soundcore i2c_core piix snd_page_alloc pcspkr generic ext3 jbd ide_disk ide_core
CPU:    0
EIP:    0060:[<f8d6d308>]    Not tainted VLI
EFLAGS: 00210246   (2.6.18-rc3-mm1 #21) 
EIP is at svc_pool_for_cpu+0xc/0x43 [sunrpc]
eax: ffffffff   ebx: f59a75c0   ecx: f59a76c0   edx: 00000000
esi: f59cbc20   edi: f59a75c0   ebp: f582d5c0   esp: f59cbb98
ds: 007b   es: 007b   ss: 0068
Process mount (pid: 2599, ti=f59cb000 task=f59a5550 task.ti=f59cb000)
Stack: f8d6e506 f59cbbb0 00000000 00200282 00000014 00000006 f59a76c0 f59a75c0 
       f59cbc20 f59a75c0 f582d5c0 f8d6ea83 00200286 c0270376 f582d5c0 f59a76c0 
       f59a75c0 c02dbbc0 00000006 f59a76c0 f5956c80 f8d6ebd7 00000001 00000000 
Call Trace:
 [<f8d6e506>] svc_sock_enqueue+0x33/0x294 [sunrpc]
 [<f8d6ea83>] svc_setup_socket+0x31c/0x326 [sunrpc]
 [<c0270376>] release_sock+0xc/0x83
 [<f8d6ebd7>] svc_makesock+0x14a/0x185 [sunrpc]
 [<f8ca3b10>] make_socks+0x72/0xae [lockd]
 [<f8ca3bce>] lockd_up+0x82/0xd9 [lockd]
 [<c01169a6>] __wake_up+0x11/0x1a
 [<f9227743>] nfs_start_lockd+0x26/0x43 [nfs]
 [<f9228264>] nfs_create_server+0x1dc/0x3da [nfs]
 [<c02c4298>] wait_for_completion+0x70/0x99
 [<c0116293>] default_wake_function+0x0/0xc
 [<c0124918>] call_usermodehelper_keys+0xc4/0xd3
 [<f922e348>] nfs_get_sb+0x398/0x3b4 [nfs]
 [<c0124927>] __call_usermodehelper+0x0/0x43
 [<c0158d68>] vfs_kern_mount+0x83/0xf6
 [<c0158e1d>] do_kern_mount+0x2d/0x3e
 [<c016a8ac>] do_mount+0x5b2/0x625
 [<c019facb>] task_has_capability+0x56/0x5e
 [<c029479e>] inet_bind_bucket_create+0x11/0x3c
 [<c0295e57>] inet_csk_get_port+0x196/0x1a0
 [<c0270376>] release_sock+0xc/0x83
 [<c02add33>] inet_bind+0x1c6/0x1d0
 [<c01397fe>] handle_IRQ_event+0x23/0x49
 [<c013ec5e>] __alloc_pages+0x5e/0x28d
 [<c01034d2>] common_interrupt+0x1a/0x20
 [<c0169815>] copy_mount_options+0x26/0x109
 [<c016a991>] sys_mount+0x72/0xa4
 [<c0102b4b>] syscall_call+0x7/0xb
Code: 31 c0 eb 15 8b 40 10 89 d1 c1 e9 02 8b 50 1c 8d 41 02 89 42 04 8d 44 8b 08 5a 59 5b c3 90 90 89 c1 a1 88 86 d8 f8 83 f8 ff 75 0a <0f> 0b f4 00 2c 6f d7 f8 eb 0a 83 f8 01 74 09 83 f8 02 74 0e 31 
EIP: [<f8d6d308>] svc_pool_for_cpu+0xc/0x43 [sunrpc] SS:ESP 0068:f59cbb98
 

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys -- and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
