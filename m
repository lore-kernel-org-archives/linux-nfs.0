From: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: Re: rpc.statd is not running but is required
Date: Mon, 2 May 2011 01:47:01 -0700 (PDT)
Message-ID: <558844.52844.qm@web111705.mail.gq1.yahoo.com>
References: <846668.33333.qm@web111707.mail.gq1.yahoo.com> <20110502183547.7e9f1295@notabene.brown>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs <linux-nfs@vger.kernel.org>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nm24.bullet.mail.sp2.yahoo.com ([98.139.91.94]:46711 "HELO
	nm24.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751873Ab1EBIrD convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2011 04:47:03 -0400
In-Reply-To: <20110502183547.7e9f1295-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>mount tried to run=A0 /usr/sbin/start-statd and it failed for some rea=
son.
>What is in /usr/sbin/start-statd ??
>What happens if you run it directly?
>What happens if you just run=A0 /usr/sbin/rpc.statd??
=A0
=A0
root@server:~# find /usr/ -name "start-statd"root@server:~#
I don't have it!!!
=A0
>How is that relevant?
> man 8 mount
>might help you.
=A0
I think the above problem is serious and "-o loop" may not help

// Naderan *Mahmood;


----- Original Message -----
=46rom: NeilBrown <neilb@suse.de>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Cc: nfs <linux-nfs@vger.kernel.org>
Sent: Monday, May 2, 2011 1:05 PM
Subject: Re: rpc.statd is not running but is required

On Mon, 2 May 2011 00:59:01 -0700 (PDT) Mahmood Naderan
<nt_mahmood@yahoo.com> wrote:

> Hi,
> I have setup NFS and I checked every thing with documents and manual.
> After the client boots up, it says:
> =A0
> =A0
> mount.nfs: rpc.statd is not running but is required for remote lockin=
g.
> mount.nfs: Either use '-o nolock' to keep locks local, or start statd=
=2E
> mountall: mount /opt [1000] terminated with status 32

mount tried to run=A0 /usr/sbin/start-statd and it failed for some reas=
on.
What is in /usr/sbin/start-statd ??
What happens if you run it directly?
What happens if you just run=A0 /usr/sbin/rpc.statd??

> =A0
> and I can not see the shared folder.
> my hosts.allow file contains:
> =A0
> =A0
> portmap: 192.168.1.0/255.255.255.0
> lockd: 192.168.1.0/255.255.255.0
> rqoutad: 192.168.1.0/255.255.255.0
> mountd: 192.168.1.0/255.255.255.0
> =A0
> =A0
> also /etc/exports contain:
> /opt=A0=A0=A0=A0=A0=A0=A0 192.168.1.0/255.255.255.0(rw,no_subtree_che=
ck,sync,no_root_squash)
> =A0
> =A0
> Any idea about that? What does '-o loop' mean?

How is that relevant?

man 8 mount

might help you.

NeilBrown


> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at=A0 http://vger.kernel.org/majordomo-info.html
