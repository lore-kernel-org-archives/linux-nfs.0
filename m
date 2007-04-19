From: Javier =?iso-8859-1?Q?Fern=E1ndez-Sanguino_Pe=F1a?= <jfs@computer.org>
Subject: Re: Does mountd/statd really need to listen on a privileged
	port??
Date: Thu, 19 Apr 2007 03:21:54 +0200
Message-ID: <20070419012154.GB19063@javifsp.no-ip.org>
References: <17958.48121.280256.493824@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0485118865=="
Cc: anibal@debian.org, Matthias Koenig <mkoenig@novell.com>,
	nfs@lists.sourceforge.net, Olaf Kirch <olaf.kirch@oracle.com>,
	Steve Dickson <SteveD@redhat.com>
To: Neil Brown <neilb@suse.de>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HeLLP-0000ZM-Ju
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 18:21:55 -0700
Received: from ug-out-1314.google.com ([66.249.92.170])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HeLLR-0005FQ-OQ
	for nfs@lists.sourceforge.net; Wed, 18 Apr 2007 18:21:58 -0700
Received: by ug-out-1314.google.com with SMTP id z38so485459ugc
	for <nfs@lists.sourceforge.net>; Wed, 18 Apr 2007 18:21:56 -0700 (PDT)
In-Reply-To: <17958.48121.280256.493824@notabene.brown>
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


--===============0485118865==
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="98e8jtXdkpgskNou"
Content-Disposition: inline


--98e8jtXdkpgskNou
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, Apr 19, 2007 at 10:46:49AM +1000, Neil Brown wrote:
> What would people think if I added it to the nfs-utils release and
> made some improvements?  Would that get into distros in parallel with
> nfs-utils?

Well, portmap is being used by applications which are completely unrelated to
nfs (FAM and NIS come to mind) but who depend on it. Including it into
nfs-utils doesn't seem natural to me as you would need to have those pieces
depending on 'portmap' to depend on 'nfs-utils' even if they are completely
unrelated to NFS.

It would seem more natural to have a new upstream portmap maintainer, if
needed, that an inclusion in the NFS project. IMHO

In any case, I don't see that many changes being introduced by distributions.
Debian's portmap and Fedora/RedHat's portmap is rather similar (there are
slightly differences in some command line switches).

If you forwarded some fixes to portmap to the distribution's BTS I'm pretty
sure it would get accpeted.

Regards

Javier

--98e8jtXdkpgskNou
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)

iD8DBQFGJsQxsandgtyBSwkRArZLAJ0fghhFG6zfz3JjJwNIrwkty1256gCghrN3
yWmf51BrKEhIJx/bpb1P2o0=
=eNW/
-----END PGP SIGNATURE-----

--98e8jtXdkpgskNou--


--===============0485118865==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
--===============0485118865==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs

--===============0485118865==--
