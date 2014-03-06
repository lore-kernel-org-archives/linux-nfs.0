Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f182.google.com ([209.85.213.182]:34511 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752811AbaCFTwj convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Mar 2014 14:52:39 -0500
Received: by mail-ig0-f182.google.com with SMTP id uy17so8159467igb.3
        for <linux-nfs@vger.kernel.org>; Thu, 06 Mar 2014 11:52:38 -0800 (PST)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.2 \(1874\))
Subject: Re: Optimal NFS mount options to safely allow interrupts and timeouts on newer kernels
From: Trond Myklebust <trond.myklebust@primarydata.com>
In-Reply-To: <2043391310.134091.1394135196565.JavaMail.zimbra@xes-inc.com>
Date: Thu, 6 Mar 2014 14:52:35 -0500
Cc: Jim Rees <rees@umich.edu>, bhawley@luminex.com, Brown Neil <neilb@suse.de>,
        linux-nfs-owner@vger.kernel.org, linux-nfs@vger.kernel.org
Message-Id: <76B038DA-3E86-4C46-BFB6-928BFB8202D8@primarydata.com>
References: <1696396609.119284.1394040541217.JavaMail.zimbra@xes-inc.com> <1709792528-1394084840-cardhu_decombobulator_blackberry.rim.net-1367662481-@b5.c4.bise6.blackberry> <764210708.28409.1394119821635.JavaMail.zimbra@xes-inc.com> <20140306162208.GA18207@umich.edu> <1094203678.52139.1394124222574.JavaMail.zimbra@xes-inc.com> <20140306173632.GA18545@umich.edu> <1397912955.101159.1394130906695.JavaMail.zimbra@xes-inc.com> <B454F556-9381-4DB7-B864-EC066DBEAC63@primarydata.com> <2043391310.134091.1394135196565.JavaMail.zimbra@xes-inc.com>
To: Andrew Martin <amartin@xes-inc.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 6, 2014, at 14:46, Andrew Martin <amartin@xes-inc.com> wrote:

>> From: "Trond Myklebust" <trond.myklebust@primarydata.com>
>> On Mar 6, 2014, at 13:35, Andrew Martin <amartin@xes-inc.com> wrote:
>> 
>>>> From: "Jim Rees" <rees@umich.edu>
>>>> Why would a bunch of blocked apaches cause high load and reboot?
>>> What I believe happens is the apache child processes go to serve
>>> these requests and then block in uninterruptable sleep. Thus, there
>>> are fewer and fewer child processes to handle new incoming requests.
>>> Eventually, apache would normally kill said children (e.g after a
>>> child handles a certain number of requests), but it cannot kill them
>>> because they are in uninterruptable sleep. As more and more incoming
>>> requests are queued (and fewer and fewer child processes are available
>>> to serve the requests), the load climbs.
>> 
>> Does ‘top’ support this theory? Presumably you should see a handful of
>> non-sleeping apache threads dominating the load when it happens.
> Yes, it looks like the root apache process is still running:
> root      1773  0.0  0.1 244176 16588 ?        Ss   Feb18   0:42 /usr/sbin/apache2 -k start
> 
> All of the others, the children (running as the www-data user), are marked as D.
> 
>> Why is the server becoming ‘unavailable’ in the first place? Are you taking
>> it down?
> I do not know the answer to this. A single NFS server has an export that is
> mounted on multiple servers, including this web server. The web server is
> running Ubuntu 10.04 LTS 2.6.32-57 with nfs-common 1.2.0. Intermittently, the
> NFS mountpoint will become inaccessible on this web server; processes that 
> attempt to access it will block in uninterruptable sleep. While this is 
> occurring, the NFS export is still accessible normally from other clients, 
> so it appears to be related to this particular machine (probably since it is 
> the last machine running Ubuntu 10.04 and not 12.04). I do not know if this 
> is a bug in 2.6.32 or another package on the system, but at this time I 
> cannot upgrade it to 12.04, so I need to find a solution on 10.04. 
> 
> I attempted to get a backtrace from one of the uninterruptable apache processes:
> echo w > /proc/sysrq-trigger
> 
> Here's one example:
> [1227348.003904] apache2       D 0000000000000000     0 10175   1773 0x00000004
> [1227348.003906]  ffff8802813178c8 0000000000000082 0000000000015e00 0000000000015e00
> [1227348.003908]  ffff8801d88f03d0 ffff880281317fd8 0000000000015e00 ffff8801d88f0000
> [1227348.003910]  0000000000015e00 ffff880281317fd8 0000000000015e00 ffff8801d88f03d0
> [1227348.003912] Call Trace:
> [1227348.003918]  [<ffffffffa00a5ca0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
> [1227348.003923]  [<ffffffffa00a5cc4>] rpc_wait_bit_killable+0x24/0x40 [sunrpc]
> [1227348.003925]  [<ffffffff8156a41f>] __wait_on_bit+0x5f/0x90
> [1227348.003930]  [<ffffffffa00a5ca0>] ? rpc_wait_bit_killable+0x0/0x40 [sunrpc]
> [1227348.003932]  [<ffffffff8156a4c8>] out_of_line_wait_on_bit+0x78/0x90
> [1227348.003934]  [<ffffffff81086790>] ? wake_bit_function+0x0/0x40
> [1227348.003939]  [<ffffffffa00a6611>] __rpc_execute+0x191/0x2a0 [sunrpc]
> [1227348.003945]  [<ffffffffa00a6746>] rpc_execute+0x26/0x30 [sunrpc]

That basically means that the process is hanging in the RPC layer, somewhere in the state machine. ‘echo 0 >/proc/sys/sunrpc/rpc_debug’ as the ‘root’ user should give us a dump of which state these RPC calls are in. Can you please try that?

_________________________________
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com

