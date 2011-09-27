Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out4.smtp.messagingengine.com ([66.111.4.28]:46793 "EHLO
	out4.smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751835Ab1I0ARV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 26 Sep 2011 20:17:21 -0400
Received: from compute4.internal (compute4.nyi.mail.srv.osa [10.202.2.44])
	by gateway1.nyi.mail.srv.osa (Postfix) with ESMTP id 05F202971B
	for <linux-nfs@vger.kernel.org>; Mon, 26 Sep 2011 20:17:20 -0400 (EDT)
Message-Id: <1317082639.4908.140258148055849@webmail.messagingengine.com>
From: dchilton+linux-nfs@bestmail.us
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="us-ascii"
Subject: DomU boot NFSD "90-second grace period" is ~ 4-5 minutes, then finishes
 without problem.  How to debug/fix the extended wait?
Date: Mon, 26 Sep 2011 17:17:19 -0700
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

I'm booting a Xen DomU that connects to NFS4 mounts served up by the
Dom0. Fyi,

rpm -qa | egrep -i "^nfs|^kernel"
 nfs-kernel-server-1.2.3-11.16.1.x86_64
 nfsidmap-0.23-13.1.x86_64
 nfs-client-1.2.3-11.16.1.x86_64
 kernel-xen-2.6.37.6-0.7.1.x86_64

@ DomU launch, it gets to the NFSv4 'stuff',

	...
	[   11.533498] EXT4-fs (xvda1): mounted filesystem with ordered
	data mode. Opts: acl,user_xattr,barrier=1
	[   11.579889] EXT4-fs (xvdd): mounted filesystem with ordered
	data mode. Opts: acl,user_xattr,journal_checksum,barrier=1
	[   15.237650] microcode: Microcode Update Driver: v2.00-xen
	<tigran@aivazian.fsnet.co.uk>, Peter Oruba
	[   24.271451] RPC: Registered udp transport module.
	[   24.271469] RPC: Registered tcp transport module.
	[   24.271479] RPC: Registered tcp NFSv4.1 backchannel transport
	module.
	[   24.340308] FS-Cache: Loaded
	[   24.554720] Installing knfsd (copyright (C) 1996
	okir@monad.swb.de).
	[   24.555025] FS-Cache: Netfs 'nfs' registered for caching
	[   25.239401] NFSD: Using /var/lib/nfs/v4recovery as the NFSv4
	state recovery directory
	[   25.245234] NFSD: starting 90-second grace period

and simply, quietly sits there ~4-5 minutes.  Then, without any further
fanfare, the boot completes.

	Welcome to openSUSE 11.4 "Celadon" - Kernel 2.6.37.6-0.7-xen
	(xvc0).
	
	test login:

At this point the DomU is up.  All the NFS mounts are mounted.  Nothing
seems amiss.

Clearly, the 4-5 minute wait isn't normal.

I suspect that there's some sort of settling/locking issue, but I don't
know how to verify or debug the source of the problem.

Any pointers as to what to start looking at?

Thanks

DCh
