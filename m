From: jehan procaccia <jehan.procaccia@int-evry.fr>
Subject: Re: async vs. sync
Date: Mon, 22 Nov 2004 23:57:53 +0100
Message-ID: <41A26EF1.8040404@int-evry.fr>
References: <EXCHG20034NQhEP9w0z00007249@EXCHG2003.microtech-ks.com>	 <41A25DCB.6020700@int-evry.fr>  <41A25FA3.6060000@int-evry.fr> <1101162043.11196.88.camel@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: Roger Heflin <rheflin@atipa.com>, Olaf Kirch <okir@suse.de>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWN8B-0005YY-QN
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 14:57:59 -0800
Received: from smtp2.int-evry.fr ([157.159.10.45])
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CWN89-0007Ti-W4
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 14:57:59 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
In-Reply-To: <1101162043.11196.88.camel@lade.trondhjem.org>
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

Trond Myklebust wrote:

>m=E5 den 22.11.2004 Klokka 22:52 (+0100) skreiv jehan procaccia:
> =20
>
>>>[root@arvouin tmp]# mount cobra3:/p2v5f1 -o=20
>>>async,wsize=3D32768,rsize=3D32768,soft /mnt/cobra3
>>>[root@arvouin /mnt/cobra3/mci/test/Test-sync]
>>>$time tar xvfz /usr/src/redhat/SOURCES/httpd-2.0.51.tar.gz
>>>
>>>sorry I don't want to wait more than 10 minutes to send that mail, but=
=20
>>>again seeing the files apperaing very slowly on the tty it seems not=20
>>>to be the solution :-( .
>>>     =20
>>>
>
>The following script may help you understand why things are slower in
>the case of "async" on an untar. It basically just creates a bunch of
>files: in the first test it does not sync the directory to disk after
>each file creation, in the second case it does. The test does no
>reads/writes to the file.
>
>Run it on the server and you will see  a clear difference in time
>between test1 and test2. Run it on the client, and there should be
>little difference between test1 and test2 (but there will be a heavy
>dependency on the "async" vs "sync" export flag on the server).
> =20
>
These prediction are perfect, this is exaclty  what happened:
I reduce the loop from 1000 to 100, it was too long on the client in=20
sync mode ....

[root@cobra3 /p2v5f1/mci/test/Test-sync]
$ ./test2.sh
Test without directory sync after file creation

real    0m0.037s
user    0m0.010s
sys     0m0.000s
Test2 with directory sync after file creation

real    0m6.040s
user    0m0.000s
sys     0m0.000s

NFS client, while server export in sync mode
cobra3:/p2v5f1 /mnt/cobra3 nfs=20
rw,v3,rsize=3D8192,wsize=3D8192,soft,tcp,lock,addr=3Dcobra3 0 0
$./test2.sh
Test without directory sync after file creation

real    0m31.144s
user    0m0.042s
sys     0m0.373s
Test2 with directory sync after file creation

real    0m49.030s
user    0m0.073s
sys     0m0.694s

Now NFS server exports in async mode to the client, performances are far=20
better , even better than direclty on the server when forcing a sync=20
call after every creation !
$./test2.sh
Test without directory sync after file creation

real    0m0.446s
user    0m0.026s
sys     0m0.078s
Test2 with directory sync after file creation

real    0m0.785s
user    0m0.076s
sys     0m0.305s

Hopefully I'll try to capture traffic next wednesday when I'll be back=20
at work ..

Thanks.

>NFSv3 mandates that all directory-related operations should behave as in
>test 2. Only writes to ordinary files may be cached by the server, and
>when the client sends a COMMIT request, the server should do an fsync()
>on that file.
>
>Cheers,
>  Trond
> =20
>



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
