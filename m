From: seth vidal <skvidal@phy.duke.edu>
Subject: 2.4.18-5 server and client with < 2.4.18-5 read slowness
Date: 23 Jul 2002 18:25:26 -0400
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1027463126.28462.104.camel@opus>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature";
	boundary="=-umd2o+WOFYUEh+6gp8Va"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from mail.phy.duke.edu ([152.3.182.2])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17X860-0005F1-00
	for <nfs@lists.sourceforge.net>; Tue, 23 Jul 2002 15:25:32 -0700
Received: from opus.phy.duke.edu (opus.phy.duke.edu [152.3.182.42])
	by mail.phy.duke.edu (Postfix) with ESMTP id 95215303C3
	for <nfs@lists.sourceforge.net>; Tue, 23 Jul 2002 18:25:26 -0400 (EDT)
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


--=-umd2o+WOFYUEh+6gp8Va
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi all,
 I've been trying to sort out the problems with rhl 7.3 2.4.18-5.
I've got the mounts using rsize and wsize of 8192 and in async mount
(and async export on the server (for testing nfs speed, not disk speed))

What I've found is this:

if the server is 2.4.18-5 the read and write performance is fine with
either older kernels or 2.4.18-5 (on 100tx cards 9-10MB/s on read and
write w/multiple threads)

If the server is < 2.4.18-5 the performance for clients 2.4.18-5+ is
good for writes, lousy for reads, but the performance for < 2.4.18-5
clients is good for both reads and writes.

(2MB/s read performance and 9-10MB/s write performance)

Is this occurring b/c of the rpc congestion fixes that went into the
client for 2.4.18-5+ or is it related to the rpc_ping function (which
appears to be showing up A LOT in the tcpdumps of traffic b/t the two
machines)

Is it likely that the newer clients will just not be happy with older
servers b/c of the changes to the client code? Is there any way to work
around this?

-sv



--=-umd2o+WOFYUEh+6gp8Va
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQA9PdfW1Aj3x2mIbMcRAqshAJ0YnOVe5c2z0Oy0FYa8DLUNgomkjACfWkTu
dgjBy0BlL8XKduFBnjGGUk8=
=mrAi
-----END PGP SIGNATURE-----

--=-umd2o+WOFYUEh+6gp8Va--



-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
