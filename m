From: Ian Truelsen <ian@ihtruelsen.2y.net>
Subject: problem with exports file
Date: Tue, 20 Aug 2002 13:45:21 -0500
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020820134521.352272bd.ian@ihtruelsen.2y.net>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 boundary="16,CV1yC(c?yL=.8"
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from h24-82-200-89.wp.shawcable.net ([24.82.200.89] helo=dark-lord.ihtruelsen.2y.net)
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17hE0K-00019R-00
	for <nfs@lists.sourceforge.net>; Tue, 20 Aug 2002 11:45:25 -0700
To: NFS List <nfs@lists.sourceforge.net>
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

--16,CV1yC(c?yL=.8
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

I am not sure what it is that I am doing wrong here, but it is driving
me nuts.

Here is what I am trying to set up: I want some individual directories
on the server to be available to my whole lan, but I want one machine to
have access to the whole directory tree for administration. Here is what
I have in my exports file:

/home/ian *.ihtruelsen.2y.net(rw,no_root_squash)
/media *.ihtruelsen.2y.net(rw,no_root_squash)
/home/httpd *.ihtruelsen.2y.net(rw,no_root_squash)
/ minion.ihtruelsen.2y.net(rw,no_root_squash)

This works fine for the individual directories, but the whole structure
will not mount on the minion machine, giving me a Permission denied
error.

Can anyone give me some idea why this won't work as imagined?

-- 
Ian Truelsen
Masters program in Philosophy 
University of Manitoba, Winnipeg, Canada
BA (Wilfrid Laurier University)
Email: ian@ihtruelsen.2y.net
Homepage: http://www.ihtruelsen.2y.net
PGP key available at: http://www.ihtruelsen.2y.net/pgp.html 
and http://pgp.mit.edu (search 'ihtruelsen')
--16,CV1yC(c?yL=.8
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.7 (GNU/Linux)

iD8DBQE9Yo5BRbkIX3MFv7URAjYYAKCMwOMuTgw6e+UkpG/bkNlwY9s1agCfcpLf
ElA+QNQHrqEgVmUyK1oTNqo=
=vPXB
-----END PGP SIGNATURE-----

--16,CV1yC(c?yL=.8--



-------------------------------------------------------
This sf.net email is sponsored by: OSDN - Tired of that same old
cell phone?  Get a new here for FREE!
https://www.inphonic.com/r.asp?r=sourceforge1&refcode1=vs3390
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
