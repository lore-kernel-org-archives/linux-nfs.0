From: Mahmood Naderan <nt_mahmood@yahoo.com>
Subject: Re: rpc.statd is not running but is required
Date: Mon, 2 May 2011 04:16:06 -0700 (PDT)
Message-ID: <943072.59877.qm@web111704.mail.gq1.yahoo.com>
References: <846668.33333.qm@web111707.mail.gq1.yahoo.com> <20110502183547.7e9f1295@notabene.brown> <4DBE80CE.8070406@conversis.de> <830501.99174.qm@web111711.mail.gq1.yahoo.com> <20110502204200.41f71733@notabene.brown>
Reply-To: Mahmood Naderan <nt_mahmood@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Cc: nfs <linux-nfs@vger.kernel.org>
To: NeilBrown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from nm30-vm0.bullet.mail.sp2.yahoo.com ([98.139.91.238]:44425 "HELO
	nm30-vm0.bullet.mail.sp2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753360Ab1EBLQH convert rfc822-to-8bit
	(ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 2 May 2011 07:16:07 -0400
In-Reply-To: <20110502204200.41f71733-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Sorry but I found another thing that may point to problem
In the server log I see=20
mountd[5744]: authenticated mount request from 192.168.1.3:866 for /hom=
e/nfsroot (/home/nfsroot)

192.168.1.3 is the client and /home/nfsroot is the place that clients b=
oots from there (an image is installed so the client boots from there)

Does that mean the permission is denied for client? How can I fix that?

Appreciate your help and comments.

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
