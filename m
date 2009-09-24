From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: NFS: nfsroot BUG() hit in latest -git
Date: Thu, 24 Sep 2009 09:58:43 -0400
Message-ID: <0A59A8E5-E9D6-4A46-BB30-AF779EE5A7D0@oracle.com>
References: <f861ec6f0909240049q69df95e5wba5260788931667c@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v936)
Content-Type: multipart/mixed; boundary=Apple-Mail-2-615616547
Cc: Linux-NFS <linux-nfs@vger.kernel.org>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: Manuel Lauss <manuel.lauss@googlemail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:31981 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751319AbZIXN6r (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 24 Sep 2009 09:58:47 -0400
In-Reply-To: <f861ec6f0909240049q69df95e5wba5260788931667c-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--Apple-Mail-2-615616547
Content-Type: text/plain;
	charset=US-ASCII;
	format=flowed;
	delsp=yes
Content-Transfer-Encoding: 7bit

On Sep 24, 2009, at 3:49 AM, Manuel Lauss wrote:
> Hi Chuck!
>
> I'm seeing kernel panics when mounting my NFSroot, caused
> by 9423a08ad5773d0a7612d434700561dc8346b6d6:
>
> root=/dev/nfs nfsroot=192.168.44.70:/mnt/work/mips-rootfs,v3,tcp
>
> Looking up port of RPC 100003/3 on 192.168.44.70
> eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
> Looking up port of RPC 100005/3 on 192.168.44.70
> Kernel bug detected[#1]:
> Cpu 0
> $ 0   : 00000000 10003c00 00000100 80510000
> $ 4   : 8d011c18 00000000 00000000 00000000
> $ 8   : 00000003 fffff000 00000001 00000000
> $12   : 66008c77 3b9aca00 00000003 00000000
> $16   : 8d011c18 8d1c2178 8d1c2004 8d1c236c
> $20   : 8d1c5514 8d1c5514 8d1c6000 8d1c5100
> $24   : 00000010 00000000
> $28   : 8d010000 8d011c00 00008001 801ec1c0
> Hi    : 00000000
> Lo    : 00000000
> epc   : 801ea174 nfs_init_timeout_values+0x10c/0x118
>    Not tainted
> ra    : 801ec1c0 nfs_create_server+0xf4/0x5b4
> Status: 10003c03    KERNEL EXL IE
> Cause : 00808024
> PrId  : 04030202 (Au1250)
> Modules linked in:
> Process swapper (pid: 1, threadinfo=8d010000, task=8d007408,  
> tls=00000000)
> Stack : 805303b0 00000000 805303b0 80510000 8d1b5034 8d1c5100  
> 00000000 80387d4c
>        8d1c5100 00000000 8d1c5100 8d1c5190 8d1c20e0 00000010  
> 80428a50 00000000
>        00000000 ffff8d77 8052ba48 8052ba4c 8052ba64 811a38a0  
> 00000000 80513830
>        80513830 10003c01 00000009 80181470 00000174 ffffffff  
> 00000004 811a38a0
>        0000000e 0000000e 000000d0 8d1c305c 8d1c20e0 8d1c5514  
> 8d1c6000 8d1c5100
>        ...
> Call Trace:
> [<801ea174>] nfs_init_timeout_values+0x10c/0x118
> [<801ec1c0>] nfs_create_server+0xf4/0x5b4
> [<801f7ab8>] nfs_get_sb+0x680/0x9b8
> [<801878a8>] vfs_kern_mount+0x68/0xd0
> [<80187974>] do_kern_mount+0x54/0x118
> [<8019f970>] do_mount+0x694/0x720
> [<8019fa90>] sys_mount+0x94/0xec
> [<80531b90>] do_mount_root+0x2c/0xc8
> [<80531f24>] mount_root+0x9c/0x148
> [<8053218c>] prepare_namespace+0x1bc/0x1f0
> [<80531388>] kernel_init+0x11c/0x13c
> [<8010f090>] kernel_thread_helper+0x10/0x18
>
> It's hitting the "BUG()" in fs/nfs/ 
> client.c::nfs_init_timeout_values().
> it does not show up if I remove the "v3,tcp" from nfsroot
> parameters, but then the whole userspace boot process takes ages.
>
> Any ideas?

Viro just reported a similar problem.  Maybe the attached patch fixes  
it?

>
> Thank you!
>        Manuel Lauss

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com


--Apple-Mail-2-615616547
Content-Disposition: attachment;
	filename="[PATCH] nfs[23] tcp breakage in mount with binary options.eml"
Content-Type: message/rfc822;
	x-mac-hide-extension=yes;
	x-unix-mode=0666;
	name="[PATCH] nfs[23] tcp breakage in mount with binary options.eml"
Content-Transfer-Encoding: 7bit

Received: from acsmt355.oracle.com (/141.146.40.155)
	by default (Oracle Beehive Gateway v4.0)
	with ESMTP ; Thu, 24 Sep 2009 06:37:15 -0700
Return-Path: <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>
Received: from rcsinet15.oracle.com by acsmt357.oracle.com
	with ESMTP id 19989921431253799433; Thu, 24 Sep 2009 08:37:13 -0500
Received: from rgminet11.oracle.com (rcsinet11.oracle.com [148.87.113.123])
	by rgminet15.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n8ODbCsw024279
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <chuck.lever@oracle.com>; Thu, 24 Sep 2009 13:37:13 GMT
Received: from ZenIV.linux.org.uk (zeniv.linux.org.uk [195.92.253.2])
	by rgminet11.oracle.com (Switch-3.3.1/Switch-3.3.1) with ESMTP id n8ODc18O028345
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <chuck.lever@oracle.com>; Thu, 24 Sep 2009 13:38:03 GMT
Received: from viro by ZenIV.linux.org.uk with local (Exim 4.69 #1 (Red Hat Linux))
	id 1MqoVL-00031P-UO; Thu, 24 Sep 2009 13:37:03 +0000
Date: Thu, 24 Sep 2009 14:37:03 +0100
From: Al Viro <viro@ZenIV.linux.org.uk>
To: Trond.Myklebust@netapp.com
Cc: linux-kernel@vger.kernel.org, Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] nfs[23] tcp breakage in mount with binary options
Message-ID: <20090924133703.GN14381@ZenIV.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
User-Agent: Mutt/1.5.18 (2008-05-17)
Sender: Al Viro <viro-rfM+Q5joDG/XmaaqVzeoHQ@public.gmane.org>
X-Source-IP: zeniv.linux.org.uk [195.92.253.2]
X-CT-RefId: str=0001.0A090208.4ABB7604.00FE:SCFMA543401,ss=1,fgs=0

We forget to set nfs_server.protocol in tcp case when old-style binary
options are passed to mount.  The thing remains zero and never validated
afterwards.  As the result, we hit BUG in fs/nfs/client.c:588.

Breakage has been introduced in NFS: Add nfs_alloc_parsed_mount_data
merged yesterday...

Signed-off-by: Al Viro <viro@zeniv.linux.org.uk>
---
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 810770f..29786d3 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1711,6 +1711,8 @@ static int nfs_validate_mount_data(void *options,
 
 		if (!(data->flags & NFS_MOUNT_TCP))
 			args->nfs_server.protocol = XPRT_TRANSPORT_UDP;
+		else
+			args->nfs_server.protocol = XPRT_TRANSPORT_TCP;
 		/* N.B. caller will free nfs_server.hostname in all cases */
 		args->nfs_server.hostname = kstrdup(data->hostname, GFP_KERNEL);
 		args->namlen		= data->namlen;

--Apple-Mail-2-615616547--
