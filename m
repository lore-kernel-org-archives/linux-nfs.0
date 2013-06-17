Return-Path: linux-nfs-owner@vger.kernel.org
Received: from userp1040.oracle.com ([156.151.31.81]:16665 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752483Ab3FQOXR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Jun 2013 10:23:17 -0400
Content-Type: text/plain; charset=US-ASCII
Mime-Version: 1.0 (Mac OS X Mail 6.5 \(1508\))
Subject: Re: Can't mount NFSv4 with kerberos on Debian Wheezy
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <51BC9892.6050509@gmail.com>
Date: Mon, 17 Jun 2013 10:23:10 -0400
Cc: linux-nfs@vger.kernel.org
Message-Id: <2BEA0A42-284D-4C5C-95DF-B9C43C98A3AD@oracle.com>
References: <51BAAFFC.6060208@gmail.com> <51BAB0BC.1010303@gmail.com> <5A1575CF-0400-48CE-B18B-5B26C92D152A@oracle.com> <CAFYD6QXVKpLDS_cWiA2uasu+KXazcRuk-+BX39MdehSwiu35gw@mail.gmail.com> <871BEFF7-33F4-4B34-9887-D5388951987E@oracle.com> <51BC8740.8010000@gmail.com> <FD6F6C61-BF8B-4C9C-BCB5-E240203D3ACB@oracle.com> <51BC9624.80507@gmail.com> <36188287-B17A-468C-B8CE-CA55D3B99816@oracle.com> <51BC9892.6050509@gmail.com>
To: John Haiducek <jhaiduce@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 15, 2013, at 12:38 PM, John Haiducek <jhaiduce@gmail.com> wrote:

> On 06/15/2013 10:31 AM, Chuck Lever wrote:
>> On the client, "sudo rpcdebug -m nfs -s all" And try the mount. Look in /var/log/messages for output. Did you tell us what kernel release you are running on client and server? "uname -a" 
> 
> Ok, now in /var/log messages I have this:
> 
> Jun 15 09:13:21 tbm kernel: [307264.414216] NFSD: starting 90-second grace period
> Jun 15 09:23:34 tbm kernel: [307877.856060] nfs: server tbm.enterprise.local not responding, still trying
> Jun 15 09:29:35 tbm kernel: [308238.304057] nfs: server tbm.enterprise.local not responding, still trying
> Jun 15 10:33:27 tbm kernel: [312070.654766] NFS: nfs mount opts='addr=192.168.1.7,clientaddr=192.168.1.7'
> Jun 15 10:33:27 tbm kernel: [312070.654780] NFS:   parsing nfs mount option 'addr=192.168.1.7'
> Jun 15 10:33:27 tbm kernel: [312070.654795] NFS:   parsing nfs mount option 'clientaddr=192.168.1.7'
> Jun 15 10:33:27 tbm kernel: [312070.654807] NFS: MNTPATH: '/export/nfstest'
> Jun 15 10:33:27 tbm kernel: [312070.654810] --> nfs4_try_mount()
> Jun 15 10:33:27 tbm kernel: [312070.654822] --> nfs4_create_server()
> Jun 15 10:33:27 tbm kernel: [312070.654854] --> nfs4_init_server()
> Jun 15 10:33:27 tbm kernel: [312070.654857] --> nfs4_set_client()
> Jun 15 10:33:27 tbm kernel: [312070.654862] --> nfs_get_client(tbm,v4)
> Jun 15 10:33:27 tbm kernel: [312070.654867] --> nfs_get_client() = ffff88021bcd3c00 [share]
> Jun 15 10:33:27 tbm kernel: [312070.654872] <-- nfs4_set_client() = 0 [new ffff88021bcd3c00]
> Jun 15 10:33:27 tbm kernel: [312070.655071] <-- nfs4_init_server() = 0
> Jun 15 10:33:27 tbm kernel: [312070.655241] --> nfs4_get_rootfh()
> Jun 15 10:33:27 tbm kernel: [312070.655279] encode_compound: tag=
> Jun 15 10:33:44 tbm kernel: [312087.264052] encode_compound: tag=
> Jun 15 10:34:27 tbm kernel: [312130.784203] encode_compound: tag=
> Jun 15 10:34:27 tbm kernel: [312130.784290] encode_compound: tag=
> Jun 15 10:34:27 tbm kernel: [312130.784541] encode_compound: tag=
> Jun 15 10:34:27 tbm kernel: [312130.784587] encode_compound: tag=
> 
> 
> The first 3 lines are from a previous mount attempt before I ran the rpcdebug command.
> 
> Client and server are the same machine. uname -a prints this:
> 
> Linux tbm 3.2.0-4-amd64 #1 SMP Debian 3.2.41-2 x86_64 GNU/Linux

Is rpc.svcgssd running?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



