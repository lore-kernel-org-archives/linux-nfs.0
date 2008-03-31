From: "Anirban Sinha" <ASinha-z4qIPS1Syiu/3pe1ocb+swC/G2K4zDHf@public.gmane.org>
Subject: nfsd restart failures without /proc/fs/nfsd filesystem mounted
Date: Mon, 31 Mar 2008 15:39:04 -0700
Message-ID: <DDFD17CC94A9BD49A82147DDF7D545C59D349C@exchange.ZeugmaSystems.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
To: <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.zeugmasystems.com ([192.139.122.66]:55361 "EHLO
	zeugmasystems.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752101AbYCaWkV convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 31 Mar 2008 18:40:21 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi:

I am using a system where we do not use the /proc/nfs/nfsd filesystem (=
due to several reasons). I understand that without this filesystem, nfs=
utils does not use the "new cache" mechanism. However, a nfsd restart o=
peration should still be functional. However, when I try doing this man=
ually, I get the following error:=20

root:my_node:/etc/rc.d/init.d# /sbin/service nfs restart
Shutting down NFS mountd:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 [=A0 OK=A0 ]
Shutting down NFS daemon:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 [FAILED]
Shutting down NFS services:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 [=A0 OK=A0 ]
Starting NFS services:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 [=A0 OK=A0 ]
Starting NFS daemon:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0[FAILED=
]
Starting NFS mountd:=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 [=A0 OK=
=A0 ]

And the kernel log says:
[13:37:37.766844] nfsd: Could not allocate memory read-ahead cache.

This issue is happening on an intel platform. However, this same operat=
ion succeeds on our mips platform (without nfsd filesystem). What is al=
so interesting is that once I turn on /proc/fs/nfsd filesystem on Intel=
, the issue seems to go away.

Several weeks back, I reported an issue regarding exportfs -a failure o=
n an already exported filesystem when nfsd FS was not used. It turned o=
ut to be a bug in the nfsutils. Did we bump into another bug here? Is t=
here no other option but to turn on nfsd filesystem?=20

Thanks for whoever responds to this ...

Cheers,

Ani



