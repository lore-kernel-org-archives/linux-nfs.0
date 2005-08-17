From: Michael <mikore.li@gmail.com>
Subject: can anyone explain this state?
Date: Wed, 17 Aug 2005 19:13:42 +0800
Message-ID: <bc57270905081704131c4b23d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E5Lrj-00055M-Lj
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 04:13:51 -0700
Received: from wproxy.gmail.com ([64.233.184.192])
	by mail.sourceforge.net with esmtp (Exim 4.44)
	id 1E5Lri-0002LN-BJ
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 04:13:51 -0700
Received: by wproxy.gmail.com with SMTP id i3so118602wra
        for <nfs@lists.sourceforge.net>; Wed, 17 Aug 2005 04:13:44 -0700 (PDT)
To: nfs@lists.sourceforge.net
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

Hi,=20

These day, I observed a strange thing when I copy a 100MB file from
nfs server, both client and server is running redhat 9.0 with kernel
2.4.20-8:

$ sudo mount -o
rw,bg,vers=3D3,tcp,timeo=3D600,rsize=3D1024,wsize=3D1024,hard,intr,ac
server1:/home/test filetest
$ time cp ./filetest/new100m /tmp/o100m

real    1m6.575s
user    0m0.040s
sys     0m1.430s
$ time cp ./filetest/new100m /tmp/o100m

real    0m4.964s     =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D> i=
t is so different comparing
with above time!!
user    0m0.030s
sys     0m0.570s
$ sudo umount filetest
$ sudo mount -o
rw,bg,vers=3D3,tcp,timeo=3D600,rsize=3D102400,wsize=3D102400,hard,intr,ac
server1:/home/test filetest
$ time cp ./filetest/new100m /tmp/o100m

real    0m9.075s
user    0m0.020s
sys     0m0.470s
$ time cp ./filetest/new100m /tmp/o100m

real    0m7.501s    =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D>=
only different in 2 seconds!
why not less than 4.9 seconds?
user    0m0.000s
sys     0m0.520s

Thanks!


-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
