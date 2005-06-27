From: =?iso-8859-1?Q?Peter_=C5strand?= <astrand@cendio.se>
Subject: Re: Problems getting NFS over SSH to work
Date: Mon, 27 Jun 2005 18:44:23 +0200 (CEST)
Message-ID: <Pine.LNX.4.61.0506271821200.11518@maggie.lkpg.cendio.se>
References: <429CDB09.1060301@zgod.cjb.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="789237761-638667899-1119889281=:11518"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Dmwiq-0007xj-Sd
	for nfs@lists.sourceforge.net; Mon, 27 Jun 2005 09:44:36 -0700
Received: from mail.cendio.se ([193.12.253.69])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Dmwio-0001O7-S1
	for nfs@lists.sourceforge.net; Mon, 27 Jun 2005 09:44:36 -0700
To: Julius Schwartzenberg <julius@zgod.cjb.net>
In-Reply-To: <429CDB09.1060301@zgod.cjb.net>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--789237761-638667899-1119889281=:11518
Content-Type: TEXT/PLAIN; CHARSET=iso-8859-1; FORMAT=flowed
Content-ID: <Pine.LNX.4.61.0506271822181.11719@maggie.lkpg.cendio.se>
Content-Transfer-Encoding: quoted-printable

On Tue, 31 May 2005, Julius Schwartzenberg wrote:

> 'overtake' another computer by spoofing it's MAC address. Since I would=
=20
> like to access the server easily from my workstation, I thought NFS ove=
r=20
> SSH would be a good solution. The server uses Slackware 10.1, the=20
> workstation uses Slackware 10.0 with some updates including kernel=20
> 2.6.9. I installed UNFS3 version 0.9.12 on the server and I followed th=
e=20
> exact instructions from the NFS how-to on how to set up the tunnel over=
=20
> SSH.

UNFS3 is a good choice. However, the section about SSH tunneling in the=20
NFS Howto is wrong in several ways. Also, it assumes that you are using=20
the knfsd implementation.


> When I run the mount command on my client, I get the following error=20
> message though: mount: RPC: Cannot receive; errno =3D Connection refuse=
d=20
> (translated from dutch)

It would help if you posted the exact unfsd and ssh command lines. For me=
,=20
this works:

1. Create an exports file on the remote machine. I'll use=20
/home/peter/exports, with:

/home/peter 127.0.0.1(rw,password=3Dmysecret)


2. On the client, run:

ssh -L 12049:localhost:12049 peter@ourserver unfsd -d -e /home/peter/expo=
rts -n 12049 -m 12049 -p -s -l 127.0.0.1


3. On the client, as root, run:

mount -o port=3D12049,mountport=3D12049,mountvers=3D3,nfsvers=3D3,nolock,=
fg,soft,intr,tcp localhost:@password:mysecret/home/peter /mnt


The examples above assumes that port 12049 are free both on the server=20
and the client.

If you have multiple users on the client machine, the password will be=20
visible in the "mount" output. You can use one time passwords to prevent=20
this. See the unfs3 documentation.

I've been thinking about writing some wrapper scripts that simplifies all=
=20
this. NFSv3 over SSH actually works quite nice.

--=20
Peter =C5strand		Chief Developer
Cendio			www.thinlinc.com
Teknikringen 3		www.cendio.se
583 30 Link=F6ping        Phone: +46-13-21 46 00
--789237761-638667899-1119889281=:11518--


-------------------------------------------------------
SF.Net email is sponsored by: Discover Easy Linux Migration Strategies
from IBM. Find simple to follow Roadmaps, straightforward articles,
informative Webcasts and more! Get everything you need to get up to
speed, fast. http://ads.osdn.com/?ad_id=7477&alloc_id=16492&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
