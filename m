From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: can anyone explain this state?
Date: Wed, 17 Aug 2005 08:02:54 -0400
Message-ID: <1124280174.23245.4.camel@lade.trondhjem.org>
References: <bc57270905081704131c4b23d4@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1E5Mde-0006v4-OZ
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 05:03:22 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1E5Mde-0006I1-CH
	for nfs@lists.sourceforge.net; Wed, 17 Aug 2005 05:03:22 -0700
To: Michael <mikore.li@gmail.com>
In-Reply-To: <bc57270905081704131c4b23d4@mail.gmail.com>
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

on den 17.08.2005 Klokka 19:13 (+0800) skreiv Michael:
> Hi, 
> 
> These day, I observed a strange thing when I copy a 100MB file from
> nfs server, both client and server is running redhat 9.0 with kernel
> 2.4.20-8:
> 
> $ sudo mount -o
> rw,bg,vers=3,tcp,timeo=600,rsize=1024,wsize=1024,hard,intr,ac
> server1:/home/test filetest
> $ time cp ./filetest/new100m /tmp/o100m
> 
> real    1m6.575s
> user    0m0.040s
> sys     0m1.430s
> $ time cp ./filetest/new100m /tmp/o100m
> 
> real    0m4.964s     =================> it is so different comparing
> with above time!!
> user    0m0.030s
> sys     0m0.570s

This is done using synchronous writes. Each write will wait for the
server to commit it to disk.

> $ sudo umount filetest
> $ sudo mount -o
> rw,bg,vers=3,tcp,timeo=600,rsize=102400,wsize=102400,hard,intr,ac
> server1:/home/test filetest
> $ time cp ./filetest/new100m /tmp/o100m
> 
> real    0m9.075s
> user    0m0.020s
> sys     0m0.470s
> $ time cp ./filetest/new100m /tmp/o100m
> 
> real    0m7.501s    ==================>only different in 2 seconds!
> why not less than 4.9 seconds?
> user    0m0.000s
> sys     0m0.520s

This is done using asynchronous writes. Much faster, and no need (on
NFSv3) to wait for the disk before sending the next request.

The reason is that on 2.4 kernels (and early 2.6 kernels) we could only
do synchronous writes when you set wsize < PAGE_SIZE.

Cheers,
  Trond



-------------------------------------------------------
SF.Net email is Sponsored by the Better Software Conference & EXPO
September 19-22, 2005 * San Francisco, CA * Development Lifecycle Practices
Agile & Plan-Driven Development * Managing Projects & Teams * Testing & QA
Security * Process Improvement & Measurement * http://www.sqe.com/bsce5sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
