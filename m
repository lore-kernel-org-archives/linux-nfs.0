From: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: Re: rpc.statd is not running but is required
Date: Mon, 2 May 2011 03:46:13 -0700 (PDT)
Message-ID: <875966.44962.qm@web111717.mail.gq1.yahoo.com>
References: <846668.33333.qm@web111707.mail.gq1.yahoo.com> <20110502183547.7e9f1295@notabene.brown> <4DBE80CE.8070406@conversis.de> <830501.99174.qm@web111711.mail.gq1.yahoo.com> <20110502204200.41f71733@notabene.brown>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs <linux-nfs@vger.kernel.org>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nm2.bullet.mail.sp2.yahoo.com ([98.139.91.72]:33348 "HELO
	nm2.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757751Ab1EBKqO convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2011 06:46:14 -0400
In-Reply-To: <20110502204200.41f71733-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

>to start statd.  That should work unless NEED_STATD is set to 'no' in=20
>/etc/default/nfs-common.

mahmood@server:~$ cat /etc/default/nfs-common
# If you do not set values for the NEED_ options, they will be attempte=
d
# autodetected; this should be sufficient for most people. Valid altern=
atives
# for the NEED_ options are "yes" and "no".
# Do you want to start the statd daemon? It is not needed for NFSv4.
NEED_STATD=3D
# Options for rpc.statd.
#=A0=A0 Should rpc.statd listen on a specific port? This is especially =
useful
#=A0=A0 when you have a port-based firewall. To use a fixed port, set t=
his
#=A0=A0 this variable to a statd argument like: "--port 4000 --outgoing=
-port 4001".
#=A0=A0 For more information, see rpc.statd(8) or http://wiki.debian.or=
g/?SecuringNFS
STATDOPTS=3D
# Do you want to start the idmapd daemon? It is only needed for NFSv4.
NEED_IDMAPD=3D
# Do you want to start the gssd daemon? It is required for Kerberos mou=
nts.
NEED_GSSD=3D

Should I NEED_STATD to yes?

>What is in /etc/default/nfs-common??
>If you=20
>/etc/init.d/nfs-common restart
>does that start statd?

As I said, I have only nfs-kernel-server

mahmood@server:~$ ls /etc/init.d/nfs*
/etc/init.d/nfs-kernel-server

One more question? Can I install statd?
mahmood@server:~$ sudo apt-get install stat
stat        statcvs     statd       statgrab    statnews    statserial =
 statsvn

So you recommend that?

// Naderan *Mahmood;


----- Original Message -----
=46rom: NeilBrown <neilb@suse.de>
To: Mahmood Naderan <nt_mahmood@yahoo.com>
Cc: Dennis Jacobfeuerborn <dennisml@conversis.de>; nfs <linux-nfs@vger.=
kernel.org>
Sent: Monday, May 2, 2011 3:12 PM
Subject: Re: rpc.statd is not running but is required

On Mon, 2 May 2011 03:03:28 -0700 (PDT) Mahmood Naderan
<nt_mahmood@yahoo.com> wrote:

> I heve this service
> =A0
> mahmood@server:~$ sudo=A0 /etc/init.d/nfs-kernel-server restart
> =A0* Stopping NFS kernel daemon=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 [ OK ]
> =A0* Unexporting directories for NFS kernel daemon...=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 [ OK ]
> =A0* Exporting directories for NFS kernel daemon...=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 [=
 OK ]
> =A0* Starting NFS kernel daemon=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 [ OK ]
>=20
> =A0
> I use debian based linux. Is that what you meant?

(sorry - clicked wrong button before.

Yes, it seems Debian doesn't supply start-statd.=A0 I wonder why.

They rely on
=A0 =A0 /etc/init.d/nfs-common start

to start statd.=A0 That should work unless NEED_STATD is set to 'no' in=
=20
/etc/default/nfs-common.

What is in /etc/default/nfs-common??
If you=20
=A0  /etc/init.d/nfs-common restart

does that start statd?

NeilBrown


>=20
> // Naderan *Mahmood;
>=20
>=20
> ----- Original Message -----
> From: Dennis Jacobfeuerborn <dennisml@conversis.de>
> To: NeilBrown <neilb@suse.de>
> Cc: Mahmood Naderan <nt_mahmood@yahoo.com>; nfs <linux-nfs-u79uwXL29TZNg+MwTxZMZA@public.gmane.org=
l.org>
> Sent: Monday, May 2, 2011 2:30 PM
> Subject: Re: rpc.statd is not running but is required
>=20
> On 05/02/2011 10:35 AM, NeilBrown wrote:
> > On Mon, 2 May 2011 00:59:01 -0700 (PDT) Mahmood Naderan
> > <nt_mahmood@yahoo.com>=A0 wrote:
> >
> >> Hi,
> >> I have setup NFS and I checked every thing with documents and manu=
al.
> >> After the client boots up, it says:
> >>
> >>
> >> mount.nfs: rpc.statd is not running but is required for remote loc=
king.
> >> mount.nfs: Either use '-o nolock' to keep locks local, or start st=
atd.
> >> mountall: mount /opt [1000] terminated with status 32
> >
> > mount tried to run=A0 /usr/sbin/start-statd and it failed for some =
reason.
> > What is in /usr/sbin/start-statd ??
> > What happens if you run it directly?
> > What happens if you just run=A0 /usr/sbin/rpc.statd??
> >
>=20
> Have you tried checking if the /etc/init.d/nfslock service is enabled=
 and=20
> running?
>=20
> Regards,
> =A0=A0 Dennis
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at=A0 http://vger.kernel.org/majordomo-info.html
