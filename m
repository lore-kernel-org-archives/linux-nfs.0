Return-Path: linux-nfs-owner@vger.kernel.org
Received: from xes-mad.com ([216.165.139.218]:9192 "EHLO xes-mad.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750924AbaCFTqu convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Mar 2014 14:46:50 -0500
Date: Thu, 6 Mar 2014 13:46:36 -0600 (CST)
From: Andrew Martin <amartin@xes-inc.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jim Rees <rees@umich.edu>, bhawley@luminex.com, Brown Neil <neilb@suse.de>,
        linux-nfs-owner@vger.kernel.org, linux-nfs@vger.kernel.org
Message-ID: <2043391310.134091.1394135196565.JavaMail.zimbra@xes-inc.com>
In-Reply-To: <B454F556-9381-4DB7-B864-EC066DBEAC63@primarydata.com>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <1709792528-1394084840-cardhu_decombobulator_blackberry.rim.net-1367662481-@b5.c4.bise6.blackberry> <764210708.28409.1394119821635.JavaMail.zimbra@xes-inc.com> <20140306162208.GA18207@umich.edu> <1094203678.52139.1394124222574.JavaMail.zimbra@xes-inc.com> <20140306173632.GA18545@umich.edu> <1397912955.101159.1394130906695.JavaMail.zimbra@xes-inc.com> <B454F556-9381-4DB7-B864-EC066DBEAC63@primarydata.com>
Subject: Re: Optimal NFS mount options to safely allow interrupts and
 timeouts on newer kernels
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

> From: "Trond Myklebust" <trond.myklebust@primarydata.com>
> On Mar 6, 2014, at 13:35, Andrew Martin <amartin@xes-inc.com> wrote:
> 
> >> From: "Jim Rees" <rees@umich.edu>
> >> Why would a bunch of blocked apaches cause high load and reboot?
> > What I believe happens is the apache child processes go to serve
> > these requests and then block in uninterruptable sleep. Thus, there
> > are fewer and fewer child processes to handle new incoming requests.
> > Eventually, apache would normally kill said children (e.g after a
> > child handles a certain number of requests), but it cannot kill them
> > because they are in uninterruptable sleep. As more and more incoming
> > requests are queued (and fewer and fewer child processes are available
> > to serve the requests), the load climbs.
> 
> Does ‘top’ support this theory? Presumably you should see a handful of
> non-sleeping apache threads dominating the load when it happens.
Yes, it looks like the root apache process is still running:
root      1773  0.0  0.1 244176 16588 ?        Ss   Feb18   0:42 /usr/sbin/apache2 -k start

All of the others, the children (running as the www-data user), are marked as D.

> Why is the server becoming ‘unavailable’ in the first place? Are you taking
> it down?
I do not know the answer to this. A single NFS server has an export that is
mounted on multiple servers, including this web server. The web server is
running Ubuntu 10.04 LTS 2.6.32-57 with nfs-common 1.2.0. Intermittently, the
NFS mountpoint will become inaccessible on this web server; processes that 
attempt to access it will block in uninterruptable sleep. While this is 
occurring, the NFS export is still accessible normally from other clients, 
so it appears to be related to this particular machine (probably since it is 
the last machine running Ubuntu 10.04 and not 12.04). I do not know if this 
is a bug in 2.6.32 or another package on the system, but at this time I 
cannot upgrade it to 12.04, so I need to find a solution on 10.04. 

I attempted to get a backtrace from one of the uninterruptable apache processes:
echo w > /proc/sysrq-trigger

Here's one example:
[1227348.003904] apache2       D 0000000000000000     0 10175   1773 0x00000004
[1227348.003906]  ffff8802813178c8 0000000000000082 0000000000015e00 0000000000015e00
[1227348.003908]  ffff8801d88f03d0 ffff880281317fd8 0000000000015e00 ffff8801d88f0000
[1227348.003910]  0000000000015e00 ffff880281317fd8 0000000000015e00 ffff8801d88f03d0
[1227348.003912] Call Trace:
[1227348.003918]  [<ffffffffa00a5ca0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
[1227348.003923]  [<ffffffffa00a5cc4>] rpc_wait_bit_killable+0x24/0x40 [sunrpc]
[1227348.003925]  [<ffffffff8156a41f>] __wait_on_bit+0x5f/0x90
[1227348.003930]  [<ffffffffa00a5ca0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
[1227348.003932]  [<ffffffff8156a4c8>] out_of_line_wait_on_bit+0x78/0x90
[1227348.003934]  [<ffffffff81086790>] ? wake_bit_function+0x0/0x40
[1227348.003939]  [<ffffffffa00a6611>] __rpc_execute+0x191/0x2a0 [sunrpc]
[1227348.003945]  [<ffffffffa00a6746>] rpc_execute+0x26/0x30 [sunrpc]
[1227348.003949]  [<ffffffffa009eb2a>] rpc_run_task+0x3a/0x90 [sunrpc]
[1227348.003953]  [<ffffffffa009ec82>] rpc_call_sync+0x42/0x70 [sunrpc]
[1227348.003959]  [<ffffffffa013b33b>] T.976+0x4b/0x70 [nfs]
[1227348.003965]  [<ffffffffa013bd75>] nfs3_proc_access+0xd5/0x1a0 [nfs]
[1227348.003967]  [<ffffffff810fea8f>] ? free_hot_page+0x2f/0x60
[1227348.003969]  [<ffffffff8156bd6e>] ? _spin_lock+0xe/0x20
[1227348.003971]  [<ffffffff8115b626>] ? dput+0xd6/0x1a0
[1227348.003973]  [<ffffffff8115254f>] ? __follow_mount+0x6f/0xb0
[1227348.003978]  [<ffffffffa00a7fd4>] ? rpcauth_lookup_credcache+0x1a4/0x270 [sunrpc]
[1227348.003983]  [<ffffffffa0125817>] nfs_do_access+0x97/0xf0 [nfs]
[1227348.003989]  [<ffffffffa00a87f5>] ? generic_lookup_cred+0x15/0x20 [sunrpc]
[1227348.003994]  [<ffffffffa00a7910>] ? rpcauth_lookupcred+0x70/0xc0 [sunrpc]
[1227348.003996]  [<ffffffff8115254f>] ? __follow_mount+0x6f/0xb0
[1227348.004001]  [<ffffffffa0125915>] nfs_permission+0xa5/0x1e0 [nfs]
[1227348.004003]  [<ffffffff81153989>] __link_path_walk+0x99/0xf80
[1227348.004005]  [<ffffffff81154aea>] path_walk+0x6a/0xe0
[1227348.004007]  [<ffffffff81154cbb>] do_path_lookup+0x5b/0xa0
[1227348.004009]  [<ffffffff81148e3a>] ? get_empty_filp+0xaa/0x180
[1227348.004011]  [<ffffffff81155c63>] do_filp_open+0x103/0xba0
[1227348.004013]  [<ffffffff8156bd6e>] ? _spin_lock+0xe/0x20
[1227348.004015]  [<ffffffff812b8055>] ? _atomic_dec_and_lock+0x55/0x80
[1227348.004016]  [<ffffffff811618ea>] ? alloc_fd+0x10a/0x150
[1227348.004018]  [<ffffffff811454e9>] do_sys_open+0x69/0x170
[1227348.004020]  [<ffffffff81145630>] sys_open+0x20/0x30
[1227348.004022]  [<ffffffff81013172>] system_call_fastpath+0x16/0x1b
