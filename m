From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: The actimeo seems not work
Date: Mon, 02 May 2005 09:02:05 -0400
Message-ID: <1115038925.10853.10.camel@lade.trondhjem.org>
References: <003001c54f04$a6fd2a80$6b00a8c0@hgichon>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DSaZ3-0005NB-2C
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 06:02:21 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DSaZ2-0000Rt-HN
	for nfs@lists.sourceforge.net; Mon, 02 May 2005 06:02:20 -0700
To: =?UTF-8?Q?=EA=B9=80=EA=B2=BD?= =?UTF-8?Q?=ED=91=9C?= <kpkim@gluesys.com>
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

m=C3=A5 den 02.05.2005 Klokka 19:49 (+0900) skreiv =EA=B9=80=EA=B2=BD=ED=91=
=9C:
> =20
> when mount option is actimeo=3D0 ( in linux client)
> linux-client> ls -al /mnt/test.test=20
> linux-client>-rwxrwxrwx    1 root     root           12 Apr 29
> 16:59 /mnt/test.test
> =20
> linux-server tcpdump output
> -----------------------------------------------------------
> 18:51:52.561558 GRVC-C.4105878944 > 192.168.1.212.nfs: 120 access [|
> nfs] (DF)
> 18:51:52.561588 192.168.1.212.nfs > GRVC-C.4105878944: reply ok 120
> access c 0000 (DF)
> 18:51:52.561683 GRVC-C.4122656160 > 192.168.1.212.nfs: 132 getattr [|
> nfs] (DF)
> 18:51:52.561759 192.168.1.212.nfs > GRVC-C.4122656160: reply ok 112
> getattr REG 100777 ids 0/0 [|nfs] (DF)
> -------------------------------------------------------------


ACCESS caching in the 2.4. kernels was very experimental (in fact the
ACCESS patch was never applied to the mainline kernel) and could explain
why this is happening.

Cheers,
  Trond



-------------------------------------------------------
This SF.Net email is sponsored by: NEC IT Guy Games.
Get your fingers limbered up and give it your best shot. 4 great events, 4
opportunities to win big! Highest score wins.NEC IT Guy Games. Play to
win an NEC 61 plasma display. Visit http://www.necitguy.com/?r=20
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
