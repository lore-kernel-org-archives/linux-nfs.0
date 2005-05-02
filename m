From: Neil Horman <nhorman@redhat.com>
Subject: Re: The actimeo seems not work
Date: Mon, 2 May 2005 08:37:46 -0400
Message-ID: <20050502123746.GB3486@hmsendeavour.rdu.redhat.com>
References: <003001c54f04$a6fd2a80$6b00a8c0@hgichon>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DSaBJ-0004UC-TM
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 05:37:49 -0700
Received: from mx1.redhat.com ([66.187.233.31])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DSaBI-0006YL-8p
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 05:37:49 -0700
Received: from int-mx1.corp.redhat.com (int-mx1.corp.redhat.com [172.16.52.254])
	by mx1.redhat.com (8.12.11/8.12.11) with ESMTP id j42Cbli4013581
	for <nfs@lists.sourceforge.net>; Mon, 2 May 2005 08:37:47 -0400
Received: from hmsendeavour.rdu.redhat.com (hmsendeavour.rdu.redhat.com [172.16.57.156])
	by int-mx1.corp.redhat.com (8.11.6/8.11.6) with ESMTP id j42CblO03716
	for <nfs@lists.sourceforge.net>; Mon, 2 May 2005 08:37:47 -0400
Received: from hmsendeavour.rdu.redhat.com (localhost.localdomain [127.0.0.1])
	by hmsendeavour.rdu.redhat.com (8.13.1/8.13.1) with ESMTP id j42CbkM2003715
	for <nfs@lists.sourceforge.net>; Mon, 2 May 2005 08:37:46 -0400
To: nfs@lists.sourceforge.net
In-Reply-To: <003001c54f04$a6fd2a80$6b00a8c0@hgichon>
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

On Mon, May 02, 2005 at 07:49:43PM +0900, =EF=BF=BD=EF=BF=BD=EF=BF=BD=EF=BF=
=BD=C7=A5 wrote:
> hello list.
> I have some question how to work of  linux nfs client cache.
>=20
> I was proceeding two test.
> One is solaris 9 client with linux server.
> The other is linux client with linux server.
>=20
> Linux server and client kernel version is 2.4.27.
> nfs-util version is 1.0.4.
>=20
> [ mount option list ]
> Linux server export option is rw,async.
> Linux client mount optione is just actimeo=3D0.
> Another linux client mount option is  actimeo=3D100.
> Solaris9 mount option is soft,xattr,rw.
>=20
> [ linux client setting ]
> 192.168.1.212:/vol1 /mnt1 nfs rw,v3,rsize=3D8192,wsize=3D8192,acregmin=3D=
0,acregmax=3D0,acdirmin=3D0,acdirmax=3D0,hard,udp,lock,addr=3D192.168.1.2=
12 0 0
> 192.168.1.212:/vol1 /mnt nfs rw,v3,rsize=3D8192,wsize=3D8192,acregmin=3D=
100,acregmax=3D100,acdirmin=3D100,acdirmax=3D100,hard,udp,lock,addr=3D192=
.168.1.212 0 0
>=20
> [ Solaris 9 test ]
> 2 solaris 9 clients ----> linux server.=20
>=20
> After i touch a file on one solaris client, I type ls -al the file on t=
he other solaris client.
> And i found that the file attribute(mtime) was updated randomly.(0 sec =
~ 30sec)
> The solais9 client is my customer machine.
> My client want that the file attribute update interval is to 0 sec.
> So I recommand to check nfs mount option in solaris 9 ( actimeo, acregX=
XX...).
>=20
> [ linux client test ]
>=20
> Test procedure is same with solaris9.
> But, resut is not same.
> Linux client shows up-to-dated file attribute.
> As I know, linux nfs client default mount option is acregmin is 3.
> So i change the mount option to  actimeo=3D100.
> But result is not different.
> So I wonder that actimeo option is a available.
> i tried tcpdump.
>=20
You're probably seeing the close-to-open cache consistency mechanism work=
ing.
Every time a file is closed on a linux system (with no outstanding open f=
d's,
IIRC), a setattr transaction is sent to the server to update file metadat=
a.  On
every file open (if there are no already open fd's, IIRC), a getattr tran=
saction
is sent to the server to get the latest file metadata on the server.  Thi=
s is
probably why it seems that the attribute cache timeouts aren't working li=
ke you
would expect.  To get a clearer view of how they operate, moun the linux =
clients
using the nocto nfs mount option.  Of course, I wouldn't recommend doing =
this,
as it provides better consistency between nfs nodes, but it will make the=
 ac*
options work a little more like you might expect.

Regards
Neil


> when mount option is actimeo=3D0 ( in linux client)
> linux-client> ls -al /mnt/test.test=20
> linux-client>-rwxrwxrwx    1 root     root           12 Apr 29 16:59 /m=
nt/test.test
>=20
> linux-server tcpdump output
> -----------------------------------------------------------
> 18:51:52.561558 GRVC-C.4105878944 > 192.168.1.212.nfs: 120 access [|nfs=
] (DF)
> 18:51:52.561588 192.168.1.212.nfs > GRVC-C.4105878944: reply ok 120 acc=
ess c 0000 (DF)
> 18:51:52.561683 GRVC-C.4122656160 > 192.168.1.212.nfs: 132 getattr [|nf=
s] (DF)
> 18:51:52.561759 192.168.1.212.nfs > GRVC-C.4122656160: reply ok 112 get=
attr REG 100777 ids 0/0 [|nfs] (DF)
> -------------------------------------------------------------
>=20
> when mount option is actimeo=3D100 ( in linux client)
> linux-client> ls -al /mnt1/test.test=20
> linux-client>-rwxrwxrwx    1 root     root           12 Apr 29 16:59 /m=
nt/test.test
>=20
> linux-server tcpdump output
> -------------------------------------------------------------
> 18:55:37.860627 GRVC-C.4189765024 > 192.168.1.212.nfs: 120 access [|nfs=
] (DF)
> 18:55:37.860694 192.168.1.212.nfs > GRVC-C.4189765024: reply ok 120 acc=
ess c 0000 (DF)
> 18:55:37.860874 GRVC-C.4206542240 > 192.168.1.212.nfs: 116 getattr [|nf=
s] (DF)
> 18:55:37.860932 192.168.1.212.nfs > GRVC-C.4206542240: reply ok 112 get=
attr DIR 40777 ids 99/99 [|nfs] (DF)
> 18:55:37.861123 GRVC-C.4223319456 > 192.168.1.212.nfs: 132 getattr [|nf=
s] (DF)
> 18:55:37.861147 192.168.1.212.nfs > GRVC-C.4223319456: reply ok 112 get=
attr REG 100777 ids 0/0 [|nfs] (DF)
> 18:55:37.861373 GRVC-C.4240096672 > 192.168.1.212.nfs: 132 getattr [|nf=
s] (DF)
> 18:55:37.861387 192.168.1.212.nfs > GRVC-C.4240096672: reply ok 112 get=
attr REG 100777 ids 0/0 [|nfs] (DF)
> -------------------------------------------------------------
>=20
> As you see, two more getattr appeared in actimeo=3D100.
>=20
> linux nfs client code seems different by actimeo option.
> but I can't verify the affect of nfs client cache . ( aspect of file at=
tribute cacheing)
>=20
> anybody help me?
> How can i verify the affect of nfs client cache.
> sorry poor my english.
--=20
/***************************************************
 *Neil Horman
 *Software Engineer
 *Red Hat, Inc.
 *nhorman@redhat.com
 *gpg keyid: 1024D / 0x92A74FA1
 *http://pgp.mit.edu
 ***************************************************/


-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
