From: Paul Libert <Paul.Libert@naturalsciences.be>
Subject: kernel nlockmgr not registred with port mapper
Date: Fri, 13 Aug 2004 12:02:34 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <411C91BA.10506@naturalsciences.be>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="------------enig1D5DA5A83C15804CED6F68EC"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1BvYtf-0004yu-TJ
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 03:02:51 -0700
Received: from nestor.kbinirsnb.be ([193.190.234.10])
	by sc8-sf-mx2.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.34)
	id 1BvYtf-0003B0-54
	for nfs@lists.sourceforge.net; Fri, 13 Aug 2004 03:02:51 -0700
Received: from bernie.kbinirsnb.be (root@bernie.kbinirsnb.be [192.168.20.4])
	by nestor.kbinirsnb.be (8.12.11/8.12.11/Debian-5) with ESMTP id i7DA2ev1031963
	for <nfs@lists.sourceforge.net>; Fri, 13 Aug 2004 12:02:40 +0200
Received: from naturalsciences.be (PC20_115 [192.168.20.115])
	by bernie.kbinirsnb.be (8.12.11.Beta0/8.12.11.Beta0/Debian-1) with ESMTP id i7DA2gfB003463
	for <nfs@lists.sourceforge.net>; Fri, 13 Aug 2004 12:02:42 +0200
To: nfs@lists.sourceforge.net
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

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enig1D5DA5A83C15804CED6F68EC
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Dear List,

Solution to this problem should be easy but I'm to blind to find out so 
   ...

I'm having problem with to acquire locks on file over a nfs mounted 
filesystem.

Client system is a Debian Linux with 2.4.25 Debian packaged kernel
Server system is a Debian Linux with 2.4.24 Debian packaged kernel or 
2.6.6 Debian packaged kernel.

After looking on the system, it appears that a 'rpcinfo -p' on both 
server shows no nlockmgr :

Server 1 :
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100024    1   udp    882  status
     100024    1   tcp    885  status
     100003    2   udp   2049  nfs
     100003    2   tcp   2049  nfs
     100005    1   udp    897  mountd
     100005    2   udp    897  mountd
     100005    1   tcp    900  mountd
     100005    2   tcp    900  mountd
Server 2 :
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100011    1   udp    795  rquotad
     100011    2   udp    795  rquotad
     100011    1   tcp    798  rquotad
     100011    2   tcp    798  rquotad
     100024    1   udp    846  status
     100024    1   tcp    849  status
     100003    2   udp   2049  nfs
     100003    2   tcp   2049  nfs
     100005    1   udp    953  mountd
     100005    2   udp    953  mountd
     100005    1   tcp    956  mountd
     100005    2   tcp    956  mountd
     390113    1   tcp   7937

Client has the nlockmgr as a registred service :
    program vers proto   port
     100000    2   tcp    111  portmapper
     100000    2   udp    111  portmapper
     100011    1   udp    953  rquotad
     100011    2   udp    953  rquotad
     100011    1   tcp    956  rquotad
     100011    2   tcp    956  rquotad
     100024    1   udp    793  status
     100024    1   tcp    796  status
     100003    2   udp   2049  nfs
     100003    2   tcp   2049  nfs
     100005    1   udp    805  mountd
     100005    2   udp    805  mountd
     100005    1   tcp    808  mountd
     100005    2   tcp    808  mountd
     390113    1   tcp   7937
     100021    1   udp  52638  nlockmgr
     100021    3   udp  52638  nlockmgr
     100021    4   udp  52638  nlockmgr
     100021    1   tcp  56348  nlockmgr
     100021    3   tcp  56348  nlockmgr
     100021    4   tcp  56348  nlockmgr

So obviously, my problem is there.
I investigated further and found out that on both server, the 'lockd' 
kernel module was not loaded.
I tought I had found my problem and issused a 'modprobe lockd'
So now, kernel module is loaded but the nlockmgr is still not registred 
on portmap.

I've tried restartinf the portmapper and reloading the rpc.server but it 
doesn't solve my problem.
Unloading and reloading the kernel module doesn't change anything.

It must be obvious but I keep missing it ...

Any help will be very much appreciated.

Best regards.

Paul Libert

--------------enig1D5DA5A83C15804CED6F68EC
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.2.1-nr1 (Windows XP)
Comment: Using GnuPG with Thunderbird - http://enigmail.mozdev.org

iD8DBQFBHJHB9IdyKWFcSoYRAgLUAJ9TqrL7/nEAnuAbW6Fx5CJ89CQzPwCgizjW
dKUijo6AY+Vy6wpRIr7cQJo=
=h/eY
-----END PGP SIGNATURE-----

--------------enig1D5DA5A83C15804CED6F68EC--


-------------------------------------------------------
SF.Net email is sponsored by Shop4tech.com-Lowest price on Blank Media
100pk Sonic DVD-R 4x for only $29 -100pk Sonic DVD+R for only $33
Save 50% off Retail on Ink & Toner - Free Shipping and Free Gift.
http://www.shop4tech.com/z/Inkjet_Cartridges/9_108_r285
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
