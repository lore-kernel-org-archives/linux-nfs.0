From: "Heflin, Roger A." <Roger.A.Heflin@conocophillips.com>
Subject: RE: Too many mounts
Date: Thu, 6 Mar 2003 16:19:56 -0600
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <5CA6F03EF05E0046AC5594562398B916A3285A@POEXMB3.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <jonas@informatik.gu.se>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from usamail1.conoco.com ([12.31.208.226])
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18r3id-0005OJ-00
	for <nfs@lists.sourceforge.net>; Thu, 06 Mar 2003 14:20:03 -0800
To: <nfs@lists.sourceforge.net>
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




>  To: nfs@lists.sourceforge.net
> From: Jonas Oberg <jonas@informatik.gu.se>
> Organization: Institutionen for Informatik, Handelshogskolan, GU
> Date: Thu, 06 Mar 2003 14:52:22 +0100
> Subject: [NFS] Too many mounts
>=20
> In our department we have a problem with our student server. It
> appears that the Linux kernel limits the number of anonymous (nfs
> et. al) mounts to 256. This is a problem for us, since we use
> automount to mount home directories from our fileserver via NFS. We
> are frequently in the range of 190-220 active mounts (we have set the
> automount timeout to be about 30 seconds to get rid of idle mounts
> quickly).
>=20
> Does anyone have a solution for this problem? Would using devfs
> perhaps solve the problem by allowing more anonymous mounts?
>=20
>=20
	It is supposed to be a kernel limitation so devfs won't help you.

	There were (6-9 months ago)  some patches for certain=20
	versions of the kernel to change the limit up to around 768 or so,
	and there was a more complicated patch that would take the number
	higher, but I believe had to use unsecured ports.

	The last time I looked for them I did not find exactly what I
	was looking for, and we have not been hitting the limit except
	under conditions that were a admin mistake and not supposed to have
	been happening.


						Roger


-------------------------------------------------------
This SF.net email is sponsored by: Etnus, makers of TotalView, The debugger 
for complex code. Debugging C/C++ programs can leave you feeling lost and 
disoriented. TotalView can help you find your way. Available on major UNIX 
and Linux platforms. Try it free. www.etnus.com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
