From: Guolin Cheng <guolin@alexa.com>
Subject: RE: processes stuck in D state
Date: Tue, 6 May 2003 11:32:46 -0700
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <0D122719B1756A43AD405320EE3D8EFA01278C4F@moneyb.alexa.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Cc: nfs@lists.sourceforge.net, neilb@cse.unsw.edu.au, Ops <ops@alexa.com>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.alexa.com ([209.247.255.131])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 19D7FH-00089N-00
	for <nfs@lists.sourceforge.net>; Tue, 06 May 2003 11:32:55 -0700
To: "'Lever, Charles'" <Charles.Lever@netapp.com>,
   Michael Buesch
	 <fsdeveloper@yahoo.de>, Andy Jewell <andy@alexa.com>,
   Jonathan Baker
	 <jonathan@alexa.com>, Paul Sauer <paul@alexa.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

Hi, all,

 We are encountering the same problem here as well,=20
=20
[root@arc100 root]# ps auxw
......
 andy      9087  0.0  3.2 12900 10312 ?       D    May05   0:02
/0/tmp/av_explore .index /net/arc295/0/DQ_crawl26.20030416034937.arc.gz
......

although the nfs server has no problem at all. If I try to "ls
/net/arc295/0" then the new "ls" process will hang as well.
The method I followed to fix the problem is:

[root@arc100 root]# umount -f /net/arc295/0
umount2: Device or resource busy
umount: /net/arc295/0: Illegal seek
[root@arc100 root]# /etc/init.d/amd restart
Stopping amd:                                              [  OK  ]
Starting amd:                                              [  OK  ]
[root@arc100 root]# cd /net/arc295/0
[root@arc100 0]# ls=20

 My nfs clients/servers has the same configurations:=20

	Redhat 8.0
 	General Linux Kernel 2.4.20 ("nfs over tcp" is enabled)
	gcc-3.2-7=20
 	amd ( am-utils-6.0.7-9 )
	amd mount options in map amd.master
(opts:=3Drw,intr,nfsv3,tcp,nosuid,nodev,noresvport)
      The real amd mount status for the nfs directory:
        arc295:/0 on /.amd_mnt/arc295/host/0 type nfs
(rw,intr,nfsv3,tcp,nosuid,nodev,noresvport,dev=3D0000f10e,vers=3D3,proto=
=3Dtcp)

 Any one need more info the shoot the sort of problem, let me know.

 Thanks.
 --Guolin Cheng


-----Original Message-----
From: Lever, Charles [mailto:Charles.Lever@netapp.com]
Sent: Tuesday, May 06, 2003 8:18 AM
To: Michael Buesch
Cc: nfs@lists.sourceforge.net; neilb@cse.unsw.edu.au
Subject: RE: [NFS] processes stuck in D state


hi michael-

i'm not sure why you mailed neilb -- this appears to
be NFS client related, not server related.

can you spell out the sequence of events that leads
to the stuck processes?  it looks like the client
is working-as-designed, but if you can provide more
details, we can verify what's going on.

> -----Original Message-----
> From: Michael Buesch [mailto:fsdeveloper@yahoo.de]
> Sent: Tuesday, May 06, 2003 10:52 AM
> To: neilb@cse.unsw.edu.au
> Cc: nfs@lists.sourceforge.net
> Subject: [NFS] processes stuck in D state
>=20
>=20
> -----BEGIN PGP SIGNED MESSAGE-----
> Hash: SHA1
>=20
> Hi!
>=20
> Please take a look at this problem:
>=20
> [linux-kernel-mailing-list thread]
> http://marc.theaimsgroup.com/?t=3D98639966100003&r=3D1&w=3D2
>=20
> thanks.
> Please cc me, as I'm not subscribed to the nfs-list.
>=20
> - --=20
> Regards Michael B=FCsch
> http://www.8ung.at/tuxsoft
>  16:28:34 up 20 min,  1 user,  load average: 1.07, 0.97, 0.66
> -----BEGIN PGP SIGNATURE-----
> Version: GnuPG v1.2.1 (GNU/Linux)
>=20
> iD8DBQE+t8wdoxoigfggmSgRAm5aAJsGJLPe9yUd4sqah4yiU0GsMIAGzACfSa2+
> gAMZvSHQirHmE8yZChpgH/8=3D
> =3Dpka2
> -----END PGP SIGNATURE-----
>=20
>=20
>=20
> -------------------------------------------------------
> Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
> The only event dedicated to issues related to Linux=20
> enterprise solutions
> www.enterpriselinuxforum.com
>=20
> _______________________________________________
> NFS maillist  -  NFS@lists.sourceforge.net
> https://lists.sourceforge.net/lists/listinfo/nfs
>=20


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise =
solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs


-------------------------------------------------------
Enterprise Linux Forum Conference & Expo, June 4-6, 2003, Santa Clara
The only event dedicated to issues related to Linux enterprise solutions
www.enterpriselinuxforum.com

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
