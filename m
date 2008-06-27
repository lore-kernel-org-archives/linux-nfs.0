From: Adrian von Bidder <avbidder-xzBkAS4TQxQfv37vnLkPlQ@public.gmane.org>
Subject: Re: [NFS] NFS performance debugging
Date: Fri, 27 Jun 2008 08:24:49 +0200
Message-ID: <200806270824.54066@fortytwo.ch>
References: <200806231659.58158@fortytwo.ch> <200806260819.35108@fortytwo.ch>
	<20080626170342.GB6961@fieldses.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============1348583904=="
Cc: "J. Bruce Fields" <bfields@fieldses.org>
To: nfs@lists.sourceforge.net
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:45434 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751780AbYF0GZP (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Jun 2008 02:25:15 -0400
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1KC7OS-0000kL-8t
	for linux-nfs@vger.kernel.org; Fri, 27 Jun 2008 16:25:12 +1000
In-Reply-To: <20080626170342.GB6961@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--===============1348583904==
Content-Type: multipart/signed; boundary="nextPart5982726.Ist6aXSyaf";
	protocol="application/pgp-signature"; micalg=pgp-sha1
Content-Transfer-Encoding: 7bit

--nextPart5982726.Ist6aXSyaf
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Thursday 26 June 2008 19.03:42 you wrote:
> On Thu, Jun 26, 2008 at 08:19:29AM +0200, Adrian von Bidder wrote:
> > On Wednesday 25 June 2008 18.56:58 J. Bruce Fields wrote:
> > > On Wed, Jun 25, 2008 at 09:02:42AM +0200, Adrian von Bidder wrote:
> > > > First tries showed
> > > >  * There are no acl on my files now
> > >
> > > NFSv4 uses an entirely different type of ACL, for which you need
> > > different client-side tools; see
> >
> > I'm absolutely confused on the state of nfs4 acls.  There are so many
> > old mailing list posts around that it's difficult to see what
> > information applies to the currentimplementation.  So: are POSIX acls
> > in the server filesystem somehow mapped to nfsv4 acls on the client
> > side?  I understand there understands an RFC proposal on how to do
> > this, and
> > http://wiki.linux-nfs.org/wiki/index.php/ACLs is very interesting but
> > doesn't really cover the current state of the implementation.
>
> I've attempted to update that wiki page to fix that problem; could you
> take a look and tell me whether the changes help?

The summary is: "POSIX ACLs on the server side turn (more or less) into=20
NFSv4 ACL on the client.", correct?  So our current ACL based system of=20
permissions should work except that we can't modify permissions on the=20
client side until I've deployed nfs4 acl tools ...

>
> > > 	http://www.citi.umich.edu/projects/nfsv4/linux/nfs4-acl-tools/
> >
> > Hmm.  Not packaged in Debian yet?????? ;-)  So work to do for me if I
> > end up using nfs4
>
> Yes.  Volunteers to package those things welcomed....

=2E.. which means you've possibly got your Debian packager, and I might eve=
n=20
be able to do that on company time.

Ok, I guess I know in which direction to put my work now, thanks a lot. =20
(nfs-iostat will be the first thing I'll try, though, to get some more=20
data.)

cheers
=2D- vbi


=2D-=20
Why on earth should we teach children
that they are not allowed to share the toys.
        -- Patrick Harvie, Member of the Scottish Parliament
           Speaking at Debconf7



--nextPart5982726.Ist6aXSyaf
Content-Type: application/pgp-signature; name=signature.asc 
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.6 (GNU/Linux)
Comment: get my key from http://fortytwo.ch/gpg/92082481

iKcEABECAGcFAkhkh7ZgGmh0dHA6Ly9mb3J0eXR3by5jaC9sZWdhbC9ncGcvZW1h
aWwuMjAwMjA4MjI/dmVyc2lvbj0xLjUmbWQ1c3VtPTVkZmY4NjhkMTE4NDMyNzYw
NzFiMjVlYjcwMDZkYTNlAAoJECqqZti935l6kckAnRQJrZp74o/GaWPJzH3klDMk
y4xoAKCdel/2MJGK6zV4XygNVlmMdWtvPA==
=PpfN
-----END PGP SIGNATURE-----

--nextPart5982726.Ist6aXSyaf--


--===============1348583904==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://sourceforge.net/services/buy/index.php
--===============1348583904==
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

--===============1348583904==--


