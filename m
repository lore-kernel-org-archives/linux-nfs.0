From: Kurt Garloff <garloff@suse.de>
Subject: [garloff@suse.de: linux-2.4.18-rpc_tweaks.dif]
Date: Wed, 27 Mar 2002 10:20:20 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <20020327102020.E21073@gum01m.etpnet.phys.tue.nl>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="eVzOFob/8UvintSX"
Received: from etpmod.phys.tue.nl ([131.155.111.35])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 16q9bV-0008OP-00
	for <nfs@lists.sourceforge.net>; Wed, 27 Mar 2002 01:20:25 -0800
Received: from gum01m.etpnet.phys.tue.nl (gum01m.etpnet.phys.tue.nl [192.168.84.65])
	by etpmod.phys.tue.nl (8.9.3/8.9.3/SuSE Linux 8.9.3-0.1) with ESMTP id KAA22178
	for <nfs@lists.sourceforge.net>; Wed, 27 Mar 2002 10:20:21 +0100
Received: (from garloff@localhost)
	by gum01m.etpnet.phys.tue.nl (8.11.6/8.11.6/SuSE Linux 0.5) id g2R9KKW21766
	for nfs@lists.sourceforge.net; Wed, 27 Mar 2002 10:20:20 +0100
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


--eVzOFob/8UvintSX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

Yusuf Goolamabbas asked me to send this here as well.
In case you reply, please Cc: me, as I'm not on the NFS list.

----- Forwarded message from Kurt Garloff <garloff@suse.de> -----

Date: Wed, 27 Mar 2002 03:27:36 +0100
From: Kurt Garloff <garloff@suse.de>
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Cc: Linux kernel list <linux-kernel@vger.kernel.org>
Subject: linux-2.4.18-rpc_tweaks.dif
Mail-Followup-To: Kurt Garloff <garloff@suse.de>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	Linux kernel list <linux-kernel@vger.kernel.org>
User-Agent: Mutt/1.3.22.1i
X-Operating-System: Linux 2.4.16-schedJ2 i686
X-PGP-Info: on http://www.garloff.de/kurt/mykeys.pgp
X-PGP-Key: 1024D/1C98774E, 1024R/CEFC9215
Organization: TU/e(NL), SuSE(DE)

Hi Trond,

http://www.fys.uio.no/~trondmy/src/2.4.18/linux-2.4.18-rpc_tweaks.dif
contains a change that causes devastating NFS client performance: My NFS
read performance on a switched 100BaseT went down from >9MB/s to 500kB/s.
(NFSv3, rsize=3D8192, 2.4.16 AXP kernel nfsd server)

The reason is that
xprt_adjust_cwnd()
does no longer do what the comment above says it should do:
_slowly_ increase cwnd until we start to hit the limit (which we see from
timed out requests). Instead cwnd gets bumped very fast resulting in lots of
timed out requests. This way you get fast oscillations in cwnd.

Putting the old code back for xprt_adjust_cwnd() gave me back the old
performance.

Except for the missing damping, comparing the functionality with the old
code, e.g. this snippet
+	if (xprt->cong > cwnd)
+		goto out;
also makes me wonder whether it could be correct.=20
Please have a look at it again!

Regards,
--=20
Kurt Garloff                   <kurt@garloff.de>         [Eindhoven, NL]
Physics: Plasma simulations  <K.Garloff@Phys.TUE.NL>  [TU Eindhoven, NL]
Linux: SCSI, Security          <garloff@suse.de>    [SuSE Nuernberg, DE]
 (See mail header or public key servers for PGP2 and GPG public keys.)



----- End forwarded message -----

--=20
Kurt Garloff                   <kurt@garloff.de>         [Eindhoven, NL]
Physics: Plasma simulations  <K.Garloff@Phys.TUE.NL>  [TU Eindhoven, NL]
Linux: SCSI, Security          <garloff@suse.de>    [SuSE Nuernberg, DE]
 (See mail header or public key servers for PGP2 and GPG public keys.)

--eVzOFob/8UvintSX
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.0.6 (GNU/Linux)
Comment: For info see http://www.gnupg.org

iD8DBQE8oY7UxmLh6hyYd04RArGGAKDEI47bKfxIfflWHosQQFsWwBMxdACeNi3L
tQCwvP2IEiS/YZ54tm0kHHg=
=oV6U
-----END PGP SIGNATURE-----

--eVzOFob/8UvintSX--

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
