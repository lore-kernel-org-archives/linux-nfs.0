From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: async vs. sync
Date: Mon, 22 Nov 2004 17:20:42 -0500
Message-ID: <1101162043.11196.88.camel@lade.trondhjem.org>
References: <EXCHG20034NQhEP9w0z00007249@EXCHG2003.microtech-ks.com>
	 <41A25DCB.6020700@int-evry.fr>  <41A25FA3.6060000@int-evry.fr>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-FUYve4/QI2U91+kuoQqY"
Cc: Roger Heflin <rheflin@atipa.com>, Olaf Kirch <okir@suse.de>,
	nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1CWMYL-0000MQ-Vj
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 14:20:57 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1CWMYJ-00027X-Sa
	for nfs@lists.sourceforge.net; Mon, 22 Nov 2004 14:20:57 -0800
To: jehan procaccia <jehan.procaccia@int-evry.fr>
In-Reply-To: <41A25FA3.6060000@int-evry.fr>
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


--=-FUYve4/QI2U91+kuoQqY
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

m=E5 den 22.11.2004 Klokka 22:52 (+0100) skreiv jehan procaccia:
> > [root@arvouin tmp]# mount cobra3:/p2v5f1 -o=20
> > async,wsize=3D32768,rsize=3D32768,soft /mnt/cobra3
> > [root@arvouin /mnt/cobra3/mci/test/Test-sync]
> > $time tar xvfz /usr/src/redhat/SOURCES/httpd-2.0.51.tar.gz
> >
> > sorry I don't want to wait more than 10 minutes to send that mail, but=20
> > again seeing the files apperaing very slowly on the tty it seems not=20
> > to be the solution :-( .

The following script may help you understand why things are slower in
the case of "async" on an untar. It basically just creates a bunch of
files: in the first test it does not sync the directory to disk after
each file creation, in the second case it does. The test does no
reads/writes to the file.

Run it on the server and you will see  a clear difference in time
between test1 and test2. Run it on the client, and there should be
little difference between test1 and test2 (but there will be a heavy
dependency on the "async" vs "sync" export flag on the server).

NFSv3 mandates that all directory-related operations should behave as in
test 2. Only writes to ordinary files may be cached by the server, and
when the client sends a COMMIT request, the server should do an fsync()
on that file.

Cheers,
  Trond
--=20
Trond Myklebust <trond.myklebust@fys.uio.no>

--=-FUYve4/QI2U91+kuoQqY
Content-Disposition: inline; filename=script.sh
Content-Type: application/x-shellscript; name=script.sh
Content-Transfer-Encoding: 7bit

#!/bin/bash
#
test1()
{
	(
	rm -rf test_dir1
	mkdir test_dir1
	cd test_dir1
	i=0
	while [ $i -lt 1000 ]
	do
		echo -n "" >file$i
		i=$(($i + 1))
	done
	)
}

test2()
{
	(
	rm -rf test_dir2
	mkdir test_dir2
	cd test_dir2
	i=0
	while [ $i -lt 1000 ]
	do
		echo -n "" >file$i
		sync
		i=$(($i + 1))
	done
	)
}

sync
echo "Test without directory sync after file creation"
time test1
sync
echo "Test2 with directory sync after file creation"
time test2

--=-FUYve4/QI2U91+kuoQqY--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now. 
http://productguide.itmanagersjournal.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
