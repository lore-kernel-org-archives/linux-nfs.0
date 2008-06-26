From: Adrian von Bidder <avbidder-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Subject: Re: [NFS] NFS performance debugging
Date: Thu, 26 Jun 2008 08:19:29 +0200
Message-ID: <200806260819.35108@fortytwo.ch>
References: <200806231659.58158@fortytwo.ch> <200806250902.42880@fortytwo.ch>
	<20080625165658.GA12629@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1553722926=="
Cc: nfs@lists.sourceforge.net
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:42775 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750865AbYFZGqQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jun 2008 02:46:16 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KBlFD-0007QS-Gp
	for linux-nfs@vger.kernel.org; Thu, 26 Jun 2008 16:46:11 +1000
In-Reply-To: <20080625165658.GA12629@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--===============1553722926==
Content-Type: multipart/signed; boundary="nextPart1766973.jJxfiDh7lB";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart1766973.jJxfiDh7lB
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Wednesday 25 June 2008 18.56:58 J. Bruce Fields wrote:
> On Wed, Jun 25, 2008 at 09:02:42AM +0200, Adrian von Bidder wrote:
> > On Tuesday 24 June 2008 22.29:31 J. Bruce Fields wrote:
> > > On Tue, Jun 24, 2008 at 12:17:24PM +0200, Adrian von Bidder wrote:
> > > > Starting KDE, opening documents, sometimes also closing oo.org and
> > > > saving documents takes several seconds longer than on local disk.
> > >
> > > "close" on nfs is an operation that requires a round-trip to the
> > > server and waiting for the disk to commit any writes made before the
> > > close, so if you've got to do a lot of those it can take time.=20
> > > Fooling with the journaling on the exported filesystem may help.
> >
> > Are there tools to measure latencies on NFS?  Given a network dump,
> > desired output would be histograms of latencies by file operation?  (Or
> > maybe I can catch the information on the client, VFS side instead of
> > NFS?
> >
> > At this time, I really need to collect more data on where the problem
> > is since all I'm doing right now is fooling around based on
> > assumptions... :-(
> >
> > OTOH I'd suspect KDE/oo.org startup to be mostly reads of those config
> > files, so the problem shouldn't be close latencies.  Assumptions again.
> >
> > > > TODO today: play around with NFSv4 on the shaky assumption that
> > > > nfsv3 is actually working but net latency is killing my
> > > > performance.
> > >
> > > Delegations *might* help if the problem is really open latency.
> >
> > First tries showed
> >  * There are no acl on my files now
>
> NFSv4 uses an entirely different type of ACL, for which you need
> different client-side tools; see

I'm absolutely confused on the state of nfs4 acls.  There are so many old=20
mailing list posts around that it's difficult to see what information=20
applies to the currentimplementation.  So: are POSIX acls in the server=20
filesystem somehow mapped to nfsv4 acls on the client side?  I understand=20
there understands an RFC proposal on how to do this, and=20
http://wiki.linux-nfs.org/wiki/index.php/ACLs is very interesting but=20
doesn't really cover the current state of the implementation.

> 	http://www.citi.umich.edu/projects/nfsv4/linux/nfs4-acl-tools/

Hmm.  Not packaged in Debian yet?????? ;-)  So work to do for me if I end u=
p=20
using nfs4

>
> >  * user id mapping seems funny: some users map to nobody, others map
> > correctly.  Huh?
>
> And whereas v2/v3 require only uid's and gid's to agree, v4 (if you're
> using auth_sys) requires uid's, gid's, *and* user and group names to
> agree.

I got that fixed.  "localdomain" in idmapd.conf...

cheers
=2D- vbi


=2D-=20
> Maybe that question would be a good starting point: What's the use for
> a gender field there?
Stalking.
        -- Miriam Ruiz, Marco d'Itri (im that order)

--nextPart1766973.jJxfiDh7lB
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: get my key from http://fortytwo.ch/gpg/92082481

iKcEABECAGcFAkhjNPdgGmh0dHA6Ly9mb3J0eXR3by5jaC9sZWdhbC9ncGcvZW1h
aWwuMjAwMjA4MjI/dmVyc2lvbj0xLjUmbWQ1c3VtPTVkZmY4NjhkMTE4NDMyNzYw
NzFiMjVlYjcwMDZkYTNlAAoJECqqZti935l6VlIAni3r8HWnxxxUjLngVXcgV5Br
rMpdAKCl3IW1ZgJjt9KklHH0LWOd3IJ44w==
=OUqg
-----END PGP SIGNATURE-----

--nextPart1766973.jJxfiDh7lB--


--===============1553722926==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
--===============1553722926==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

--===============1553722926==--


