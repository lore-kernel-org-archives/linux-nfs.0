From: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Subject: Re: pNFS timeouts
Date: Mon, 14 Jun 2010 17:05:42 +0200
Message-ID: <20100614150542.GD17703@ics.muni.cz>
References: <20100614085157.GS17703@ics.muni.cz>
 <4C163892.20201@panasas.com>
 <20100614142332.GB17703@ics.muni.cz>
 <4C1640DF.5070506@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from minas.ics.muni.cz ([147.251.4.40]:38154 "EHLO minas.ics.muni.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754301Ab0FNPFm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jun 2010 11:05:42 -0400
In-Reply-To: <4C1640DF.5070506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jun 14, 2010 at 10:46:55AM -0400, Benny Halevy wrote:
> > Jun 14 16:17:00 undomiel1 kernel: [187434.936507] nfs41_sequence_ca=
ll_done rpc_cred ffff88003d7a0300
> > Jun 14 16:17:00 undomiel1 kernel: [187434.936514] <-- nfs41_sequenc=
e_call_done
> > Jun 14 16:17:00 undomiel1 kernel: [187434.936522] nfs4_schedule_sta=
te_renewal: requeueing work. Lease period =3D 60
> > Jun 14 16:17:00 undomiel1 kernel: [187434.936530] --> nfs_put_clien=
t({2})
> > Jun 14 16:17:16 undomiel1 kernel: [187450.536014] nfs4_renew_state:=
 start
> > Jun 14 16:17:16 undomiel1 kernel: [187450.536045] nfs4_renew_state:=
 failed to call renewd. Reason: lease not expired
> > Jun 14 16:17:16 undomiel1 kernel: [187450.536056] nfs4_schedule_sta=
te_renewal: requeueing work. Lease period =3D 38
>=20
> This looks like a complaint but it's actually saying that the "failur=
e"
> is due to the fact that everything is OK (lease not expired)

the state renewal actually starts after 16 seconds after schedule start
renewal for some reason. The nfs_put_client actually starts the renewal=
?

> BTW, is this the same issue that Jiri reported?
> http://marc.info/?l=3Dlinux-nfs&m=3D127619696004097&w=3D2

Yes, but I didn't see any response to that, so I guess his report is no=
t clear
enough.

--=20
Luk=E1=B9 Hejtm=E1nek
