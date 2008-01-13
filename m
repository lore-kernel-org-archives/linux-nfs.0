From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 3/6] NLM: Initialize completion variable in lockd_up
Date: Sun, 13 Jan 2008 08:27:18 -0500
Message-ID: <20080113082718.396890f7@tleilax.poochiereds.net>
References: <1199820798-5289-1-git-send-email-jlayton@redhat.com>
	<1199820798-5289-2-git-send-email-jlayton@redhat.com>
	<1199820798-5289-3-git-send-email-jlayton@redhat.com>
	<1199820798-5289-4-git-send-email-jlayton@redhat.com>
	<20080109173542.GA30523@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: akpm@linux-foundation.org, neilb@suse.de,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: Christoph Hellwig <hch@infradead.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:44727 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751144AbYAMN1f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 13 Jan 2008 08:27:35 -0500
In-Reply-To: <20080109173542.GA30523@infradead.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 9 Jan 2008 17:35:42 +0000
Christoph Hellwig <hch@infradead.org> wrote:

> On Tue, Jan 08, 2008 at 02:33:15PM -0500, Jeff Layton wrote:
> > lockd_start_done is a global var that can be reused if lockd is
> > restarted, but it's never reinitialized. On all but the first use,
> > wait_for_completion isn't actually waiting on it since it has
> > already completed once.
> 
> I don't think we'll need lockd_start_done anymore after the kthread
> conversion.  When kthread_run returns the thread it created is
> guaranteed to have run until it scheduled away.
> 

Christoph,
   I've been hitting an intermittent null pointer dereference ever
since I've made this change:

BUG: unable to handle kernel NULL pointer dereference at virtual address 00000038
printing eip: e09ddee1 *pde = 1f377067 *pte = 00000000 
Oops: 0000 [#1] SMP 
Modules linked in: nfsd nfs_acl auth_rpcgss exportfs rfcomm l2cap bluetooth autofs4 lockd sunrpc nf_conntrack_ipv6 xt_state nf_conntrack xt_tcpudp ip6t_ipv6header ip6t_REJECT ip6table_filter ip6_tables x_tables ipv6 loop dm_multipath pcspkr 8139cp 8139too mii joydev i2c_piix4 i2c_core sr_mod sg cdrom dm_snapshot dm_zero dm_mirror dm_mod ata_piix pata_acpi ata_generic libata sd_mod scsi_mod ext3 jbd mbcache uhci_hcd ohci_hcd ehci_hcd

Pid: 1946, comm: rpc.nfsd Not tainted (2.6.24-0.138.rc7.kthread.2.fc9 #1)
EIP: 0060:[<e09ddee1>] EFLAGS: 00010202 CPU: 0
EIP is at find_socket+0xa/0x3f [lockd]
EAX: 00000000 EBX: 00000006 ECX: 00000000 EDX: 00000011
ESI: 00000000 EDI: 00000011 EBP: df358ec4 ESP: df358eb8
 DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
Process rpc.nfsd (pid: 1946, ti=df358000 task=df38ae10 task.ti=df358000)
Stack: 00000006 00000000 00000006 df358ee0 e09de0cb 22222222 22222222 00000006 
       00000008 00000801 df358f04 e09de337 00000000 00000000 00000000 00000000 
       00000801 00000008 00000801 df358f1c e0aa05ac 00000000 df356200 00000008 
Call Trace:
 [<c040649a>] show_trace_log_lvl+0x1a/0x2f
 [<c040654a>] show_stack_log_lvl+0x9b/0xa3
 [<c04065f9>] show_registers+0xa7/0x178
 [<c04067ff>] die+0x135/0x220
 [<c063ff1b>] do_page_fault+0x553/0x631
 [<c063e5a2>] error_code+0x72/0x78
 [<e09de0cb>] make_socks+0x27/0xbe [lockd]
 [<e09de337>] lockd_up+0x3b/0x148 [lockd]
 [<e0aa05ac>] nfsd_svc+0xf2/0x107 [nfsd]
 [<e0aa0b19>] write_svc+0x1a/0x20 [nfsd]
 [<e0aa0d10>] nfsctl_transaction_write+0x39/0x63 [nfsd]
 [<c04b97cf>] sys_nfsservctl+0x11f/0x160
 [<c0405252>] syscall_call+0x7/0xb
 =======================
Code: 89 d8 5b 5d c3 55 89 e5 c7 05 48 a4 9e e0 01 00 00 00 e8 a7 ff ff ff 8b 15 00 0c 76 c0 5d 01 d0 c3 55 89 e5 57 89 d7 56 89 c6 53 <8b> 48 38 83 e9 08 eb 15 8b 41 14 0f b6 40 29 39 f8 75 07 b8 01 
EIP: [<e09ddee1>] find_socket+0xa/0x3f [lockd] SS:ESP 0068:df358eb8
---[ end trace 7d509b4c18b144aa ]---

The problem is that make_socks is occasionally getting called with a
NULL nlmsvc_serv pointer. I think the problem occurs here in lockd_up().

        if (nlmsvc_task) {
                if (proto)
                        error = make_socks(nlmsvc_serv, proto);
                goto out;
        }

You pointed out earlier that this should really be checking that
nlmsvc_serv is non-NULL. I can and will make this change, and that will
likely fix this particular oops, but the fact that I'm hitting it here
suggests that kthread_run is returning before lockd has a chance
to set nlmsvc_serv. It shouldn't be according to your statement above.

Are you sure that kthread_run is working correctly? It seems like it
might not be doing the right thing here...

-- 
Jeff Layton <jlayton@redhat.com>
