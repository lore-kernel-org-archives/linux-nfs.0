Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34408 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751884Ab2FLLSH (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Jun 2012 07:18:07 -0400
Date: Tue, 12 Jun 2012 07:18:03 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: NFSv4 regression, kernel BUG at fs/nfsd/nfs4state.c:1044!
Message-ID: <20120612111802.GI31109@pad.fieldses.org>
References: <20120610090342.GA5076@cucamonga.audible.transient.net>
 <20120611161425.GF31109@pad.fieldses.org>
 <20120612101339.GB30293@cucamonga.audible.transient.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20120612101339.GB30293@cucamonga.audible.transient.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 12, 2012 at 10:13:39AM +0000, Jamie Heilman wrote:
> J. Bruce Fields wrote:
> > On Sun, Jun 10, 2012 at 09:03:42AM +0000, Jamie Heilman wrote:
> > > Upgrading my NFSv4 server from 3.3.8 to 3.4.2 I've managed to
> > > reproduce this reliably:
> > > 
> > > ------------[ cut here ]------------
> > > kernel BUG at fs/nfsd/nfs4state.c:1044!
> > 
> > That's 
> > 
> > 	free_client(struct nfs4_client *clp)
> > 	{
> > --->        	BUG_ON(!spin_is_locked(&client_lock));
> > 
> > 
> > > invalid opcode: 0000 [#1] 
> > > Modules linked in: md5 cpufreq_conservative cpufreq_stats cpufreq_powersave cpufreq_ondemand autofs4 quota_v2 quota_tree nfsd nfs_acl exportfs nfs lockd fscache auth_rpcgss sunrpc xt_mark xt_dscp cls_fw sch_htb iptable_nat nf_nat ipt_REJECT xt_multiport xt_mac xt_tcpudp iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_state nf_conntrack xt_LOG xt_limit iptable_filter ip_tables x_tables dm_crypt dm_mod snd_hda_codec_via tpm_tis tpm via_rhine snd_hda_intel snd_hda_codec tpm_bios mii via_velocity snd_hwdep snd_pcm snd_timer snd soundcore snd_page_alloc evdev crc_ccitt via_agp agpgart button
> > > 
> > > Pid: 1804, comm: nfsd Not tainted 3.4.2 #3 To Be Filled By O.E.M. To Be Filled By O.E.M./To be filled by O.E.M.
> > > EIP: 0060:[<f86ac683>] EFLAGS: 00010246 CPU: 0
> > > EIP is at free_client.isra.47+0x3/0x5 [nfsd]
> > > EAX: 00000000 EBX: e9d48800 ECX: e9d48030 EDX: f86b20f8
> > > ESI: e9d48810 EDI: e9cf9ec0 EBP: e9cf9eb4 ESP: e9cf9eb4
> > >  DS: 007b ES: 007b FS: 0000 GS: 00e0 SS: 0068
> > > CR0: 8005003b CR2: b760bee0 CR3: 34d04000 CR4: 000006b0
> > > DR0: 00000000 DR1: 00000000 DR2: 00000000 DR3: 00000000
> > > DR6: ffff0ff0 DR7: 00000400
> > > Process nfsd (pid: 1804, ti=e9cf8000 task=e9cf4000 task.ti=e9cf8000)
> > > Stack:
> > >  e9cf9ed4 f86a6c00 e9d48828 e9cf9ec0 e9cf9ec0 e9d48800 e9d48000 00000000
> > >  e9cf9f00 f86a6d36 00000000 000555c0 f53c0001 4fd43f69 00000001 7ad0b2a0
> > >  f4c45000 f4c44060 00000360 e9cf9f3c f869f63c f86aff20 e9cb9000 00000000
> > > Call Trace:
> > >  [<f86a6c00>] expire_client+0xb1/0xb9 [nfsd]
> > 
> > And the only free_client call there is:
> > 
> > 	spin_lock(&client_lock);
> > 	unhash_client_locked(clp);
> > 	if (atomic_read(&clp->cl_refcount) == 0)
> > --->		free_client(clp);
> > 	spin_unlock(&client_lock);
> > 
> > So, that's strange.
> 
> OK, other observations which may or may not have any value:
> - I can't trigger the BUG if I build with CONFIG_SMP (which obviously
>   changes the RCU as well)
> - I can't trigger the BUG if I build with CONFIG_DEBUG_SPINLOCK

Oh, OK, so probably spin_is_locked() just isn't reliable in the
!CONFIG_SMP case.  That would make sense.

So at a minimum we should change that BUG_ON to a WARN_ON_ONCE.

--b.

> - the "RPC: fragment too large" errors I mentioned appear to only occur
>   with a 3.5-rc client; I can't repro them with a 3.4 client
> 
> -- 
> Jamie Heilman                     http://audible.transient.net/~jamie/
