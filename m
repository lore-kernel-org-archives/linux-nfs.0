Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:32881 "EHLO mx2.suse.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750770AbdCIA56 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 8 Mar 2017 19:57:58 -0500
From: NeilBrown <neilb@suse.com>
To: Simo Sorce <simo@redhat.com>,
        The GSS-Proxy developers and users mailing list
        <gss-proxy@lists.fedorahosted.org>,
        "linux-nfs\@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Thu, 09 Mar 2017 11:57:44 +1100
Subject: Re: [gssproxy] migration from svcgssd to gssproxy results in regression.
In-Reply-To: <1488989946.25839.3.camel@redhat.com>
References: <87lgsgissm.fsf@notabene.neil.brown.name> <1488989946.25839.3.camel@redhat.com>
Message-ID: <877f3zi7w7.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On Wed, Mar 08 2017, Simo Sorce wrote:

> On Wed, 2017-03-08 at 10:14 +1100, NeilBrown wrote:
>> Hi,
>> =C2=A0I recently tried using gssproxy for krb5 authentication with nfsd.
>> =C2=A0This was because customer is using an AD kerberos master which uses
>> =C2=A0certificates which are too big for svcgssd to work with (i.e. larg=
er
>> =C2=A0than one page).
>>=20
>> =C2=A0Unfortunately it doesn't work.
>>=20
>> =C2=A0The svcgssd code in nfs-utils calls
>> =C2=A0=C2=A0=C2=A0gss_display_name()
>> =C2=A0to get the name of the principal.=C2=A0=C2=A0This returns somethin=
g like
>> =C2=A0"user@domain".
>>=20
>> =C2=A0getpwnam() works perfectly on this (when nsswitch is set to use
>> "winbind")
>> =C2=A0but svcgssd goes further and uses nfs4_gss_princ_to_ids() to perfo=
rm
>> =C2=A0the lookup.=C2=A0=C2=A0Presumably this is more general?
>>=20
>> =C2=A0gssproxy does neither of these.
>> =C2=A0It uses gss_localname() to get the user name, which returns
>> something
>> =C2=A0like "user".
>> =C2=A0It then calls getpwnam() on that, which fails ("user@domain" or
>> =C2=A0"domain\user" both succeed).
>>=20
>> =C2=A0I have modified my copy to use gss_display_name() instead of
>> =C2=A0gss_localname() and it now appears to work perfectly ... for this
>> =C2=A0use-case at least.
>>=20
>> =C2=A0What is the right way forward here?
>> =C2=A0Is nfs4_gss_princ_to_ids() really necessary?
>> =C2=A0Should gssproxy use it, at least for requests from the NFS server?
>> =C2=A0Is there are good reason not to use gss_display_name() uniformly?
>> =C2=A0Maybe use gss_local_name(), and it that fails, or getpwnam fails,
>> =C2=A0use gss_display_name()??
>
> No, you should configure krb5.conf to map to a fully qualified name if
> that is what you normally want.
>
> The default rule allows mapping only for the default realm and does so
> by truncating away the realm name, but you can configure your own.
>
> see auth_to_local_names directive in krb5.conf

Ah-ha.  Thanks so much.
I added
		auth_to_local =3D RULE:[1:$1@$0]

to krb5.conf, and now it works as expected.

Thanks,
NeilBrown


>
> Simo.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEG8Yp69OQ2HB7X0l6Oeye3VZigbkFAljAqIgACgkQOeye3VZi
gblWuhAAvCq6JBUBQArJK03JVnvOA/lsO3zrdS64vh6ciVzJgtnlvEW+Vcvm062J
o8CdjWMrOn85oDa9nMQt0mPDdsHvSiP0s7B+ZhX5mztPrCqdNjA77Q+sGGkSJtl8
7oRKp3oyL83ZmHKwD+eSrUKhxQwY8ZD8nq0IqPvokIgLgQ16m5vZwKaahUAdarJm
uV+OO7lUtNf6NH7dbysMeYhDk9VjWZ1cVbeGndIKKczgndHmKw8e/1c4pnxMUV/Z
LS9qbCAjA+PzU/hvxKkULJdfY8PokOLV5WEsmoN/TEsHzUdQeaLvdAhH8Qf07Q2M
TalkUAUDjswAnN2Da8jK2ISAVLaH4kUuXozn23XBXizU25K/asCifMWNzKfQ0p1c
1rU5mKCF7z4E0PrYFTVcR9z3FTNI/4P7xD8RJBj8NMb+A3tZ6XWYJGZ25HHVUDd2
5HuFAeIYpKnZZG85FjmnqobwGG9aHvf5QS1kJz9Ad9ZZc2rJJ7wd9jae15gMa503
AGcsA45MpH3Cix6P78Yxz7o1x8XFJh1M3tZdBrdQXK+mpm0b4YrKQniXGCSJn4w9
K3vupYXf60y8or72qJszP1sB9NK8D26gkG9MZgj/aNfaPse+TZ30jViwrCJ77UKg
bVthpzg2D1UrwU7SBnuDboQbnRVvX1NIoUJBRXMbnlg3+3h5Sps=
=xeYS
-----END PGP SIGNATURE-----
--=-=-=--
