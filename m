From: Vincent Roqueta <vincent.roqueta@ext.bull.net>
Subject: Re: NFS blocked
Date: Wed, 9 Feb 2005 12:12:03 +0100
Message-ID: <200502091212.03935.vincent.roqueta@ext.bull.net>
References: <4209E62D.5040203@zaide.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1Cypff-0002pv-MS
	for nfs@lists.sourceforge.net; Wed, 09 Feb 2005 03:06:11 -0800
Received: from ecfrec.frec.bull.fr ([129.183.4.8])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1Cypfc-0006bR-9u
	for nfs@lists.sourceforge.net; Wed, 09 Feb 2005 03:06:11 -0800
Received: from localhost (localhost [127.0.0.1])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id EE56419D907
	for <nfs@lists.sourceforge.net>; Wed,  9 Feb 2005 12:06:05 +0100 (CET)
Received: from ecfrec.frec.bull.fr ([127.0.0.1])
 by localhost (ecfrec.frec.bull.fr [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id 26570-01 for <nfs@lists.sourceforge.net>;
 Wed,  9 Feb 2005 12:06:03 +0100 (CET)
Received: from ecn002.frec.bull.fr (ecn002.frec.bull.fr [129.183.4.6])
	by ecfrec.frec.bull.fr (Postfix) with ESMTP id 5087E19D904
	for <nfs@lists.sourceforge.net>; Wed,  9 Feb 2005 12:06:03 +0100 (CET)
To: nfs@lists.sourceforge.net
In-Reply-To: <4209E62D.5040203@zaide.org>
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

Le mercredi 9 F=E9vrier 2005 11:30, Damien "zaide" a =E9crit=A0:
> I have a strange problem on my nfsv3 all work fine but when i try to cat
> a file inside a mounted nfs partition who work with apache's session i
> get this problem:
>
> $ strace cat /web/tmp/sess_231f9a00283f90be0ddd9a19e583f492
> execve("/bin/cat", ["cat",
> "/web/tmp/sess_231f9a00283f90be0ddd9a19e583f492"], [/* 18 vars */]) =3D 0
> ....
> open("/web/tmp/sess_231f9a00283f90be0ddd9a19e583f492",
> O_RDONLY|O_LARGEFILE) =3D 3
> fstat64(3, {st_mode=3DS_IFREG|0600, st_size=3D13, ...}) =3D 0
> read(3, "cmp|i:0;", 32768)         =3D 13
> write(1, "cmp|i:0;", 13cmp|i:0;)           =3D 13
> read(3, "", 32768)                      =3D 0
> brk(0)                                  =3D 0x8073000
> brk(0)                                  =3D 0x8073000
> brk(0x8072000)                          =3D 0x8072000
> brk(0)                                  =3D 0x8072000
> close(3
>
> and that all, it is blocked to the close() function.
>
> my process:
> test-cl   8678  0.0  0.0  1724  564 pts/4    S+   10:52   0:00 strace
> cat /web/tmp/sess_231f9a00283f90be0ddd9a19e583f492
> test-cl  19613  0.0  0.0  1824  432 pts/4    D+   10:52   0:00 cat
> /web/tmp/sess_231f9a00283f90be0ddd9a19e583f492
>
> my mounted partitions:
> nfsserver:/data1/web/tmp on /web/tmp type nfs
> (rw,noexec,nosuid,addr=3D172.16.8.100)
>
> and in my log:
> Feb  9 11:24:35 nfs-client kernel: lockd: server 172.16.8.100 not
> responding, still trying
>
> that all i have, so do you have any solutions, do you have allready seen
> this?

Yes,  I am working on a similar problem

=2D What is the kernel (uname -a) on the client? On the server ?=20
=2D Are rpc.lockd and rpc.statd running
=2D Can you do a tcpdump while the cat is blocked?


Vincent=20


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
