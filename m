Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from chicago.messinet.com ([50.196.241.75]:43580 "EHLO
	chicago.messinet.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751710AbbCKB3w (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Mar 2015 21:29:52 -0400
Received: from localhost (localhost [127.0.0.1])
	by chicago.messinet.com (Postfix) with ESMTP id 56C5B67B4807
	for <linux-nfs@vger.kernel.org>; Tue, 10 Mar 2015 20:29:49 -0500 (CDT)
Received: from chicago.messinet.com ([127.0.0.1])
	by localhost (chicago.messinet.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id IHVS3x48NL3F for <linux-nfs@vger.kernel.org>;
	Tue, 10 Mar 2015 20:29:48 -0500 (CDT)
Received: from linux-ws1.messinet.com (unknown [IPv6:2001:55c:dc00:0:cf56:dd2e:206a:3ebf])
	(using TLSv1 with cipher ECDHE-RSA-AES128-SHA (128/128 bits))
	(Client did not present a certificate)
	by chicago.messinet.com (Postfix) with ESMTPSA id 3F57467B3DEC
	for <linux-nfs@vger.kernel.org>; Tue, 10 Mar 2015 20:29:48 -0500 (CDT)
From: Anthony Messina <amessina@messinet.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Kernel warning: net/sunrpc/clnt.c:2161 call_decode+0x269/0x8a0 [sunrpc]()
Date: Tue, 10 Mar 2015 20:29:49 -0500
Message-ID: <2905412.OH09VlPNMp@linux-ws1.messinet.com>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart1621954.XS1oHKu296"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


--nextPart1621954.XS1oHKu296
Content-Transfer-Encoding: quoted-printable
Content-Type: text/plain; charset="us-ascii"

While this may be unrelated, it is one of the errors that seems to occu=
r=20
around the same time as the issues detailed in "soft lockup in the laun=
dromat"=20
[1] and "NMI/soft lockup in nfs_delegation_need_return()" [2].  This is=
 on an=20
NFSv4.2/KRB5 client using kernel-3.18.9-200.fc21.x86_64 with the patch =
from=20
thread "[PATCH] NFS: fix clp->cl_revoked list deletion causing softlock=
 in=20
nfsd" applied at the Fedora kernel packaging level.

=2D-----------[ cut here ]------------
WARNING: CPU: 0 PID: 6545 at net/sunrpc/clnt.c:2161 call_decode+0x269/0=
x8a0=20
[sunrpc]()
Modules linked in: dm_crypt bnep bluetooth rfkill veth cts rpcsec_gss_k=
rb5=20
nfsv4 dns_resolver nfs fscache ip6t_rpfilter ip6t_REJECT nf_reject_ipv6=
=20
xt_conntrack ebtable_nat ebtable_broute bridge stp llc ebtable_filter e=
btables=20
ip6table_na
 shpchp i2c_i801 crc32c_intel serio_raw dcdbas ghash_clmulni_intel nfsd=
=20
auth_rpcgss nfs_acl lockd grace sunrpc uas usb_storage nouveau video mx=
m_wmi=20
broadcom wmi i2c_algo_bit drm_kms_helper ttm drm tg3 ptp pps_core
CPU: 0 PID: 6545 Comm: kworker/0:1 Not tainted 3.18.9-200.fc21.x86_64 #=
1
Hardware name: Dell Inc. XPS 8300  /0Y2MRG, BIOS A06 10/17/2011
Workqueue: rpciod rpc_async_schedule [sunrpc]
 0000000000000000 0000000089b51bad ffff88015d23fcc8 ffffffff8175b71c
 0000000000000000 0000000000000000 ffff88015d23fd08 ffffffff81098eb1
 0000000000000000 ffff8801572f1218 ffff880017369000 ffff8802060f1000
Call Trace:
 [<ffffffff8175b71c>] dump_stack+0x46/0x58
 [<ffffffff81098eb1>] warn_slowpath_common+0x81/0xa0
 [<ffffffffa0641810>] ? nfs4_xdr_dec_readdir+0xf0/0xf0 [nfsv4]
 [<ffffffff81098fca>] warn_slowpath_null+0x1a/0x20
 [<ffffffffa02810a9>] call_decode+0x269/0x8a0 [sunrpc]
 [<ffffffffa0280e40>] ? call_refreshresult+0x150/0x150 [sunrpc]
 [<ffffffffa0280e40>] ? call_refreshresult+0x150/0x150 [sunrpc]
 [<ffffffffa028b6e4>] __rpc_execute+0x94/0x450 [sunrpc]
 [<ffffffffa028bab5>] rpc_async_schedule+0x15/0x20 [sunrpc]
 [<ffffffff810b1a6d>] process_one_work+0x14d/0x3f0
 [<ffffffff810b23c3>] worker_thread+0x53/0x470
 [<ffffffff810b2370>] ? rescuer_thread+0x290/0x290
 [<ffffffff810b75b8>] kthread+0xd8/0xf0
 [<ffffffff810b74e0>] ? kthread_create_on_node+0x1b0/0x1b0
 [<ffffffff8176207c>] ret_from_fork+0x7c/0xb0
 [<ffffffff810b74e0>] ? kthread_create_on_node+0x1b0/0x1b0
=2D--[ end trace aa1a2fd825fce8b1 ]---


[1] http://www.spinics.net/lists/linux-nfs/msg49735.html
[2] http://www.spinics.net/lists/linux-nfs/msg47059.html
[3] http://www.spinics.net/lists/linux-nfs/msg49798.html


=2D-=20
Anthony - https://messinet.com/ - https://messinet.com/~amessina/galler=
y
8F89 5E72 8DF0 BCF0 10BE 9967 92DC 35DC B001 4A4E

--nextPart1621954.XS1oHKu296
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iEYEABECAAYFAlT/mo0ACgkQktw13LABSk4NoACgg0ZRlYmEsD499rtwrzjo5z4E
oNYAoMYJYmgCnj8VXQAOtyiG+lqF1EhP
=dgff
-----END PGP SIGNATURE-----

--nextPart1621954.XS1oHKu296--

