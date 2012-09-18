Return-Path: linux-nfs-owner@vger.kernel.org
Received: from cantor2.suse.de ([195.135.220.15]:45950 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752658Ab2IRBXn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Sep 2012 21:23:43 -0400
Received: from relay2.suse.de (unknown [195.135.220.254])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx2.suse.de (Postfix) with ESMTP id DDE65A3DDF
	for <linux-nfs@vger.kernel.org>; Tue, 18 Sep 2012 03:23:41 +0200 (CEST)
Date: Tue, 18 Sep 2012 11:23:29 +1000
From: NeilBrown <neilb@suse.de>
To: NFS <linux-nfs@vger.kernel.org>
Subject: Inconsistency when mounting a directory that 'world' cannot access.
Message-ID: <20120918112329.7d88ed9e@notabene.brown>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=PGP-SHA1;
 boundary="Sig_/pK_0xtQY.6ziqjzt=+7aUAi"; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--Sig_/pK_0xtQY.6ziqjzt=+7aUAi
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable


Suppose that on an NFS server I have a directory
   /foo/bar/baz

which I export, and that /foo/bar does not have world access.  e.g.
permissions are '750' and everyone who owns files in there is a member of t=
he
group which owns /foo/bar.

Then with NFSv3 I can
  mount server:/foo/bar/baz  /somewhere
because the lookup of /foo/bar/baz happens as root on the server in mountd.

With NFSv4 using 'sec=3Dsys' I can only do this if I export with
"no_root_squash", as the lookup happens on the client as root, and if root
were squashed, it wouldn't have access beyond /foo/bar.

But if I use NFSv4 using 'sec=3Dkrb5', the lookup happens on the client usi=
ng a
machine credential which gets mapped to 'nobody/nogroup' (or whatever anonu=
id
and anongid are set to for the export).  So I cannot perform the mount at a=
ll.

This is - at best - inconsistent and can cause confusion (hey - I was
confused for a while there).

Should something be done?  Can anything be done?

I lean towards thinking that the most restrictive behaviour is most correct
(though I have a customer who feels that it is too restrictive).

Should the NFSv4 client always use an anon credential when performing the
'mount'?  Is that even possible for auth_sys?
Should rpc.mountd use set_fsuid before doing the path lookup to ensure that
everyone has access to the exported directory?

Or is there some way 'mount' lookups for krb5 could be treated as being
performed by root?

Any ideas?

NeilBrown


PS the reason to want to mount a sub directory instead of just mounting the
top level directory is that "/foo/bar" is rather large - over 1000 home
directories.  Whenever anything does an "ls -l" or similar in there (and it
seems that some things do) it causes fairly horrible performance somewhere
(lots of uid to name to uid mappings probably being part of it).  Using an
automounter to just mount the bit that is required seems to help.

--Sig_/pK_0xtQY.6ziqjzt=+7aUAi
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.18 (GNU/Linux)

iQIVAwUBUFfNETnsnt1WYoG5AQIzKQ//V39iBhRtNtYz61C1ICk+peXgvt1oATkm
bRx9OdLz9IYuEHEcVFX+X25OCbWQT2NaFhg55+2l2DEhYb+02wXC6j1/8d9ayH5a
dAioYVRATZANkBhQ/2Y9BOMRLE1AxfUv0esufrlhjzQoiXvgkSbemNJtsXnyPay0
lS9ZC7rNHFWfo0eKsdpMfax1fUo5lT2Q+l5CtVlWc/JO+gUU7+hiAWSperdsEPgl
BPmYTShDpdJm739U6KKrfsB+ozz436cHbmeR/ataoL3znVHZd8VAjUf0AYYvhUns
hVYq7GDg7dEgh5s1WF2cqXYYYgieC7COhqVREeBcpEi5VkA5Sl4AxhQ0Zu5RXK+j
OdZeUcnVmt0CjeaABLzakWdFkIlrf2hPOhLSzGJw7+AoR8GvemOWpNR6l4s6I3zz
dymCR4YpxopazvPGcY9P2U0S1GULzwz4iTY82DuIZ5RlHW3NHWbQVM5uD4Q5w8/L
YXX5a2aLdrkxkzi3MQjkWGsXJny+tm1l/0y28qfzhyL1zQJRp97KC+0t8bRUTxkO
P1tbRucDodH0M8/alcrf0vaZXmqAiLUaqWk8RX78wmowZlTxsKWuvwZ30poUnqOE
Hn+h8iGOHeyWGo35Qd77r5xYEb9fwxfUtW12eCEftMq+iqJk1lHKTtzVYVbVea/1
Z/dIWH8E5KM=
=FjXT
-----END PGP SIGNATURE-----

--Sig_/pK_0xtQY.6ziqjzt=+7aUAi--
