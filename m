Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:52947 "EHLO mx1.suse.de"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751370AbdHKHRp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 11 Aug 2017 03:17:45 -0400
From: NeilBrown <neilb@suse.com>
To: Jeff Layton <jlayton@redhat.com>,
        Olga Kornievskaia <kolga@netapp.com>,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-api@vger.kernel.org
Date: Fri, 11 Aug 2017 17:17:34 +1000
Cc: David Howells <dhowells@redhat.com>
Subject: Re: [RFC 1/1] destroy_creds.2: new page documenting destroy_creds()
In-Reply-To: <1502281848.12841.2.camel@redhat.com>
References: <20170807212355.29127-1-kolga@netapp.com> <20170807212355.29127-3-kolga@netapp.com> <1502281848.12841.2.camel@redhat.com>
Message-ID: <87378yr2sx.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Wed, Aug 09 2017, Jeff Layton wrote:
....
>
> Thanks, that helps a bit. I'm less clear on what the higher-level
> vision is here though:
>
> Are we all going to be running scripts on logout that scrape
> /proc/mounts and run fslogout on each? Will this be added to kdestroy?
>
> Or are you aiming to have KCM do this on some trigger? (see:
> https://fedoraproject.org/wiki/Changes/KerberosKCMCache)
>
> Also, doing this per-mount seems wrong to me. Shouldn't this be done on
> a per-net-namespace basis or maybe even globally?

Having looked at the code, I think this is invalidating cached
credentials globally -- or at least, globally for all filesystems that
use sunrpc.

I actually question the premise for wanting to do this.  Tickets have a
timeout and will expire.  Any code that is allowed to get a ticket, can
hold on to it as long as it likes - but it will cease to work after the
expiry time.  Hunting out all the places that a key might be cached, and
invalidating them, seems to deviate from the model.  If you are concerned
about leaving credentials around where they can theoretically be
misused, then set a smaller expiry time.

What is the threat-model that this change is supposed to guard against?

Looking that the syscall itself:
 1/ why restrict the call to directories only?
 2/ Every new syscall should have a 'flags' argument, because you never
    know when you'll need one.

NeilBrown

=20=20=20
>
> It seems like we can afford to be rather cavalier about destroying
> creds here. Even if we purge creds for a user that should have remained
> valid, we just end up having to re-upcall for them, right?
> --=20
> Jeff Layton <jlayton@redhat.com>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAlmNWhAACgkQOeye3VZi
gblmZRAAsm2J4ZBknA4qKpWsZJkPoYgscpzh0mcYKtqF3hvLWy9MYz6lXDkP8Mmi
obf6460arcZQd2p1boWOLQr1yss1SBxF4yQYFKuJg1AHz1D7K5P+LYatJr9W67wC
NUfOKE2pt5KQr10aeaFq3LJEf7gl6qIchPFbVtbQ8aSvUb/uwprb5y/k/O/befEa
lNytiPz5xRkdefACwlD0VIfrQPE+jCMiPMhhRtEKPHfYVLGNHdRctYKvdl0CC7ND
uSrVBPtW+F2OULPIF8BboiRFRNnFiJ7n4iTzwX0CsiEC4DW8vIsK4Z7YjoesXSi5
G47C3DRUOPhasd8w57IFgEWAvZQpB+4SIUA58FHJg9W4/BYB6+aNqGXWHh4+ak79
I7GWu+frZX4sG84CcgSGfzn8PhjuIBYiSk1DWFM38JanVHzJlqySCiuH49fZ36GZ
euG3aOx9LyCMiqb0iGIM1WuXj2JehZgcMMdo0IJHosoeJqHVsjZqBwYbLc8xoBAU
m6dtMDjnrDb2U2HPq7YrD48GnWH7/gmjJCG5rmKHa7O6CFwl8nyUnOHX90NiE5SL
8t0P1ex22W9UOZeaQigOlby6hE9bZuiEULSqyFhnCymcoOuYLoOWIiWDngeTpBAu
BgrDZjtBq0dwMZWYMsP697NakFuNb0pTq+Kwn6qMSjnDm9yeU90=
=Iejz
-----END PGP SIGNATURE-----
--=-=-=--
