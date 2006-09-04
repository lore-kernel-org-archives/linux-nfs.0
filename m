From: Andre van Hoorn <andre.van.hoorn@informatik.uni-oldenburg.de>
Subject: SUNRPC: Lack of RPC record fragments
Date: Mon, 04 Sep 2006 19:16:39 +0200
Message-ID: <44FC5F77.9010708@informatik.uni-oldenburg.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-15"
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GKI4Z-0001UW-US
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 10:17:24 -0700
Received: from smtpsrv03.uni-oldenburg.de ([134.106.87.11]
	ident=[U2FsdGVkX1/+Kn7wsqLWucdG6rFNPA57BZ294U7BCb8=])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GKI4Z-0002Jb-Ky
	for nfs@lists.sourceforge.net; Mon, 04 Sep 2006 10:17:27 -0700
To: nfs@lists.sourceforge.net
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

Hi,


I'm communicating with the linux NFS kernel server via RPC using the
sunrpc implementation in glibc. On certain RPC record sizes, glibc
starts to use record fragmentation (whereas the sunrpc kernel client
doesn't) and the sunrpc linux kernel server implementation lacks the RPC
record "defragmentation" functionality as can be seen in
net/sunrpc/svcsock.c:

svsk->sk_reclen =3D ntohl(svsk->sk_reclen);
if (!(svsk->sk_reclen & 0x80000000)) {
  /* FIXME: technically, a record can be fragmented,
   *  and non-terminal fragments will not have the top
   *  bit set in the fragment length header.
   *  But apparently no known nfs clients send fragmented
   *  records. */
   printk(KERN_NOTICE "RPC: bad TCP reclen 0x%08lx (non-terminal)\n",
         (unsigned long) svsk->sk_reclen);
   goto err_delete;
}

Unfortunately, I didn't find a way to disable the use of fragmentation
in glibc. Is there an existing patch for the kernel to support
fragmented records?



Best regards,

Andr=E9
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org

iD8DBQFE/F92LKwmE5jzZmkRAtfUAJwPyFRgfav/y9RhW4/6Z8jzSbyz8QCfX7t4
UNcN9tSfjWlJPjiVVFEelHM=3D
=3DqnID
-----END PGP SIGNATURE-----

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easi=
er
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=3Dlnk&kid=3D120709&bid=3D263057&dat=3D1=
21642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
