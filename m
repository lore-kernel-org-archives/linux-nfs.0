Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:33241 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935808Ab1JGAxQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 6 Oct 2011 20:53:16 -0400
Received: from relay1.suse.de (charybdis-ext.suse.de [195.135.221.2])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id 797C69043F
	for <linux-nfs@vger.kernel.org>; Fri,  7 Oct 2011 02:53:15 +0200 (CEST)
Date: Fri, 7 Oct 2011 11:53:11 +1100
From: NeilBrown <neilb@suse.de>
To: NFS <linux-nfs@vger.kernel.org>
Subject: Trailing '/' on path names in /etc/fstab confused mount.
Message-ID: <20111007115311.278a7acf@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/V2nZQuQ1mn7nF26ecoP21kJ"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/V2nZQuQ1mn7nF26ecoP21kJ
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable



If I have:

  host:/path /mountpoint nfs defaults 0 0

in /etc/fstab, mount then "mount /mountpoint" the entry that
appears in /proc/mounts is

  host:/path/ /mountpoint nfs .....

Note the extra '/'.

This confused mount.  If I run

   mount -a -t nfs,nfs4 -f -v -n -i

(as I might in a script to check if all NFS mountpoints are actually mounte=
d),
it thinks that /mountpoint is not correctly mounted.  If I edit /etc/fstab
to put the '/' in, 'mount' is not confused any more and reports correctly.

So:
  Why do we get the trailing '/'?  Is it really needed or is it a bug?

  If it is really needed I suspect we need to teach 'mount' to ignore such
  things....  but is it guaranteed that requesting "/path/" from the server
  is exactly the same as requesting "/path" ???  It certainly is for NFSv4
  and any v3 server that handled the two differently could certainly be
  considered to be odd, but is it definitely wrong?

Thought?

Thanks,
NeilBrown


--Sig_/V2nZQuQ1mn7nF26ecoP21kJ
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBTo5Ndznsnt1WYoG5AQK2OxAAkBBpL6kb9UqQ5BF16ZqF0VH6HQHLexm8
hP5UH3K9C7XUhEgo2COD6msTpThkcIYbAXn+8qcCjNcqq8xDzJvCio8GDZo7ePeO
ZtaZwTnDjLrQ171iZMT61hFhHvyd238Kc/ampEgH45V/RRcJSLplZ/3oh56TdY4o
tYMNW8IbxdGA3mec3h2mvUYvVxFx1EjnB8uEo0dDD+aHwf/J28MAs+CKQi/UIRbk
rMFcw0FEee20JcAOmjrVsklNVnlkts9zr4D2DbvaINrtvkqMj/TvsZjflttHtfDQ
tkaMMIfNptKdwL5bb1ePiy00gEwjG4CiCFcFSzA3rdNofG6QaPnAXQGnUK6NcB93
8Xjwa+ez/bDcZDqNdd+llftGBzkSrCyFOseM8d6qOaH0ynedSE72g+2onr2mH2Nn
q9AfWQ+nODyweO4d125nWFoEzaYbyPQi7hcxfj+W2L3wP+Y7+TCeh+uG6ficUB6w
Fu9THXQCMavi6Y0+DuQwnGDZ84jmfFajnbcq0TrWUs6Xzv6RbmD6slVZw97WVj5v
YG3wXGPqYqlc4rcGykD1jbfIZoD0tL/lxpd56DoLz4JUgJizo3fXoAWemNNsAtxd
WXW99tqgmsp/Q/Su5q2CNgj+huSE8pT49jFBCPx5V4gsj1eFy1DBwxkCs9Sf3Tgt
KhnYNbfhgXM=
=9GzD
-----END PGP SIGNATURE-----

--Sig_/V2nZQuQ1mn7nF26ecoP21kJ--
