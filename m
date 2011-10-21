Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vx0-f174.google.com ([209.85.220.174]:64943 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752600Ab1JUOdR convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Oct 2011 10:33:17 -0400
Received: by vcge1 with SMTP id e1so3351029vcg.19
        for <linux-nfs@vger.kernel.org>; Fri, 21 Oct 2011 07:33:16 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20111021012327.612839b5@neminis.loos.site>
References: <20111021012327.612839b5@neminis.loos.site>
Date: Fri, 21 Oct 2011 10:33:16 -0400
Message-ID: <CAKnQG+d66Driv-D7fTeyh=MP4iNqpTzjXyFEiLE34E3YV2KG_g@mail.gmail.com>
Subject: Re: sec=krb5 mounts never return
From: Kevin Coffman <kwc@umich.edu>
To: Arno Schuring <aelschuring@hotmail.com>
Cc: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Oct 20, 2011 at 7:23 PM, Arno Schuring <aelschuring@hotmail.com> wrote:
> Hello list,
>
> tl;dr: mount calls with sec=krb5 never return. They appear to get
> stalled in the kernel on "svc: transport is dead". I need to know
> if this is a configuration issue, a kernel problem or a userland
> problem, and how it can be resolved.
>
>
> I've been running a succesful NFS4 setup at home for a year now, but
> incorporating krb5 security has so far proven fruitless. I believe the
> Kerberos side of the equation is no longer causing problems; it is used
> for user authentication too, and nfs security contexts seem to work
> properly. As said above, the mount request for any Kerberos mount gets
> halted somewhere in flight:
>
> # mount -vvv -t nfs4 -o sec=krb5 genie:/media /mnt
> mount: fstab path: "/etc/fstab"
> mount: mtab path:  "/etc/mtab"
> mount: lock path:  "/etc/mtab~"
> mount: temp path:  "/etc/mtab.tmp"
> mount: UID:        0
> mount: eUID:       0
> mount: spec:  "genie:/media"
> mount: node:  "/mnt"
> mount: types: "nfs4"
> mount: opts:  "sec=krb5"
> mount: external mount: argv[0] = "/sbin/mount.nfs4"
> mount: external mount: argv[1] = "genie:/media"
> mount: external mount: argv[2] = "/mnt"
> mount: external mount: argv[3] = "-v"
> mount: external mount: argv[4] = "-o"
> mount: external mount: argv[5] = "rw,sec=krb5"
> mount.nfs4: timeout set for Sun Oct 16 22:52:10 2011
> mount.nfs4: trying text-based options
> 'sec=krb5,addr=172.22.21.8,clientaddr=172.22.21.5'
>
> And there it just seems to hang (the timeout is ignored completely)
> until killed via signal or Ctrl-C. The same mount without sec=krb5
> completes without issue:
> # mount -v -t nfs4 genie:/media /mnt
> mount.nfs4: timeout set for Thu Oct 20 23:48:55 2011
> mount.nfs4: trying text-based options
> 'addr=172.22.21.8,clientaddr=172.22.21.8'
> genie:/media on /mnt type nfs4 (rw)
>
> The machine is running a fully updated Debian 6.0 (Squeeze). So far I
> have only tried with one other client (also Squeeze) with similar
> results. Relevant software versions: kernel 2.6.32 (armel) and
> nfs-utils 1.2.2.
>
>
> The only suggestion that Google has been able to give me was to verify
> that the rpcsec_gss_krb5 was loaded, and it is:
> $ lsmod|grep gss
> rpcsec_gss_krb5         9026  5
> auth_rpcgss            33334  4 rpcsec_gss_krb5,nfsd,nfs
> sunrpc                171216  21 [..]
>
> Reproducible with only these exports:
> # exportfs -v
> /srv/nfs  172.22.21.8(ro,wdelay,root_squash,no_subtree_check,fsid=0)
> /srv/nfs  gss/krb5(ro,wdelay,root_squash,no_subtree_check,fsid=0)
>
>
> I can provide a full rpc_debug/svc_debug log if required. I'm not
> attaching it now because it is somewhat large (well, 60k) and I'm not
> even sure that user issues are on-topic for this list. What looks
> suspicious to me is the following excerpt:
> [600472.772226] nfsd: connect from 172.22.21.8, port=46257
> [600472.772300] svc: svc_setup_socket created deda1a00 (inet df948900)
> [600473.431966] svc_recv: found XPT_CLOSE
> [600473.431982] svc: svc_delete_xprt(deda1a00)
> [600473.432114] svc: transport deda1a00 is dead, not enqueued
>
>
>
> I'd be grateful for any pointers,
> Arno
> (not subscribed, please keep me in CC)

You should be seeing syslog messages if not, but I'll ask anyway.
You've got rpc.gssd configured and running on the client, and if this
is a linux server, rpc.svcgssd configured and running on the server.
("Configured" more or less means you've got a keytab.)  If they are
running, what does their output look like?  (Perhaps using "-vvv" to
get detailed output.)

K.C.
