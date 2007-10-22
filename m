From: Chris Hall <chris@halldom.com>
Subject: NFSv4, SSH etc.
Date: Mon, 22 Oct 2007 11:14:21 +0100
Message-ID: <4qlKQmD9fHHHFwKt@agrotera.halldom.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1670898847=="
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IjuKQ-0000Kk-UJ
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 03:16:12 -0700
Received: from anchor-post-36.mail.demon.net ([194.217.242.86])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IjuKU-0004TY-UA
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 03:16:16 -0700
Received: from [80.177.246.141] (helo=agrotera.halldom.com)
	by anchor-post-36.mail.demon.net with esmtp (Exim 4.67)
	id 1IjuKH-000N0v-M4
	for nfs@lists.sourceforge.net; Mon, 22 Oct 2007 10:16:02 +0000
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

This is a PGP signed message sent according to RFC3156 [PGP/MIME]

--===============1670898847==
Content-Type: multipart/signed;boundary="=_Turnpike_26GJkeDwfHHH574x=";
	protocol="application/pgp-signature";micalg=pgp-sha1

This is a PGP signed message sent according to RFC3156 [PGP/MIME]

--=_Turnpike_26GJkeDwfHHH574x=
Content-Type: text/plain;charset=us-ascii
Content-Transfer-Encoding: quoted-printable


Help !  I am failing to set up a secure NFS server.  (Generally thought
to be impossible by most sources !)

I am running a fully up to date Fedora 7.

  kernel-2.6.22.9-91.fc7
  nfs-utils-lib-1.0.8-10.fc7
  nfs-utils-1.1.0-3.fc7
  libtirpc-0.1.7-9.fc7
  rpcbind-0.1.4-6.fc7

I have been trying to get NFSv4 working between a client on the inside
of my firewall and a server on the outside (DMZ).

 a. I thought NFSv4 would be better because it apparently only requires
    the one TCP port, which is easier to manage.  This turns out not to
    be entirely the case -- umount appears to still want to talk to port
    111 to find mountd.

    Is there some configuration I have missed, please ?

 b. I already use SSH into the server.  So I thought the easy way to
    secure access to the server was to forward the nfsd port from the
    client to the server.

    This does not work.  The server refuses, returning:

        Reject State: AUTH_ERROR (1)
        Auth State: bad credential (seal broken) (1)

    I guess this is because nfsd is upset by receiving a packet which it
    sees as coming from lo, containing a foreign host name.

    I can find no way around that.

    Have I missed something, please ?

 c. I have tried to figure out whether idmapd might help me.

    I'm sorry, I cannot find anything that tells me what nfsd actually
    gets from idmapd, or what one can put in idmapd.conf to influence
    that.

    Where do I look, please.

I realise that Kerberos is a way of securing this.  But that would
require first that I set up a KDC etc etc, and second that I secure the
connection from the server in the DMZ.

I had hoped to stick with SSH which already does the job of providing a
secure, one-way connection to the server.

I could use NFSv3 and SSH.  I can set the ports to use at the server
end, and I can tell the client to forward nfsd and mountd ports -- for
which I can set special ports on the client.  However:

 d. do I need to forward lockd ?  How do I tell the client to use a
    special port number -- dedicated to lockd on the client ?

 e. similarly, do I need to forward port 111 ?

 f. I can turn off rquotad on the server, so I don't need to figure out
    how to secure that.  But I do not know how statd fits into this.
    What should I do there ?

Thanks,

Chris
--=20
Chris Hall

--=_Turnpike_26GJkeDwfHHH574x=
Content-Type: application/pgp-signature
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: PGP SDK 3.8.3

iQEVAwUARxx3/Og9H9B04S2cAQKtRggAiGf3BeuS7oJj+Gink8mUwfF5lK+u3l71
PZzkZ/ejIJv2p6S0tpgYaFmKCf1ccrJgcsJA3Ra9uGadZqLIY7qji+0HyI6FECly
LxlVwdx3h7iGN6NN4OhT19Fke7ivt09hEZMtDkHvbjIjgv7qa2LlSPXpYuGxxxov
XExLN88h+Z4u6BjctW7l+En3nd+vHHXljUiU8Zd7G3fg0/FoQ1QJRPCzFCOpGoo4
k4Jg2t0NMzvk1SBSZO06sP5PxphvCP5m9qYLZYGzaQTEozfMYXc7rAqkYjO1rVaK
AM1M1Dj9q0/w2GgzEitpQNGdh0PDElsdSUMi+xkWqJA4RzMEPoqjgQ==
=m/vT
-----END PGP SIGNATURE-----

--=_Turnpike_26GJkeDwfHHH574x=--


--===============1670898847==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
--===============1670898847==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============1670898847==--
