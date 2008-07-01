From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Massive NFS problems on large cluster with large number of
	mounts
Date: Tue, 1 Jul 2008 14:22:50 -0400
Message-ID: <20080701182250.GB21807@fieldses.org>
References: <4869E8AB.4060905@aei.mpg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-nfs@vger.kernel.org,
	Henning Fehrmann <henning.fehrmann-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>,
	Steffen Grunewald <steffen.grunewald-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
To: Carsten Aulbert <carsten.aulbert-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:50056 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752115AbYGASWv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Jul 2008 14:22:51 -0400
In-Reply-To: <4869E8AB.4060905-l1a6w7hxd2yELgA04lAiVw@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 01, 2008 at 10:19:55AM +0200, Carsten Aulbert wrote:
> Hi all (now to the right email list),
>=20
> We are running a large cluster and do a lot of cross-mounting between
> the nodes. To get this running we are running a lot of nfsd (196) and
> use mountd with 64 threads, just in case we get a massive number of h=
its
> onto a single node. All this is on Debian Etch with a recent 2.6.24
> kernel using autofs4 at the moment to do the automounts.

I'm slightly confused--the above is all about server configuration, but
the below seems to describe only client problems?

>=20
> When running these two not nice scripts:
>=20
> $ cat test_mount
> #!/bin/sh
>=20
> n_node=3D1000
>=20
> for i in `seq 1 $n_node`;do
>         n=3D`echo $RANDOM%1342+10001 | bc| sed -e "s/1/n/"`
>         $HOME/bin/mount.sh $n&
>         echo -n .
> done
>=20
> $ cat mount.sh
> #!/bin/sh
>=20
> dir=3D"/distributed/spray/data/EatH/S5R1"
>=20
> ping -c1 -w1 $1 > /dev/null&& file=3D"/atlas/node/$1$dir/"`ls -f
> /atlas/node/$1$dir/|head -n 50 | tail -n 1`
> md5sum ${file}
>=20
> With that we encounter different problems:
>=20
> Running this gives this in syslog:
> Jul  1 07:37:19 n1312 rpc.idmapd[2309]: nfsopen:
> open(/var/lib/nfs/rpc_pipefs/nfs/clntaa58/idmap): Too many open files
> Jul  1 07:37:19 n1312 rpc.idmapd[2309]: nfsopen:
> open(/var/lib/nfs/rpc_pipefs/nfs/clntaa58/idmap): Too many open files
> Jul  1 07:37:19 n1312 rpc.idmapd[2309]: nfsopen:
> open(/var/lib/nfs/rpc_pipefs/nfs/clntaa5e/idmap): Too many open files
> Jul  1 07:37:19 n1312 rpc.idmapd[2309]: nfsopen:
> open(/var/lib/nfs/rpc_pipefs/nfs/clntaa5e/idmap): Too many open files
> Jul  1 07:37:19 n1312 rpc.idmapd[2309]: nfsopen:
> open(/var/lib/nfs/rpc_pipefs/nfs/clntaa9c/idmap): Too many open files
>=20
> Which is not surprising to me. However, there are a few things I'm
> wondering about.
>=20
> (1) All our mounts use nfsvers=3D3 why is rpc.idmapd involved at all?

Are there actually files named "idmap" in those directories?  (Looks to
me like they're only created in the v4 case, so I assume those open
calls would return ENOENT if they didn't return ENFILE....)

> (2) Why is this daemon growing so extremely large?
> # ps aux|grep rpc.idmapd
> root      2309  0.1 16.2 2037152 1326944 ?     Ss   Jun30   1:24
> /usr/sbin/rpc.idmapd

I think rpc.idmapd has some state for each directory whether they're fo=
r
a v4 client or not, since it's using dnotify to watch for an "idmap"
file to appear in each one.  The above shows about 2k per mount?

--b.

> NOTE: We are now disabling this one, but still it wouldbe nice to
> understand why there seem to be a memory leak.
>=20
> (3) The script maxes out at about 340 concurrent mounts, any idea how=
 to
> increase this number? We are already running all servers with the
> insecure option, thus low ports should not be a restriction.
> (4) After running this script /etc/mtab and /proc/mounts are out of
> sync. Ian Kent from autofs fame suggested a broken local mount
> implementation which does not lock mtab well enough. Any idee about t=
hat?
>=20
> We are currently testing autofs5 and this is not giving these message=
s,
> but still we are not using high/unprivilidged ports.
>=20
> TIA for any help you might give us.
>=20
> Cheers
>=20
> Carsten
>=20
> --=20
> Dr. Carsten Aulbert - Max Planck Institut f=C3=BCr Gravitationsphysik
> Callinstra=C3=9Fe 38, 30167 Hannover, Germany
> Fon: +49 511 762 17185, Fax: +49 511 762 17193
> http://www.top500.org/system/9234 | http://www.top500.org/connfam/6/l=
ist/31
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" =
in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
