From: seth vidal <skvidal@phy.duke.edu>
Subject: more fun with hitting the hard quota
Date: 18 Apr 2002 13:16:06 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1019150166.3140.19.camel@opus>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-pXx1p0x02ZV+kIePYMjq"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.phy.duke.edu ([152.3.182.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16yFVx-0002yH-00
	for <nfs@lists.sourceforge.net>; Thu, 18 Apr 2002 10:16:10 -0700
Received: from opus.phy.duke.edu (opus.phy.duke.edu [152.3.182.42])
	by mail.phy.duke.edu (Postfix) with ESMTP id E476730199
	for <nfs@lists.sourceforge.net>; Thu, 18 Apr 2002 13:16:06 -0400 (EDT)
To: nfs@lists.sourceforge.net
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


--=-pXx1p0x02ZV+kIePYMjq
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,
 So I've setup a couple of machines to test this in more detail.

The server is running rh's skipjack beta2. a 2.4.18 +a bunch of patches
kernel.

ext3 filesystem, quotas turned on.
I set the user's hard quota to 200MB

if I mount it over nfs and then run:


while `true`
do
cat /dev/zero >> /mnt/test/dumbfile
done

Then the nfs server does respond with error messages about being over
the quota and the current cat job will stop with this error:

cat: write error: Disk quota exceeded

But if I consistently make the request to write to that file (as in the
above loop) the load on the server goes up to about 4 or 5.

At which point the other clients access becomes almost unbearable.

Does it make sense that one client should be able to abuse the server in
this way? And why didn't this happen on 2.2.19? I had a lesser powered
machine doing the same job and this problem never occurred.

I can provide more detailed tcpdumps from the server or client side now
if that'd help more.

Thanks
-sv






--=20
GPG Public Key: http://www.phy.duke.edu/~skvidal/skvidal.gpg

--=-pXx1p0x02ZV+kIePYMjq
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQA8vv9W1Aj3x2mIbMcRArR+AKCLSOX9tC+IAtFBAJCrTG4/CJxj/QCeOFua
LNnj+QBufWB/tQ8nVK+7VIg=
=LbdY
-----END PGP SIGNATURE-----

--=-pXx1p0x02ZV+kIePYMjq--


_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
