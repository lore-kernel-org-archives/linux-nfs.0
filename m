Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp-1.concepts.nl ([213.197.30.124]:49127 "EHLO
	smtp-1.concepts.nl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751341Ab1JTXjO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Oct 2011 19:39:14 -0400
Received: from d594e6a3.dsl.concepts.nl ([213.148.230.163] helo=gnome.loos.site)
	by smtp-1.concepts.nl with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.72)
	(envelope-from <aelschuring@hotmail.com>)
	id 1RH1xX-0000xR-H5
	for linux-nfs@vger.kernel.org; Fri, 21 Oct 2011 01:23:35 +0200
Received: from [172.22.21.203] (helo=neminis.loos.site)
	by gnome.loos.site with esmtp (Exim 4.72)
	(envelope-from <aelschuring@hotmail.com>)
	id 1RH1xR-0000j2-7A
	for linux-nfs@vger.kernel.org; Fri, 21 Oct 2011 01:23:29 +0200
Date: Fri, 21 Oct 2011 01:23:27 +0200
From: Arno Schuring <aelschuring@hotmail.com>
To: linux-nfs@vger.kernel.org
Subject: sec=krb5 mounts never return
Message-ID: <20111021012327.612839b5@neminis.loos.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello list,

tl;dr: mount calls with sec=krb5 never return. They appear to get
stalled in the kernel on "svc: transport is dead". I need to know
if this is a configuration issue, a kernel problem or a userland
problem, and how it can be resolved.


I've been running a succesful NFS4 setup at home for a year now, but
incorporating krb5 security has so far proven fruitless. I believe the
Kerberos side of the equation is no longer causing problems; it is used
for user authentication too, and nfs security contexts seem to work
properly. As said above, the mount request for any Kerberos mount gets
halted somewhere in flight:

# mount -vvv -t nfs4 -o sec=krb5 genie:/media /mnt
mount: fstab path: "/etc/fstab"
mount: mtab path:  "/etc/mtab"
mount: lock path:  "/etc/mtab~"
mount: temp path:  "/etc/mtab.tmp"
mount: UID:        0
mount: eUID:       0
mount: spec:  "genie:/media"
mount: node:  "/mnt"
mount: types: "nfs4"
mount: opts:  "sec=krb5"
mount: external mount: argv[0] = "/sbin/mount.nfs4"
mount: external mount: argv[1] = "genie:/media"
mount: external mount: argv[2] = "/mnt"
mount: external mount: argv[3] = "-v"
mount: external mount: argv[4] = "-o"
mount: external mount: argv[5] = "rw,sec=krb5"
mount.nfs4: timeout set for Sun Oct 16 22:52:10 2011
mount.nfs4: trying text-based options
'sec=krb5,addr=172.22.21.8,clientaddr=172.22.21.5'

And there it just seems to hang (the timeout is ignored completely)
until killed via signal or Ctrl-C. The same mount without sec=krb5
completes without issue:
# mount -v -t nfs4 genie:/media /mnt
mount.nfs4: timeout set for Thu Oct 20 23:48:55 2011
mount.nfs4: trying text-based options
'addr=172.22.21.8,clientaddr=172.22.21.8'
genie:/media on /mnt type nfs4 (rw)

The machine is running a fully updated Debian 6.0 (Squeeze). So far I
have only tried with one other client (also Squeeze) with similar
results. Relevant software versions: kernel 2.6.32 (armel) and
nfs-utils 1.2.2.


The only suggestion that Google has been able to give me was to verify
that the rpcsec_gss_krb5 was loaded, and it is:
$ lsmod|grep gss
rpcsec_gss_krb5         9026  5 
auth_rpcgss            33334  4 rpcsec_gss_krb5,nfsd,nfs
sunrpc                171216  21 [..]

Reproducible with only these exports:
# exportfs -v
/srv/nfs  172.22.21.8(ro,wdelay,root_squash,no_subtree_check,fsid=0)
/srv/nfs  gss/krb5(ro,wdelay,root_squash,no_subtree_check,fsid=0)


I can provide a full rpc_debug/svc_debug log if required. I'm not
attaching it now because it is somewhat large (well, 60k) and I'm not
even sure that user issues are on-topic for this list. What looks
suspicious to me is the following excerpt:
[600472.772226] nfsd: connect from 172.22.21.8, port=46257
[600472.772300] svc: svc_setup_socket created deda1a00 (inet df948900)
[600473.431966] svc_recv: found XPT_CLOSE
[600473.431982] svc: svc_delete_xprt(deda1a00)
[600473.432114] svc: transport deda1a00 is dead, not enqueued



I'd be grateful for any pointers,
Arno
(not subscribed, please keep me in CC)
